// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Transaction {

/// شناسه سند تراکنش.
 String get transactionId;/// صندوق مربوطه.
 String get fundId;/// عضوی که تراکنش به او تعلق دارد.
 String get memberId;/// مبلغ به تومان. این همان مبلغی است که به صندوق می‌نشیند.
 int get amount;/// کد پیگیری کارت‌به‌کارت / بانکیما.
 String? get receiptCode;/// تاریخ وقوع واریز یا برداشت از دید عضو.
@IsoDateTimeConverter() DateTime get date;/// وضعیت تأیید مدیر.
 TransactionStatus get status;/// نوع عملیات مالی.
 TransactionType get type;/// نشانی تصویر فیش در Storage (اختیاری).
 String? get receiptImageUrl;/// زمان ثبت در اپلیکیشن.
@IsoDateTimeConverter() DateTime get submittedAt;/// uid مدیری که تصمیم گرفته است.
 String? get approvedBy;/// زمان تأیید یا رد.
@NullableIsoDateTimeConverter() DateTime? get approvedAt;/// مبلغ هزینه خدمات نرم‌افزاری مربوط به این تراکنش (بدهی مدیر).
 int get feeAmount;/// اگر `true` باشد یعنی هزینه در صورتحساب مدیر ثبت شده است، نه کسر از عضو.
 bool get feeApplied;
/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionCopyWith<Transaction> get copyWith => _$TransactionCopyWithImpl<Transaction>(this as Transaction, _$identity);

  /// Serializes this Transaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Transaction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transaction&&(identical(other.transactionId, _this.transactionId) || other.transactionId == _this.transactionId)&&(identical(other.fundId, _this.fundId) || other.fundId == _this.fundId)&&(identical(other.memberId, _this.memberId) || other.memberId == _this.memberId)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.receiptCode, _this.receiptCode) || other.receiptCode == _this.receiptCode)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.receiptImageUrl, _this.receiptImageUrl) || other.receiptImageUrl == _this.receiptImageUrl)&&(identical(other.submittedAt, _this.submittedAt) || other.submittedAt == _this.submittedAt)&&(identical(other.approvedBy, _this.approvedBy) || other.approvedBy == _this.approvedBy)&&(identical(other.approvedAt, _this.approvedAt) || other.approvedAt == _this.approvedAt)&&(identical(other.feeAmount, _this.feeAmount) || other.feeAmount == _this.feeAmount)&&(identical(other.feeApplied, _this.feeApplied) || other.feeApplied == _this.feeApplied));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Transaction;
  return Object.hash(runtimeType,_this.transactionId,_this.fundId,_this.memberId,_this.amount,_this.receiptCode,_this.date,_this.status,_this.type,_this.receiptImageUrl,_this.submittedAt,_this.approvedBy,_this.approvedAt,_this.feeAmount,_this.feeApplied);
}

@override
String toString() {
  final _this = this as Transaction;
  return 'Transaction(transactionId: ${_this.transactionId}, fundId: ${_this.fundId}, memberId: ${_this.memberId}, amount: ${_this.amount}, receiptCode: ${_this.receiptCode}, date: ${_this.date}, status: ${_this.status}, type: ${_this.type}, receiptImageUrl: ${_this.receiptImageUrl}, submittedAt: ${_this.submittedAt}, approvedBy: ${_this.approvedBy}, approvedAt: ${_this.approvedAt}, feeAmount: ${_this.feeAmount}, feeApplied: ${_this.feeApplied})';
}


}

