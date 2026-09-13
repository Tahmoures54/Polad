// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Loan {

/// شناسه سند وام.
 String get loanId;/// صندوق پرداخت‌کننده.
 String get fundId;/// عضو درخواست‌کننده.
 String get memberId;/// مبلغ اصل وام به تومان.
 int get amount;/// تعداد اقساط بازپرداخت.
 int get installmentsCount;/// وضعیت پرونده وام.
 LoanStatus get status;/// نرخ هزینه اداری صندوق، مثلاً `0.02`.
 double get feeRate;/// زمان ثبت درخواست.
@IsoDateTimeConverter() DateTime get createdAt;
/// Create a copy of Loan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoanCopyWith<Loan> get copyWith => _$LoanCopyWithImpl<Loan>(this as Loan, _$identity);

  /// Serializes this Loan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Loan;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Loan&&(identical(other.loanId, _this.loanId) || other.loanId == _this.loanId)&&(identical(other.fundId, _this.fundId) || other.fundId == _this.fundId)&&(identical(other.memberId, _this.memberId) || other.memberId == _this.memberId)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.installmentsCount, _this.installmentsCount) || other.installmentsCount == _this.installmentsCount)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.feeRate, _this.feeRate) || other.feeRate == _this.feeRate)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Loan;
  return Object.hash(runtimeType,_this.loanId,_this.fundId,_this.memberId,_this.amount,_this.installmentsCount,_this.status,_this.feeRate,_this.createdAt);
}

@override
String toString() {
  final _this = this as Loan;
  return 'Loan(loanId: ${_this.loanId}, fundId: ${_this.fundId}, memberId: ${_this.memberId}, amount: ${_this.amount}, installmentsCount: ${_this.installmentsCount}, status: ${_this.status}, feeRate: ${_this.feeRate}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $LoanCopyWith<$Res>  {
  factory $LoanCopyWith(Loan value, $Res Function(Loan) _then) = _$LoanCopyWithImpl;
@useResult
$Res call({
 String loanId, String fundId, String memberId, int amount, int installmentsCount, LoanStatus status, double feeRate,@IsoDateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class _$LoanCopyWithImpl<$Res>
    implements $LoanCopyWith<$Res> {
  _$LoanCopyWithImpl(this._self, this._then);

  final Loan _self;
  final $Res Function(Loan) _then;

/// Create a copy of Loan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loanId = null,Object? fundId = null,Object? memberId = null,Object? amount = null,Object? installmentsCount = null,Object? status = null,Object? feeRate = null,Object? createdAt = null,}) {
  return _then(Loan(
loanId: null == loanId ? _self.loanId : loanId // ignore: cast_nullable_to_non_nullable
as String,fundId: null == fundId ? _self.fundId : fundId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,installmentsCount: null == installmentsCount ? _self.installmentsCount : installmentsCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoanStatus,feeRate: null == feeRate ? _self.feeRate : feeRate // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Loan].
extension LoanPatterns on Loan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Loan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Loan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Loan value)  $default,){
final _that = this;
switch (_that) {
case _Loan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Loan value)?  $default,){
final _that = this;
switch (_that) {
case _Loan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String loanId,  String fundId,  String memberId,  int amount,  int installmentsCount,  LoanStatus status,  double feeRate, @IsoDateTimeConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Loan() when $default != null:
return $default(_that.loanId,_that.fundId,_that.memberId,_that.amount,_that.installmentsCount,_that.status,_that.feeRate,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String loanId,  String fundId,  String memberId,  int amount,  int installmentsCount,  LoanStatus status,  double feeRate, @IsoDateTimeConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Loan():
return $default(_that.loanId,_that.fundId,_that.memberId,_that.amount,_that.installmentsCount,_that.status,_that.feeRate,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String loanId,  String fundId,  String memberId,  int amount,  int installmentsCount,  LoanStatus status,  double feeRate, @IsoDateTimeConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Loan() when $default != null:
return $default(_that.loanId,_that.fundId,_that.memberId,_that.amount,_that.installmentsCount,_that.status,_that.feeRate,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Loan implements Loan {
  const _Loan({required this.loanId, required this.fundId, required this.memberId, required this.amount, required this.installmentsCount, required this.status, required this.feeRate, @IsoDateTimeConverter() required this.createdAt});
  factory _Loan.fromJson(Map<String, dynamic> json) => _$LoanFromJson(json);

/// شناسه سند وام.
@override final  String loanId;
/// صندوق پرداخت‌کننده.
@override final  String fundId;
/// عضو درخواست‌کننده.
@override final  String memberId;
/// مبلغ اصل وام به تومان.
@override final  int amount;
/// تعداد اقساط بازپرداخت.
@override final  int installmentsCount;
/// وضعیت پرونده وام.
@override final  LoanStatus status;
/// نرخ هزینه اداری صندوق، مثلاً `0.02`.
@override final  double feeRate;
/// زمان ثبت درخواست.
@override@IsoDateTimeConverter() final  DateTime createdAt;

/// Create a copy of Loan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoanCopyWith<_Loan> get copyWith => __$LoanCopyWithImpl<_Loan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoanToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loan&&(identical(other.loanId, loanId) || other.loanId == loanId)&&(identical(other.fundId, fundId) || other.fundId == fundId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.installmentsCount, installmentsCount) || other.installmentsCount == installmentsCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.feeRate, feeRate) || other.feeRate == feeRate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,loanId,fundId,memberId,amount,installmentsCount,status,feeRate,createdAt);
}

@override
String toString() {
    return 'Loan(loanId: $loanId, fundId: $fundId, memberId: $memberId, amount: $amount, installmentsCount: $installmentsCount, status: $status, feeRate: $feeRate, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$LoanCopyWith<$Res> implements $LoanCopyWith<$Res> {
  factory _$LoanCopyWith(_Loan value, $Res Function(_Loan) _then) = __$LoanCopyWithImpl;
@override @useResult
$Res call({
 String loanId, String fundId, String memberId, int amount, int installmentsCount, LoanStatus status, double feeRate,@IsoDateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class __$LoanCopyWithImpl<$Res>
    implements _$LoanCopyWith<$Res> {
  __$LoanCopyWithImpl(this._self, this._then);

  final _Loan _self;
  final $Res Function(_Loan) _then;

/// Create a copy of Loan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loanId = null,Object? fundId = null,Object? memberId = null,Object? amount = null,Object? installmentsCount = null,Object? status = null,Object? feeRate = null,Object? createdAt = null,}) {
  return _then(_Loan(
loanId: null == loanId ? _self.loanId : loanId // ignore: cast_nullable_to_non_nullable
as String,fundId: null == fundId ? _self.fundId : fundId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,installmentsCount: null == installmentsCount ? _self.installmentsCount : installmentsCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoanStatus,feeRate: null == feeRate ? _self.feeRate : feeRate // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
