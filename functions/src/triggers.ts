import {onDocumentUpdated, onDocumentCreated} from "firebase-functions/v2/firestore";
import {auth} from "firebase-functions/v1";
import {getAuth} from "firebase-admin/auth";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {installmentPlan} from "./finance";
import {sendPushNotification} from "./notify";

const db = getFirestore();

/**
 * پس از تأیید تراکنش: قسط مرتبط را paid می‌کند و به عضو خبر می‌دهد.
 * موجودی صندوق در Callable approveTransaction به‌روز می‌شود؛ اینجا مکمل است.
 */
export const onTransactionApproved = onDocumentUpdated("transactions/{transactionId}", async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!before || !after) return;
  if (before.status === after.status) return;
  if (after.status !== "approved") return;
  if (after.relatedInstallmentId) {
    await db.doc(`installments/${after.relatedInstallmentId}`).set({
      status: "paid",
      paidTransactionId: event.params.transactionId,
    }, {merge: true});
  }
  await sendPushNotification(
    after.memberId,
    "پرداخت تأیید شد",
    `${after.amount} تومان به صندوق افزوده شد.`,
  );
});

/**
 * پس از تأیید وام: اگر اقساط ساخته نشده باشند با کارمزد ۲٪ تولید می‌شوند.
 */
export const onLoanApproved = onDocumentUpdated("loans/{loanId}", async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!before || !after) return;
  if (before.status === after.status) return;
  if (after.status !== "active" && after.status !== "approved") return;
  const existing = await db.collection("installments").where("loanId", "==", event.params.loanId).limit(1).get();
  if (!existing.empty) return;
  const fund = (await db.doc(`funds/${after.fundId}`).get()).data();
  const rate = after.adminFeeRate || 0.02;
  const plan = installmentPlan(
    after.amount,
    after.termMonths,
    new Date().toISOString(),
    rate,
    fund?.paymentPeriodDays || 30,
  );
  const batch = db.batch();
  for (const item of plan.items) {
    const ref = db.collection("installments").doc();
    batch.set(ref, {
      id: ref.id,
      loanId: event.params.loanId,
      fundId: after.fundId,
      memberId: after.memberId,
      sequence: item.sequence,
      amount: item.amount,
      dueDate: item.dueDate,
      status: "upcoming",
    });
  }
  batch.update(db.doc(`funds/${after.fundId}/members/${after.memberId}`), {
    debt: FieldValue.increment(plan.total),
  });
  await batch.commit();
  await sendPushNotification(after.memberId, "وام تأیید شد", "جدول اقساط در اپلیکیشن آمده است.");
});

/** اولین کاربر: Custom Claim پلتفرم. نقش صندوق از عضویت per-fund می‌آید. */
export const onUserCreated = auth.user().onCreate(async (user) => {
  const uid = user.uid;
  const users = await db.collection("users").limit(2).get();
  if (users.size <= 1) {
    await getAuth().setCustomUserClaims(uid, {platformAdmin: true, role: "admin"});
  }
});

export const onUserDocCreated = onDocumentCreated("users/{userId}", async (event) => {
  const uid = event.params.userId;
  const users = await db.collection("users").limit(2).get();
  if (users.size <= 1) {
    await getAuth().setCustomUserClaims(uid, {platformAdmin: true, role: "admin"});
  }
});
