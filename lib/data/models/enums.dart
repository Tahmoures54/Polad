import 'package:json_annotation/json_annotation.dart';

/// نقش کاربر در یک صندوق قرض‌الحسنه.
///
/// مدیر کنترل نهایی دارد؛ عضو فقط وضعیت خودش را می‌بیند و پرداخت ثبت می‌کند.
@JsonEnum()
enum UserRole {
  /// مدیر صندوق — تأیید تراکنش، اعضا، وام، گزارش و تنظیمات.
  @JsonValue('admin')
  admin,

  /// عضو صندوق — مشاهده اطلاعات شخصی و ثبت پرداخت.
  @JsonValue('member')
  member;

  /// عنوان فارسی برای نمایش در رابط کاربری.
  String get displayName => switch (this) {
    UserRole.admin => 'مدیر',
    UserRole.member => 'عضو',
  };

  /// آیا این نقش دسترسی کامل مدیریتی دارد؟
  bool get isAdmin => this == UserRole.admin;

  /// آیا این نقش فقط عضو عادی است؟
  bool get isMember => this == UserRole.member;

  /// مقدار ذخیره‌شده در Firestore / Custom Claims.
  String get firestoreValue => switch (this) {
    UserRole.admin => 'admin',
    UserRole.member => 'member',
  };
}

/// نوع دوره پرداخت سهم صندوق.
@JsonEnum()
enum FundPeriodType {
  /// پرداخت هفتگی.
  @JsonValue('weekly')
  weekly,

  /// پرداخت ماهانه (حالت پیش‌فرض صندوق خانوادگی).
  @JsonValue('monthly')
  monthly,

  /// دوره سفارشی که در تنظیمات صندوق مشخص می‌شود.
  @JsonValue('custom')
  custom;

  /// عنوان فارسی دوره.
  String get displayName => switch (this) {
    FundPeriodType.weekly => 'هفتگی',
    FundPeriodType.monthly => 'ماهانه',
    FundPeriodType.custom => 'سفارشی',
  };

  /// مقدار ذخیره‌شده در Firestore.
  String get firestoreValue => switch (this) {
    FundPeriodType.weekly => 'weekly',
    FundPeriodType.monthly => 'monthly',
    FundPeriodType.custom => 'custom',
  };
}

/// وضعیت چرخه تأیید تراکنش توسط مدیر.
@JsonEnum()
enum TransactionStatus {
  /// ثبت شده و منتظر تأیید یا رد مدیر است.
  @JsonValue('pending_approval')
  pendingApproval,

  /// مدیر تراکنش را پذیرفته و در موجودی صندوق اعمال شده است.
  @JsonValue('approved')
  approved,

  /// مدیر تراکنش را رد کرده است.
  @JsonValue('rejected')
  rejected;

  /// عنوان فارسی وضعیت.
  String get displayName => switch (this) {
    TransactionStatus.pendingApproval => 'در انتظار تأیید',
    TransactionStatus.approved => 'تأیید شده',
    TransactionStatus.rejected => 'رد شده',
  };

  /// هنوز تصمیم مدیر نگرفته است.
  bool get isPending => this == TransactionStatus.pendingApproval;

  /// تصمیم نهایی گرفته شده (تأیید یا رد).
  bool get isFinal => this != TransactionStatus.pendingApproval;

  /// مقدار ذخیره‌شده در Firestore (`pending_approval` نه `pending`).
  String get firestoreValue => switch (this) {
    TransactionStatus.pendingApproval => 'pending_approval',
    TransactionStatus.approved => 'approved',
    TransactionStatus.rejected => 'rejected',
  };
}

/// ماهیت مالی تراکنش.
@JsonEnum()
enum TransactionType {
  /// پرداخت قسط وام.
  @JsonValue('installment')
  installment,

  /// پرداخت/دریافت مرتبط با وام (مثلاً واریز اصل وام به عضو).
  @JsonValue('loan')
  loan,

  /// برداشت از صندوق.
  @JsonValue('withdrawal')
  withdrawal,

  /// هزینه خدمات نرم‌افزاری (فقط صورتحساب مدیر — از عضو کسر نمی‌شود).
  @JsonValue('fee')
  fee;

  /// عنوان فارسی نوع تراکنش.
  String get displayName => switch (this) {
    TransactionType.installment => 'قسط',
    TransactionType.loan => 'وام',
    TransactionType.withdrawal => 'برداشت',
    TransactionType.fee => 'هزینه خدمات',
  };

  /// آیا این نوع، ورود پول به صندوق است؟
  bool get isInflow => this == TransactionType.installment;

  /// آیا این نوع، خروج پول از صندوق است؟
  bool get isOutflow => this == TransactionType.loan || this == TransactionType.withdrawal;

