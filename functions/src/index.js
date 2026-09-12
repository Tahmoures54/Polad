/**
 * Polad Cloud Functions — source of truth for money movement.
 * Sensitive writes (approve, loan decision, draw, billing) never run on the client.
 *
 * Software service fee is accrued to the FUND ADMIN invoice and is NEVER
 * deducted from a member payment (Shaparak circular).
 */
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const axios = require("axios");
const crypto = require("crypto");

initializeApp();
const db = getFirestore();

const MIN_FEE = 0.005;
const MAX_FEE = 0.01;
const LOAN_FEE = 0.02;
const FREE_MEMBER_LIMIT = 10;

function assertAuth(req) {
  if (!req.auth?.uid) throw new HttpsError("unauthenticated", "وارد نشده‌اید");
  return req.auth.uid;
}

async function memberOf(fundId, uid) {
  const snap = await db.doc(`funds/${fundId}/members/${uid}`).get();
  if (!snap.exists) throw new HttpsError("permission-denied", "عضو این صندوق نیستید");
  return snap.data();
}

async function assertAdmin(fundId, uid) {
  const m = await memberOf(fundId, uid);
  if (m.role !== "admin") throw new HttpsError("permission-denied", "فقط مدیر");
  return m;
}

function inviteCode() {
  const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  let out = "";
  for (let i = 0; i < 6; i++) out += alphabet[crypto.randomInt(alphabet.length)];
  return out;
}

function installmentPlan(principal, termMonths, startIso, feeRate, periodDays) {
  const fee = Math.round(principal * feeRate);
  const total = principal + fee;
  const base = Math.floor(total / termMonths);
  const remainder = total - base * termMonths;
  const start = new Date(startIso);
  const items = [];
  for (let i = 0; i < termMonths; i++) {
    const due = new Date(start.getTime());
    due.setDate(due.getDate() + periodDays * (i + 1));
    items.push({
      sequence: i + 1,
      amount: base + (i === termMonths - 1 ? remainder : 0),
      dueDate: due.toISOString(),
    });
  }
  return { fee, total, items };
}

exports.createFund = onCall(async (req) => {
  const uid = assertAuth(req);
  const { name, shareAmount, paymentPeriodDays, serviceFeeRate, charterText, bankIban, bankAccount, isCharity } = req.data || {};
  if (!name || !shareAmount) throw new HttpsError("invalid-argument", "نام و مبلغ سهم لازم است");
  if (serviceFeeRate < MIN_FEE || serviceFeeRate > MAX_FEE) {
    throw new HttpsError("invalid-argument", "نرخ هزینه خدمات باید بین ۰٫۵٪ تا ۱٪ باشد");
  }
  const user = await db.doc(`users/${uid}`).get();
  const profile = user.data() || {};
  const ref = db.collection("funds").doc();
  const fund = {
    id: ref.id,
    name,
    inviteCode: inviteCode(),
    adminId: uid,
    shareAmount,
    paymentPeriodDays: paymentPeriodDays || 30,
    serviceFeeRate,
    loanAdminFeeRate: LOAN_FEE,
    createdAt: new Date().toISOString(),
    tier: "free",
    charterText: charterText || null,
    bankIban: bankIban || null,
    bankAccount: bankAccount || null,
    bankName: "ملت",
    isCharity: !!isCharity,
    memberCount: 1,
    balance: 0,
  };
  const batch = db.batch();
  batch.set(ref, fund);
  batch.set(db.doc(`funds/${ref.id}/members/${uid}`), {
    userId: uid,
    fundId: ref.id,
    role: "admin",
    displayName: profile.displayName || "مدیر",
    phone: profile.phone || "",
    joinedAt: new Date().toISOString(),
    status: "active",
    shareBalance: 0,
    debt: 0,
    credit: 0,
  });
  batch.set(db.doc(`users/${uid}`), {
    fundIds: FieldValue.arrayUnion(ref.id),
    activeFundId: ref.id,
  }, { merge: true });
  await batch.commit();
  return fund;
});

exports.joinFund = onCall(async (req) => {
  const uid = assertAuth(req);
  const code = String(req.data?.code || "").trim().toUpperCase();
  const found = await db.collection("funds").where("inviteCode", "==", code).limit(1).get();
  if (found.empty) throw new HttpsError("not-found", "کد دعوت نادرست است");
  const fund = found.docs[0].data();
  const members = await db.collection(`funds/${fund.id}/members`).get();
  if (fund.tier !== "premium" && members.size >= FREE_MEMBER_LIMIT) {
    throw new HttpsError("failed-precondition", "ظرفیت نسخه رایگان تکمیل است");
  }
  const user = (await db.doc(`users/${uid}`).get()).data() || {};
  await db.doc(`funds/${fund.id}/members/${uid}`).set({
    userId: uid,
    fundId: fund.id,
    role: "member",
    displayName: user.displayName || "عضو",
    phone: user.phone || "",
    joinedAt: new Date().toISOString(),
    status: "active",
    shareBalance: 0,
    debt: 0,
    credit: 0,
  });
  await db.doc(`funds/${fund.id}`).update({ memberCount: FieldValue.increment(1) });
  await db.doc(`users/${uid}`).set({
    fundIds: FieldValue.arrayUnion(fund.id),
    activeFundId: fund.id,
  }, { merge: true });
  return fund;
});

