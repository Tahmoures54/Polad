import {onSchedule} from "firebase-functions/v2/scheduler";
import {getFirestore} from "firebase-admin/firestore";
import {sendPushNotification} from "./notify";
import * as bankima from "./bankima";

const db = getFirestore();

/** یادآوری روزانه اقساط نزدیک به سررسید. */
export const sendInstallmentReminders = onSchedule("every day 08:00", async () => {
  const now = new Date();
  const until = new Date(now.getTime() + 24 * 3600 * 1000);
  const snaps = await db.collection("installments").where("status", "==", "upcoming").get();
  for (const doc of snaps.docs) {
    const i = doc.data();
    const due = new Date(i.dueDate);
    if (due >= now && due <= until) {
      await sendPushNotification(i.memberId, "یادآوری قسط", "سررسید قسط شما فردا است.");
    }
  }
});

/** علامت‌گذاری اقساط معوق. */
export const checkOverdueInstallments = onSchedule("every day 01:00", async () => {
  const now = new Date();
  const snaps = await db.collection("installments").where("status", "==", "upcoming").get();
  for (const doc of snaps.docs) {
    const due = new Date(doc.data().dueDate);
    if (due < now) {
      await doc.ref.update({status: "overdue"});
    }
  }
});

/** محاسبه کارمزد ماهانه مدیر — هرگز از عضو کسر نمی‌شود. */
export const calculateMonthlyFee = onSchedule("0 3 1 * *", async () => {
  const funds = await db.collection("funds").get();
  const now = new Date();
  for (const fundDoc of funds.docs) {
    const fund = fundDoc.data();
    if (fund.isCharity) continue;
    const txs = await db.collection("transactions")
      .where("fundId", "==", fund.id)
      .where("status", "==", "approved")
      .get();
    const volume = txs.docs.reduce((sum, d) => sum + Number(d.data().amount || 0), 0);
    const fee = Math.round(volume * (fund.serviceFeeRate || 0.005));
    const id = `${fund.id}-${now.getFullYear()}-${now.getMonth() + 1}`;
    await db.doc(`service_invoices/${id}`).set({
      id,
      fundId: fund.id,
      adminId: fund.adminId,
      year: now.getFullYear(),
      month: now.getMonth() + 1,
      transactionVolume: volume,
      feeAmount: fee,
      status: fee > 0 ? "issued" : "paid",
      rate: fund.serviceFeeRate || 0.005,
      note: "هزینه خدمات نرم‌افزاری — از عضو کسر نشده",
    }, {merge: true});
  }
});

/** یادآوری پرداخت کارمزد مدیر. */
export const sendFeeReminder = onSchedule("every monday 09:00", async () => {
  const snaps = await db.collection("service_invoices").where("status", "in", ["issued", "overdue"]).get();
  for (const doc of snaps.docs) {
    const inv = doc.data();
    await sendPushNotification(
      inv.adminId,
      "یادآوری هزینه خدمات نرم‌افزاری",
      "صورتحساب کارمزد صندوق در انتظار تسویه است. از عضو کسر نشده است.",
    );
  }
});

/**
 * همگام‌سازی گردش بانکیما به‌صورت پیشنهاد pending_approval.
 * تأیید خودکار مطلقاً انجام نمی‌شود.
 */
export const syncBankTransactions = onSchedule("every 6 hours", async () => {
  if (!bankima.configured()) return;
  const funds = await db.collection("funds").get();
  const to = new Date();
  const from = new Date(to.getTime() - 24 * 3600 * 1000);
  for (const fundDoc of funds.docs) {
    const fund = fundDoc.data();
    if (!fund.bankAccount) continue;
    try {
      const statement = await bankima.getAccountStatement(
        fund.bankAccount,
        from.toISOString(),
        to.toISOString(),
      );
      const items = statement.items || statement.rows || [];
      for (const row of items) {
        const tracking = row.trackingCode || row.receiptCode;
        if (!tracking) continue;
        const dup = await db.collection("transactions").where("trackingCode", "==", tracking).limit(1).get();
        if (!dup.empty) continue;
        const ref = db.collection("transactions").doc();
        await ref.set({
          id: ref.id,
          fundId: fund.id,
          memberId: "bankima-unmatched",
          memberName: "پیشنهاد بانکیما",
          type: "sharePayment",
          amount: row.amountToman || Math.round((row.amountRial || 0) / 10),
          status: "pending_approval",
          occurredAt: row.occurredAt || new Date().toISOString(),
          submittedAt: new Date().toISOString(),
          trackingCode: tracking,
          source: "bankima",
          reviewNote: "همگام‌سازی بانکیما — تأیید خودکار نیست",
        });
      }
    } catch {
      // سرویس بانکی نباید همگام‌سازی را متوقف کند
    }
  }
});
