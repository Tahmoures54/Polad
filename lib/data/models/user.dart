import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters/iso_date_time_converter.dart';
import 'enums.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// کاربر اپلیکیشن پولاد.
///
/// شناسایی با شماره موبایل انجام می‌شود. نقش در سطح کاربر، نقش پیش‌فرض است؛
/// نقش عملیاتی هر صندوق در عضویت همان صندوق بررسی می‌شود.
@freezed
abstract class User with _$User {
  /// سازندهٔ اصلی مدل کاربر.
  const factory User({
    /// شناسه یکتای احراز هویت (معمولاً Firebase Auth uid).
    required String uid,

    /// نام نمایشی فارسی کاربر.
    required String name,

    /// شماره موبایل به صورت ۰۹xxxxxxxxx.
    required String phone,

    /// نقش پیش‌فرض: مدیر یا عضو.
    required UserRole role,

    /// فهرست صندوق‌هایی که کاربر در آن‌ها عضویت دارد.
    @Default(<String>[]) List<String> fundIds,

    /// زمان ایجاد حساب.
    @IsoDateTimeConverter() required DateTime createdAt,
  }) = _User;

  /// ساخت مدل از JSON / Map فایراستور (پس از نرمال‌سازی تاریخ).
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
