/**
 * جدول اقساط قرض‌الحسنه: اصل + ۲٪ هزینه اداری صندوق (نه ربا).
 */
export interface InstallmentDraft {
  sequence: number;
  amount: number;
  dueDate: string;
}

export interface InstallmentPlan {
  fee: number;
  total: number;
  items: InstallmentDraft[];
}

export function installmentPlan(
  principal: number,
  termMonths: number,
  startIso: string,
  feeRate = 0.02,
  periodDays = 30,
): InstallmentPlan {
  const fee = Math.round(principal * feeRate);
  const total = principal + fee;
  const base = Math.floor(total / termMonths);
  const remainder = total - base * termMonths;
  const start = new Date(startIso);
  const items: InstallmentDraft[] = [];
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
