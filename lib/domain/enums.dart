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

/// مقدار ذخیره‌شده در Firestore برای وضعیت تراکنش.
extension TransactionStatusWire on TransactionStatus {
  /// `pending` در دامنه همان `pending_approval` در Firestore است.
  String get firestoreValue => switch (this) {
        TransactionStatus.pending => 'pending_approval',
        TransactionStatus.approved => 'approved',
        TransactionStatus.rejected => 'rejected',
      };

  static TransactionStatus fromWire(dynamic raw) {
    switch (raw?.toString()) {
      case 'pending_approval':
      case 'pending':
        return TransactionStatus.pending;
      case 'approved':
        return TransactionStatus.approved;
      case 'rejected':
        return TransactionStatus.rejected;
      default:
        return TransactionStatus.pending;
    }
  }
}

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

extension DrawStatusX on DrawStatus {
  String get fa => switch (this) {
    DrawStatus.scheduled => 'زمان‌بندی‌شده',
    DrawStatus.ready => 'آماده قرعه',
    DrawStatus.completed => 'انجام‌شده',
    DrawStatus.cancelled => 'لغو شده',
  };
}

extension DrawSelectionModeX on DrawSelectionMode {
  String get fa => switch (this) {
    DrawSelectionMode.random => 'تصادفی',
    DrawSelectionMode.manual => 'انتخاب دستی مدیر',
  };
}

extension InvoiceStatusX on InvoiceStatus {
  String get fa => switch (this) {
    InvoiceStatus.accruing => 'در حال جمع‌آوری',
    InvoiceStatus.issued => 'صادر شده',
    InvoiceStatus.paid => 'پرداخت‌شده',
    InvoiceStatus.overdue => 'معوق',
  };
}

extension SubscriptionTierX on SubscriptionTier {
  String get fa => this == SubscriptionTier.premium ? 'پریمیوم' : 'رایگان';
}
