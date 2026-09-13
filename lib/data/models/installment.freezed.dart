// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'installment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Installment {

/// شناسه سند قسط.
 String get installmentId;/// وام والد.
 String get loanId;/// عضو بدهکار.
 String get memberId;/// مبلغ این قسط به تومان.
 int get amount;/// تاریخ سررسید.
@IsoDateTimeConverter() DateTime get dueDate;/// وضعیت پرداخت نسبت به سررسید.
 InstallmentStatus get status;
/// Create a copy of Installment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InstallmentCopyWith<Installment> get copyWith => _$InstallmentCopyWithImpl<Installment>(this as Installment, _$identity);

  /// Serializes this Installment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Installment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Installment&&(identical(other.installmentId, _this.installmentId) || other.installmentId == _this.installmentId)&&(identical(other.loanId, _this.loanId) || other.loanId == _this.loanId)&&(identical(other.memberId, _this.memberId) || other.memberId == _this.memberId)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Installment;
  return Object.hash(runtimeType,_this.installmentId,_this.loanId,_this.memberId,_this.amount,_this.dueDate,_this.status);
}

@override
String toString() {
  final _this = this as Installment;
  return 'Installment(installmentId: ${_this.installmentId}, loanId: ${_this.loanId}, memberId: ${_this.memberId}, amount: ${_this.amount}, dueDate: ${_this.dueDate}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $InstallmentCopyWith<$Res>  {
  factory $InstallmentCopyWith(Installment value, $Res Function(Installment) _then) = _$InstallmentCopyWithImpl;
@useResult
$Res call({
 String installmentId, String loanId, String memberId, int amount,@IsoDateTimeConverter() DateTime dueDate, InstallmentStatus status
});




}
/// @nodoc
class _$InstallmentCopyWithImpl<$Res>
    implements $InstallmentCopyWith<$Res> {
  _$InstallmentCopyWithImpl(this._self, this._then);

  final Installment _self;
  final $Res Function(Installment) _then;

/// Create a copy of Installment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? installmentId = null,Object? loanId = null,Object? memberId = null,Object? amount = null,Object? dueDate = null,Object? status = null,}) {
  return _then(Installment(
installmentId: null == installmentId ? _self.installmentId : installmentId // ignore: cast_nullable_to_non_nullable
as String,loanId: null == loanId ? _self.loanId : loanId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InstallmentStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [Installment].
extension InstallmentPatterns on Installment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Installment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Installment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Installment value)  $default,){
final _that = this;
switch (_that) {
case _Installment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Installment value)?  $default,){
final _that = this;
switch (_that) {
case _Installment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String installmentId,  String loanId,  String memberId,  int amount, @IsoDateTimeConverter()  DateTime dueDate,  InstallmentStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Installment() when $default != null:
return $default(_that.installmentId,_that.loanId,_that.memberId,_that.amount,_that.dueDate,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String installmentId,  String loanId,  String memberId,  int amount, @IsoDateTimeConverter()  DateTime dueDate,  InstallmentStatus status)  $default,) {final _that = this;
switch (_that) {
case _Installment():
return $default(_that.installmentId,_that.loanId,_that.memberId,_that.amount,_that.dueDate,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String installmentId,  String loanId,  String memberId,  int amount, @IsoDateTimeConverter()  DateTime dueDate,  InstallmentStatus status)?  $default,) {final _that = this;
switch (_that) {
case _Installment() when $default != null:
return $default(_that.installmentId,_that.loanId,_that.memberId,_that.amount,_that.dueDate,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Installment implements Installment {
  const _Installment({required this.installmentId, required this.loanId, required this.memberId, required this.amount, @IsoDateTimeConverter() required this.dueDate, required this.status});
  factory _Installment.fromJson(Map<String, dynamic> json) => _$InstallmentFromJson(json);

/// شناسه سند قسط.
@override final  String installmentId;
/// وام والد.
@override final  String loanId;
/// عضو بدهکار.
@override final  String memberId;
/// مبلغ این قسط به تومان.
@override final  int amount;
/// تاریخ سررسید.
@override@IsoDateTimeConverter() final  DateTime dueDate;
/// وضعیت پرداخت نسبت به سررسید.
@override final  InstallmentStatus status;

/// Create a copy of Installment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InstallmentCopyWith<_Installment> get copyWith => __$InstallmentCopyWithImpl<_Installment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InstallmentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Installment&&(identical(other.installmentId, installmentId) || other.installmentId == installmentId)&&(identical(other.loanId, loanId) || other.loanId == loanId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,installmentId,loanId,memberId,amount,dueDate,status);
}

@override
String toString() {
    return 'Installment(installmentId: $installmentId, loanId: $loanId, memberId: $memberId, amount: $amount, dueDate: $dueDate, status: $status)';
}


}

/// @nodoc
abstract mixin class _$InstallmentCopyWith<$Res> implements $InstallmentCopyWith<$Res> {
  factory _$InstallmentCopyWith(_Installment value, $Res Function(_Installment) _then) = __$InstallmentCopyWithImpl;
@override @useResult
$Res call({
 String installmentId, String loanId, String memberId, int amount,@IsoDateTimeConverter() DateTime dueDate, InstallmentStatus status
});




}
/// @nodoc
class __$InstallmentCopyWithImpl<$Res>
    implements _$InstallmentCopyWith<$Res> {
  __$InstallmentCopyWithImpl(this._self, this._then);

  final _Installment _self;
  final $Res Function(_Installment) _then;

/// Create a copy of Installment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? installmentId = null,Object? loanId = null,Object? memberId = null,Object? amount = null,Object? dueDate = null,Object? status = null,}) {
  return _then(_Installment(
installmentId: null == installmentId ? _self.installmentId : installmentId // ignore: cast_nullable_to_non_nullable
as String,loanId: null == loanId ? _self.loanId : loanId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InstallmentStatus,
  ));
}


}

// dart format on