/// @nodoc
abstract mixin class $TransactionCopyWith<$Res>  {
  factory $TransactionCopyWith(Transaction value, $Res Function(Transaction) _then) = _$TransactionCopyWithImpl;
@useResult
$Res call({
 String transactionId, String fundId, String memberId, int amount, String? receiptCode,@IsoDateTimeConverter() DateTime date, TransactionStatus status, TransactionType type, String? receiptImageUrl,@IsoDateTimeConverter() DateTime submittedAt, String? approvedBy,@NullableIsoDateTimeConverter() DateTime? approvedAt, int feeAmount, bool feeApplied
});




}
/// @nodoc
class _$TransactionCopyWithImpl<$Res>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._self, this._then);

  final Transaction _self;
  final $Res Function(Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transactionId = null,Object? fundId = null,Object? memberId = null,Object? amount = null,Object? receiptCode = freezed,Object? date = null,Object? status = null,Object? type = null,Object? receiptImageUrl = freezed,Object? submittedAt = null,Object? approvedBy = freezed,Object? approvedAt = freezed,Object? feeAmount = null,Object? feeApplied = null,}) {
  return _then(Transaction(
transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,fundId: null == fundId ? _self.fundId : fundId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,receiptCode: freezed == receiptCode ? _self.receiptCode : receiptCode // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,receiptImageUrl: freezed == receiptImageUrl ? _self.receiptImageUrl : receiptImageUrl // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as String?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,feeAmount: null == feeAmount ? _self.feeAmount : feeAmount // ignore: cast_nullable_to_non_nullable
as int,feeApplied: null == feeApplied ? _self.feeApplied : feeApplied // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Transaction].
extension TransactionPatterns on Transaction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Transaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Transaction value)  $default,){
final _that = this;
switch (_that) {
case _Transaction():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Transaction value)?  $default,){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String transactionId,  String fundId,  String memberId,  int amount,  String? receiptCode, @IsoDateTimeConverter()  DateTime date,  TransactionStatus status,  TransactionType type,  String? receiptImageUrl, @IsoDateTimeConverter()  DateTime submittedAt,  String? approvedBy, @NullableIsoDateTimeConverter()  DateTime? approvedAt,  int feeAmount,  bool feeApplied)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.transactionId,_that.fundId,_that.memberId,_that.amount,_that.receiptCode,_that.date,_that.status,_that.type,_that.receiptImageUrl,_that.submittedAt,_that.approvedBy,_that.approvedAt,_that.feeAmount,_that.feeApplied);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String transactionId,  String fundId,  String memberId,  int amount,  String? receiptCode, @IsoDateTimeConverter()  DateTime date,  TransactionStatus status,  TransactionType type,  String? receiptImageUrl, @IsoDateTimeConverter()  DateTime submittedAt,  String? approvedBy, @NullableIsoDateTimeConverter()  DateTime? approvedAt,  int feeAmount,  bool feeApplied)  $default,) {final _that = this;
switch (_that) {
case _Transaction():
return $default(_that.transactionId,_that.fundId,_that.memberId,_that.amount,_that.receiptCode,_that.date,_that.status,_that.type,_that.receiptImageUrl,_that.submittedAt,_that.approvedBy,_that.approvedAt,_that.feeAmount,_that.feeApplied);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String transactionId,  String fundId,  String memberId,  int amount,  String? receiptCode, @IsoDateTimeConverter()  DateTime date,  TransactionStatus status,  TransactionType type,  String? receiptImageUrl, @IsoDateTimeConverter()  DateTime submittedAt,  String? approvedBy, @NullableIsoDateTimeConverter()  DateTime? approvedAt,  int feeAmount,  bool feeApplied)?  $default,) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.transactionId,_that.fundId,_that.memberId,_that.amount,_that.receiptCode,_that.date,_that.status,_that.type,_that.receiptImageUrl,_that.submittedAt,_that.approvedBy,_that.approvedAt,_that.feeAmount,_that.feeApplied);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Transaction implements Transaction {
  const _Transaction({required this.transactionId, required this.fundId, required this.memberId, required this.amount, this.receiptCode, @IsoDateTimeConverter() required this.date, required this.status, required this.type, this.receiptImageUrl, @IsoDateTimeConverter() required this.submittedAt, this.approvedBy, @NullableIsoDateTimeConverter() this.approvedAt, this.feeAmount = 0, this.feeApplied = false});
  factory _Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);