exports.submitPayment = onCall(async (req) => {
  const uid = assertAuth(req);
  const user = (await db.doc(`users/${uid}`).get()).data();
  const fundId = user?.activeFundId;
  if (!fundId) throw new HttpsError("failed-precondition", "صندوق فعالی ندارید");
  await memberOf(fundId, uid);
  const amount = Number(req.data?.amount);
  if (!Number.isInteger(amount) || amount <= 0) throw new HttpsError("invalid-argument", "مبلغ نامعتبر");
  const ref = db.collection("transactions").doc();
  const tx = {
    id: ref.id,
    fundId,
    memberId: uid,
    memberName: user.displayName || "",
    type: req.data.type || "sharePayment",
    amount,
    status: "pending",
    occurredAt: req.data.occurredAt,
    submittedAt: new Date().toISOString(),
    trackingCode: String(req.data.trackingCode || ""),
    receiptUrl: req.data.receiptUrl || null,
    relatedInstallmentId: req.data.relatedInstallmentId || null,
    relatedLoanId: req.data.relatedLoanId || null,
    source: "manual",
  };
  await ref.set(tx);
  return tx;
});

exports.approveTransaction = onCall(async (req) => {
  const uid = assertAuth(req);
  const txRef = db.doc(`transactions/${req.data.transactionId}`);
  const snap = await txRef.get();
  if (!snap.exists) throw new HttpsError("not-found", "تراکنش پیدا نشد");
  const tx = snap.data();
  await assertAdmin(tx.fundId, uid);
  if (tx.status !== "pending") throw new HttpsError("failed-precondition", "قابل تأیید نیست");
  const fundRef = db.doc(`funds/${tx.fundId}`);
  const fund = (await fundRef.get()).data();
  const fee = Math.round(tx.amount * fund.serviceFeeRate);
  await db.runTransaction(async (t) => {
    t.update(txRef, { status: "approved", reviewerId: uid, reviewNote: req.data.note || null });
    t.update(fundRef, { balance: FieldValue.increment(tx.amount) });
    const memberRef = db.doc(`funds/${tx.fundId}/members/${tx.memberId}`);
    if (tx.type === "sharePayment") {
      t.update(memberRef, { shareBalance: FieldValue.increment(tx.amount) });
    }
    if (tx.type === "installmentPayment") {
      t.update(memberRef, { debt: FieldValue.increment(-tx.amount) });
      if (tx.relatedInstallmentId) {
        t.update(db.doc(`installments/${tx.relatedInstallmentId}`), {
          status: "paid",
          paidTransactionId: tx.id,
        });
      }
    }
  });
  await accrueFee(fund, tx.amount, fee);
  await notify(tx.memberId, "پرداخت تأیید شد", `${tx.amount} تومان به صندوق افزوده شد.`);
  return { ok: true };
});

exports.rejectTransaction = onCall(async (req) => {
  const uid = assertAuth(req);
  const txRef = db.doc(`transactions/${req.data.transactionId}`);
  const tx = (await txRef.get()).data();
  if (!tx) throw new HttpsError("not-found", "تراکنش پیدا نشد");
  await assertAdmin(tx.fundId, uid);
  await txRef.update({ status: "rejected", reviewerId: uid, reviewNote: req.data.note || "رد شد" });
  await notify(tx.memberId, "پرداخت رد شد", req.data.note || "با مدیر تماس بگیرید.");
  return { ok: true };
});

async function accrueFee(fund, volume, fee) {
  const now = new Date();
  const q = await db.collection("service_invoices")
    .where("fundId", "==", fund.id)
    .where("year", "==", now.getFullYear())
    .where("month", "==", now.getMonth() + 1)
    .where("status", "==", "accruing")
    .limit(1)
    .get();
  if (q.empty) {
    const ref = db.collection("service_invoices").doc();
    await ref.set({
      id: ref.id,
      fundId: fund.id,
      adminId: fund.adminId,
      year: now.getFullYear(),
      month: now.getMonth() + 1,
      transactionVolume: volume,
      feeAmount: fee,
      status: "accruing",
      rate: fund.serviceFeeRate,
      note: "هزینه خدمات نرم‌افزاری پولاد — از عضو کسر نمی‌شود.",
    });
  } else {
    await q.docs[0].ref.update({
      transactionVolume: FieldValue.increment(volume),
      feeAmount: FieldValue.increment(fee),
    });
  }
}