  /// مقدار ذخیره‌شده در Firestore.
  String get firestoreValue => switch (this) {
    TransactionType.installment => 'installment',
    TransactionType.loan => 'loan',
    TransactionType.withdrawal => 'withdrawal',
    TransactionType.fee => 'fee',
  };
}

/// وضعیت درخواست و چرخه عمر وام قرض‌الحسنه.
@JsonEnum()
enum LoanStatus {
  /// درخواست عضو ثبت شده و منتظر بررسی مدیر است.
  @JsonValue('pending')
  pending,

  /// مدیر وام را تأیید کرده ولی هنوز فعال نشده است.
  @JsonValue('approved')
  approved,

  /// مدیر درخواست را رد کرده است.
  @JsonValue('rejected')
  rejected,

  /// وام پرداخت شده و اقساط در جریان است.
  @JsonValue('active')
  active,

  /// همه اقساط تسویه شده‌اند.
  @JsonValue('completed')
  completed;

  /// عنوان فارسی وضعیت وام.
  String get displayName => switch (this) {
    LoanStatus.pending => 'در انتظار بررسی',
    LoanStatus.approved => 'تأیید شده',
    LoanStatus.rejected => 'رد شده',
    LoanStatus.active => 'فعال',
    LoanStatus.completed => 'تسویه شده',
  };

  /// آیا هنوز می‌توان روی این درخواست تصمیم گرفت؟
  bool get isDecidable => this == LoanStatus.pending;

  /// آیا وام در حال بازپرداخت است؟
  bool get isOngoing => this == LoanStatus.active;

  /// مقدار ذخیره‌شده در Firestore.
  String get firestoreValue => switch (this) {
    LoanStatus.pending => 'pending',
    LoanStatus.approved => 'approved',
    LoanStatus.rejected => 'rejected',
    LoanStatus.active => 'active',
    LoanStatus.completed => 'completed',
  };
}

/// وضعیت یک قسط نسبت به سررسید و پرداخت.
@JsonEnum()
enum InstallmentStatus {
  /// هنوز سررسید نشده یا پرداخت نشده است.
  @JsonValue('pending')
  pending,

  /// قسط پرداخت و تأیید شده است.
  @JsonValue('paid')
  paid,

  /// از سررسید گذشته و پرداخت نشده است.
  @JsonValue('overdue')
  overdue;

  /// عنوان فارسی وضعیت قسط.
  String get displayName => switch (this) {
    InstallmentStatus.pending => 'در انتظار پرداخت',
    InstallmentStatus.paid => 'پرداخت‌شده',
    InstallmentStatus.overdue => 'معوق',
  };

  /// آیا این قسط هنوز بدهی باز است؟
  bool get isOpen => this != InstallmentStatus.paid;

  /// مقدار ذخیره‌شده در Firestore.
  String get firestoreValue => switch (this) {
    InstallmentStatus.pending => 'pending',
    InstallmentStatus.paid => 'paid',
    InstallmentStatus.overdue => 'overdue',
  };
}

/// روش انتخاب برنده قرعه‌کشی.
@JsonEnum()
enum DrawMethod {
  /// انتخاب تصادفی شفاف میان اعضای مشمول.
  @JsonValue('random')
  random,

  /// انتخاب دستی توسط مدیر.
  @JsonValue('manual')
  manual;

  /// عنوان فارسی روش قرعه.
  String get displayName => switch (this) {
    DrawMethod.random => 'تصادفی',
    DrawMethod.manual => 'دستی',
  };

  bool get isRandom => this == DrawMethod.random;

  /// مقدار ذخیره‌شده در Firestore.
  String get firestoreValue => switch (this) {
    DrawMethod.random => 'random',
    DrawMethod.manual => 'manual',
  };
}

/// وضعیت پرداخت صورتحساب هزینه خدمات نرم‌افزاری (بدهی مدیر، نه عضو).
@JsonEnum()
enum FeeStatus {
  /// مبلغ دوره هنوز تسویه نشده است.
  @JsonValue('pending')
  pending,

  /// مدیر هزینه خدمات را پرداخت کرده است.
  @JsonValue('paid')
  paid;

  /// عنوان فارسی وضعیت صورتحساب.
  String get displayName => switch (this) {
    FeeStatus.pending => 'پرداخت‌نشده',
    FeeStatus.paid => 'پرداخت‌شده',
  };

  bool get isPaid => this == FeeStatus.paid;

  /// مقدار ذخیره‌شده در Firestore.
  String get firestoreValue => switch (this) {
    FeeStatus.pending => 'pending',
    FeeStatus.paid => 'paid',
  };
}