/// شناسه سند تراکنش.
@override final  String transactionId;
/// صندوق مربوطه.
@override final  String fundId;
/// عضوی که تراکنش به او تعلق دارد.
@override final  String memberId;
/// مبلغ به تومان. این همان مبلغی است که به صندوق می‌نشیند.
@override final  int amount;
/// کد پیگیری کارت‌به‌کارت / بانکیما.
@override final  String? receiptCode;
/// تاریخ وقوع واریز یا برداشت از دید عضو.
@override@IsoDateTimeConverter() final  DateTime date;
/// وضعیت تأیید مدیر.
@override final  TransactionStatus status;
/// نوع عملیات مالی.
@override final  TransactionType type;
/// نشانی تصویر فیش در Storage (اختیاری).
@override final  String? receiptImageUrl;
/// زمان ثبت در اپلیکیشن.
@override@IsoDateTimeConverter() final  DateTime submittedAt;
/// uid مدیری که تصمیم گرفته است.
@override final  String? approvedBy;
/// زمان تأیید یا رد.
@override@NullableIsoDateTimeConverter() final  DateTime? approvedAt;
/// مبلغ هزینه خدمات نرم‌افزاری مربوط به این تراکنش (بدهی مدیر).
@override@JsonKey() final  int feeAmount;
/// اگر `true` باشد یعنی هزینه در صورتحساب مدیر ثبت شده است، نه کسر از عضو.
@override@JsonKey() final  bool feeApplied;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionCopyWith<_Transaction> get copyWith => __$TransactionCopyWithImpl<_Transaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Transaction&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.fundId, fundId) || other.fundId == fundId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.receiptCode, receiptCode) || other.receiptCode == receiptCode)&&(identical(other.date, date) || other.date == date)&&(identical(other.status, status) || other.status == status)&&(identical(other.type, type) || other.type == type)&&(identical(other.receiptImageUrl, receiptImageUrl) || other.receiptImageUrl == receiptImageUrl)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.approvedBy, approvedBy) || other.approvedBy == approvedBy)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.feeAmount, feeAmount) || other.feeAmount == feeAmount)&&(identical(other.feeApplied, feeApplied) || other.feeApplied == feeApplied));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,transactionId,fundId,memberId,amount,receiptCode,date,status,type,receiptImageUrl,submittedAt,approvedBy,approvedAt,feeAmount,feeApplied);
}

@override
String toString() {
    return 'Transaction(transactionId: $transactionId, fundId: $fundId, memberId: $memberId, amount: $amount, receiptCode: $receiptCode, date: $date, status: $status, type: $type, receiptImageUrl: $receiptImageUrl, submittedAt: $submittedAt, approvedBy: $approvedBy, approvedAt: $approvedAt, feeAmount: $feeAmount, feeApplied: $feeApplied)';
}


}

/// @nodoc
abstract mixin class _$TransactionCopyWith<$Res> implements $TransactionCopyWith<$Res> {
  factory _$TransactionCopyWith(_Transaction value, $Res Function(_Transaction) _then) = __$TransactionCopyWithImpl;
@override @useResult
$Res call({
 String transactionId, String fundId, String memberId, int amount, String? receiptCode,@IsoDateTimeConverter() DateTime date, TransactionStatus status, TransactionType type, String? receiptImageUrl,@IsoDateTimeConverter() DateTime submittedAt, String? approvedBy,@NullableIsoDateTimeConverter() DateTime? approvedAt, int feeAmount, bool feeApplied
});




}
/// @nodoc
class __$TransactionCopyWithImpl<$Res>
    implements _$TransactionCopyWith<$Res> {
  __$TransactionCopyWithImpl(this._self, this._then);

  final _Transaction _self;
  final $Res Function(_Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transactionId = null,Object? fundId = null,Object? memberId = null,Object? amount = null,Object? receiptCode = freezed,Object? date = null,Object? status = null,Object? type = null,Object? receiptImageUrl = freezed,Object? submittedAt = null,Object? approvedBy = freezed,Object? approvedAt = freezed,Object? feeAmount = null,Object? feeApplied = null,}) {
  return _then(_Transaction(
transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,fundId: null == fundId ? _self.fundId : fundId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,receiptCode: freezed == receiptCode ? _self.receiptCode : receiptCode // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,receiptImageUrl: freezed == receiptImageUrl ? _self.receiptImageUrl : receiptImageUrl // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,approvedBy: freezed == approvedBy ? _self.approvedBy : approvedBy // ignore: cast_nullable_to_non_nullable
as String?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,feeAmount: null == feeAmount ? _self.feeAmount : feeAmount // ignore: cast_nullable_to_non_nullable
as int,feeApplied: null == feeApplied ? _self.feeApplied : feeApplied // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