exports.requestLoan = onCall(async (req) => {
  const uid = assertAuth(req);
  const user = (await db.doc(`users/${uid}`).get()).data();
  const fundId = user.activeFundId;
  const fund = (await db.doc(`funds/${fundId}`).get()).data();
  const member = await memberOf(fundId, uid);
  const amount = Number(req.data.amount);
  const termMonths = Number(req.data.termMonths);
  if (member.status !== "active") throw new HttpsError("failed-precondition", "عضویت فعال نیست");
  if (member.shareBalance < fund.shareAmount) throw new HttpsError("failed-precondition", "حداقل یک سهم لازم است");
  if (amount > fund.shareAmount * 10) throw new HttpsError("failed-precondition", "سقف وام ۱۰ سهم است");
  const ref = db.collection("loans").doc();
  const loan = {
    id: ref.id,
    fundId,
    memberId: uid,
    memberName: user.displayName || "",
    amount,
    termMonths,
    reason: String(req.data.reason || ""),
    status: "requested",
    adminFeeRate: fund.loanAdminFeeRate,
    requestedAt: new Date().toISOString(),
  };
  await ref.set(loan);
  return loan;
});

exports.decideLoan = onCall(async (req) => {
  const uid = assertAuth(req);
  const loanRef = db.doc(`loans/${req.data.loanId}`);
  const loan = (await loanRef.get()).data();
  if (!loan) throw new HttpsError("not-found", "وام پیدا نشد");
  await assertAdmin(loan.fundId, uid);
  if (!req.data.approve) {
    await loanRef.update({ status: "rejected", decidedAt: new Date().toISOString(), decidedBy: uid, decisionNote: req.data.note || "" });
    return { ok: true };
  }
  const fundRef = db.doc(`funds/${loan.fundId}`);
  const fund = (await fundRef.get()).data();
  if (fund.balance < loan.amount) throw new HttpsError("failed-precondition", "موجودی کافی نیست");
  const plan = installmentPlan(loan.amount, loan.termMonths, new Date().toISOString(), loan.adminFeeRate, fund.paymentPeriodDays);
  const batch = db.batch();
  batch.update(loanRef, { status: "active", decidedAt: new Date().toISOString(), decidedBy: uid });
  batch.update(fundRef, { balance: FieldValue.increment(-loan.amount) });
  batch.update(db.doc(`funds/${loan.fundId}/members/${loan.memberId}`), { debt: FieldValue.increment(plan.total) });
  for (const item of plan.items) {
    const iRef = db.collection("installments").doc();
    batch.set(iRef, {
      id: iRef.id,
      loanId: loan.id,
      fundId: loan.fundId,
      memberId: loan.memberId,
      sequence: item.sequence,
      amount: item.amount,
      dueDate: item.dueDate,
      status: "upcoming",
    });
  }
  await batch.commit();
  await notify(loan.memberId, "وام تأیید شد", "جدول اقساط در اپلیکیشن آمده است.");
  return { ok: true };
});

exports.createDraw = onCall(async (req) => {
  const uid = assertAuth(req);
  const user = (await db.doc(`users/${uid}`).get()).data();
  const fundId = user.activeFundId;
  await assertAdmin(fundId, uid);
  const members = await db.collection(`funds/${fundId}/members`).get();
  const ref = db.collection("draws").doc();
  const draw = {
    id: ref.id,
    fundId,
    title: req.data.title,
    periodStart: req.data.start,
    periodEnd: req.data.end,
    status: "ready",
    mode: req.data.mode || "random",
    prizeAmount: req.data.prizeAmount || 0,
    eligibleMemberIds: members.docs.map((d) => d.id),
  };
  await ref.set(draw);
  return draw;
});

exports.runDraw = onCall(async (req) => {
  const uid = assertAuth(req);
  const drawRef = db.doc(`draws/${req.data.drawId}`);
  const draw = (await drawRef.get()).data();
  if (!draw) throw new HttpsError("not-found", "قرعه پیدا نشد");
  await assertAdmin(draw.fundId, uid);
  const ids = draw.eligibleMemberIds || [];
  const winnerId = req.data.manualWinnerId || ids[crypto.randomInt(ids.length)];
  const winner = (await db.doc(`funds/${draw.fundId}/members/${winnerId}`).get()).data();
  const next = { ...draw, status: "completed", winnerMemberId: winnerId, winnerName: winner?.displayName || "" };
  await drawRef.update(next);
  return next;
});

