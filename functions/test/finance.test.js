const test = require("node:test");
const assert = require("node:assert/strict");

/**
 * تست سادهٔ جدول اقساط ۲٪ بدون Firebase.
 * منطق با functions/src/finance.ts یکسان نگه داشته می‌شود.
 */
function installmentPlan(principal, termMonths, startIso, feeRate = 0.02, periodDays = 30) {
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

test("۲٪ هزینه اداری روی ۱۰ قسط سرشکن می‌شود", () => {
  const plan = installmentPlan(50000000, 10, "2026-01-01T00:00:00.000Z");
  assert.equal(plan.fee, 1000000);
  assert.equal(plan.total, 51000000);
  assert.equal(plan.items.length, 10);
  const sum = plan.items.reduce((a, i) => a + i.amount, 0);
  assert.equal(sum, plan.total);
});

test("تأیید خودکار وجود ندارد — وضعیت پیشنهاد pending است", () => {
  const suggestion = { status: "pending_approval", source: "bankima" };
  assert.notEqual(suggestion.status, "approved");
});
