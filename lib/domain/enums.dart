enum UserRole { admin, member }

enum MemberStatus { active, suspended, left }

enum SubscriptionTier { free, premium }

enum TransactionType {
  sharePayment,
  installmentPayment,
  loanDisbursement,
  adjustment,
  withdrawal,
}

enum TransactionStatus { pending, approved, rejected }

enum PaymentSource { manual, bankima, smsMatch }

enum LoanStatus { requested, approved, rejected, active, closed }

enum InstallmentStatus { upcoming, paid, overdue }

enum DrawStatus { scheduled, ready, completed, cancelled }

enum DrawSelectionMode { random, manual }

enum InvoiceStatus { accruing, issued, paid, overdue }

enum PaymentOrderStatus { created, redirected, verified, failed }

extension UserRoleX on UserRole {
  String get fa => this == UserRole.admin ? 'مدیر' : 'عضو';
}

extension TransactionStatusX on TransactionStatus {
  String get fa => switch (this) {
    TransactionStatus.pending => 'در انتظار تأیید',
    TransactionStatus.approved => 'تأیید شده',
    TransactionStatus.rejected => 'رد شده',
  };
}

extension TransactionTypeX on TransactionType {
  String get fa => switch (this) {
    TransactionType.sharePayment => 'پرداخت سهم',
    TransactionType.installmentPayment => 'پرداخت قسط',
    TransactionType.loanDisbursement => 'پرداخت وام',
    TransactionType.adjustment => 'اصلاحیه',
    TransactionType.withdrawal => 'برداشت',
  };
}

extension LoanStatusX on LoanStatus {
  String get fa => switch (this) {
    LoanStatus.requested => 'در انتظار بررسی',
    LoanStatus.approved => 'تأیید شده',
    LoanStatus.rejected => 'رد شده',
    LoanStatus.active => 'فعال',
    LoanStatus.closed => 'تسویه شده',
  };
}

extension InstallmentStatusX on InstallmentStatus {
  String get fa => switch (this) {
    InstallmentStatus.upcoming => 'پیش‌رو',
    InstallmentStatus.paid => 'پرداخت‌شده',
    InstallmentStatus.overdue => 'معوق',
  };
}