exports.removeMember = onCall(async (req) => {
  const uid = assertAuth(req);
  await assertAdmin(req.data.fundId, uid);
  if (req.data.userId === uid) throw new HttpsError("failed-precondition", "مدیر خودش را حذف نمی‌کند");
  await db.doc(`funds/${req.data.fundId}/members/${req.data.userId}`).delete();
  await db.doc(`funds/${req.data.fundId}`).update({ memberCount: FieldValue.increment(-1) });
  return { ok: true };
});

exports.changeRole = onCall(async (req) => {
  const uid = assertAuth(req);
  await assertAdmin(req.data.fundId, uid);
  await db.doc(`funds/${req.data.fundId}/members/${req.data.userId}`).update({ role: req.data.role });
  return { ok: true };
});

exports.markInvoicePaid = onCall(async (req) => {
  const uid = assertAuth(req);
  const inv = (await db.doc(`service_invoices/${req.data.invoiceId}`).get()).data();
  if (!inv) throw new HttpsError("not-found", "صورتحساب نیست");
  await assertAdmin(inv.fundId, uid);
  await db.doc(`service_invoices/${req.data.invoiceId}`).update({ status: "paid" });
  return { ok: true };
});

exports.startBankimaPayment = onCall(async (req) => {
  const uid = assertAuth(req);
  const amount = Number(req.data.amountToman);
  const orderRef = db.collection("payment_orders").doc();
  const order = {
    id: orderRef.id,
    uid,
    invoiceId: req.data.invoiceId,
    amountToman: amount,
    amountRial: amount * 10,
    status: "created",
    createdAt: new Date().toISOString(),
  };
  await orderRef.set(order);
  const base = process.env.BANKIMA_BASE_URL;
  const token = process.env.BANKIMA_CLIENT_SECRET;
  if (!base || !token) {
    return { orderId: order.id, redirectUrl: `polad://billing?order=${order.id}&demo=1` };
  }
  try {
    const res = await axios.post(`${base}/v1/payments/paya`, {
      amountRial: order.amountRial,
      description: "هزینه خدمات نرم‌افزاری پولاد",
      trackId: order.id,
    }, { headers: { Authorization: `Bearer ${token}` }, timeout: 15000 });
    await orderRef.update({ bankimaId: res.data.paymentId, status: "redirected" });
    return { orderId: order.id, redirectUrl: res.data.redirectUrl, paymentId: res.data.paymentId };
  } catch (e) {
    await orderRef.update({ status: "failed", error: String(e.message || e) });
    throw new HttpsError("unavailable", "ارتباط با بانکیما برقرار نشد");
  }
});

/** Custom Claims فقط با Admin SDK تنظیم می‌شود؛ کلاینت این Callable را صدا می‌زند. */
exports.setCustomClaims = onCall(async (req) => {
  const uid = assertAuth(req);
  const { targetUid, role, fundId } = req.data || {};
  if (!targetUid || !role) throw new HttpsError("invalid-argument", "uid و نقش لازم است");
  if (role !== "admin" && role !== "member") {
    throw new HttpsError("invalid-argument", "نقش نامعتبر است");
  }
  if (fundId) {
    await assertAdmin(fundId, uid);
  } else if (uid !== targetUid) {
    throw new HttpsError("permission-denied", "فقط مدیر صندوق می‌تواند نقش دیگران را تنظیم کند");
  }
  await getAuth().setCustomUserClaims(targetUid, { role, fundId: fundId || null });
  return { ok: true };
});

exports.verifyBankimaPayment = onCall(async (req) => {
  assertAuth(req);
  const order = await db.doc(`payment_orders/${req.data.orderId}`).get();
  if (!order.exists) throw new HttpsError("not-found", "سفارش نیست");
  await order.ref.update({ status: "verified" });
  if (order.data().invoiceId) {
    await db.doc(`service_invoices/${order.data().invoiceId}`).update({ status: "paid" });
  }
  return { ok: true };
});

async function notify(userId, title, body) {
  try {
    const user = (await db.doc(`users/${userId}`).get()).data();
    if (!user?.fcmToken) return;
    await getMessaging().send({ token: user.fcmToken, notification: { title, body }, android: { priority: "high" } });
  } catch (_) {
    // never fail the money path because of push
  }
}

exports.sendInstallmentReminders = onSchedule("every day 08:00", async () => {
  const now = new Date();
  const until = new Date(now.getTime() + 24 * 3600 * 1000);
  const snaps = await db.collection("installments").where("status", "==", "upcoming").get();
  for (const doc of snaps.docs) {
    const i = doc.data();
    const due = new Date(i.dueDate);
    if (due >= now && due <= until) {
      await notify(i.memberId, "یادآوری قسط", "سررسید قسط شما فردا است.");
    }
    if (due < now) {
      await doc.ref.update({ status: "overdue" });
    }
  }
});
