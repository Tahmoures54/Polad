// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fee.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Fee {

/// شناسه سند صورتحساب.
 String get feeId;/// صندوق مشمول.
 String get fundId;/// کلید ماه دوره، ترجیحاً شمسی مثل `1404-06`.
 String get month;/// جمع هزینه خدمات آن ماه به تومان.
 int get totalAmount;/// وضعیت تسویه توسط مدیر.
 FeeStatus get status;/// زمان پرداخت صورتحساب — فقط وقتی [status] برابر paid است.
@NullableIsoDateTimeConverter() DateTime? get paidAt;
/// Create a copy of Fee
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeeCopyWith<Fee> get copyWith => _$FeeCopyWithImpl<Fee>(this as Fee, _$identity);

  /// Serializes this Fee to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Fee;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Fee&&(identical(other.feeId, _this.feeId) || other.feeId == _this.feeId)&&(identical(other.fundId, _this.fundId) || other.fundId == _this.fundId)&&(identical(other.month, _this.month) || other.month == _this.month)&&(identical(other.totalAmount, _this.totalAmount) || other.totalAmount == _this.totalAmount)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.paidAt, _this.paidAt) || other.paidAt == _this.paidAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Fee;
  return Object.hash(runtimeType,_this.feeId,_this.fundId,_this.month,_this.totalAmount,_this.status,_this.paidAt);
}

@override
String toString() {
  final _this = this as Fee;
  return 'Fee(feeId: ${_this.feeId}, fundId: ${_this.fundId}, month: ${_this.month}, totalAmount: ${_this.totalAmount}, status: ${_this.status}, paidAt: ${_this.paidAt})';
}


}

/// @nodoc
abstract mixin class $FeeCopyWith<$Res>  {
  factory $FeeCopyWith(Fee value, $Res Function(Fee) _then) = _$FeeCopyWithImpl;
@useResult
$Res call({
 String feeId, String fundId, String month, int totalAmount, FeeStatus status,@NullableIsoDateTimeConverter() DateTime? paidAt
});




}
/// @nodoc
class _$FeeCopyWithImpl<$Res>
    implements $FeeCopyWith<$Res> {
  _$FeeCopyWithImpl(this._self, this._then);

  final Fee _self;
  final $Res Function(Fee) _then;

/// Create a copy of Fee
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? feeId = null,Object? fundId = null,Object? month = null,Object? totalAmount = null,Object? status = null,Object? paidAt = freezed,}) {
  return _then(Fee(
feeId: null == feeId ? _self.feeId : feeId // ignore: cast_nullable_to_non_nullable
as String,fundId: null == fundId ? _self.fundId : fundId // ignore: cast_nullable_to_non_nullable
as String,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FeeStatus,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Fee].
extension FeePatterns on Fee {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Fee value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Fee() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Fee value)  $default,){
final _that = this;
switch (_that) {
case _Fee():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Fee value)?  $default,){
final _that = this;
switch (_that) {
case _Fee() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String feeId,  String fundId,  String month,  int totalAmount,  FeeStatus status, @NullableIsoDateTimeConverter()  DateTime? paidAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Fee() when $default != null:
return $default(_that.feeId,_that.fundId,_that.month,_that.totalAmount,_that.status,_that.paidAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String feeId,  String fundId,  String month,  int totalAmount,  FeeStatus status, @NullableIsoDateTimeConverter()  DateTime? paidAt)  $default,) {final _that = this;
switch (_that) {
case _Fee():
return $default(_that.feeId,_that.fundId,_that.month,_that.totalAmount,_that.status,_that.paidAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String feeId,  String fundId,  String month,  int totalAmount,  FeeStatus status, @NullableIsoDateTimeConverter()  DateTime? paidAt)?  $default,) {final _that = this;
switch (_that) {
case _Fee() when $default != null:
return $default(_that.feeId,_that.fundId,_that.month,_that.totalAmount,_that.status,_that.paidAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Fee implements Fee {
  const _Fee({required this.feeId, required this.fundId, required this.month, required this.totalAmount, required this.status, @NullableIsoDateTimeConverter() this.paidAt});
  factory _Fee.fromJson(Map<String, dynamic> json) => _$FeeFromJson(json);

/// شناسه سند صورتحساب.
@override final  String feeId;
/// صندوق مشمول.
@override final  String fundId;
/// کلید ماه دوره، ترجیحاً شمسی مثل `1404-06`.
@override final  String month;
/// جمع هزینه خدمات آن ماه به تومان.
@override final  int totalAmount;
/// وضعیت تسویه توسط مدیر.
@override final  FeeStatus status;
/// زمان پرداخت صورتحساب — فقط وقتی [status] برابر paid است.
@override@NullableIsoDateTimeConverter() final  DateTime? paidAt;

/// Create a copy of Fee
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeeCopyWith<_Fee> get copyWith => __$FeeCopyWithImpl<_Fee>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Fee&&(identical(other.feeId, feeId) || other.feeId == feeId)&&(identical(other.fundId, fundId) || other.fundId == fundId)&&(identical(other.month, month) || other.month == month)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,feeId,fundId,month,totalAmount,status,paidAt);
}

@override
String toString() {
    return 'Fee(feeId: $feeId, fundId: $fundId, month: $month, totalAmount: $totalAmount, status: $status, paidAt: $paidAt)';
}


}

/// @nodoc
abstract mixin class _$FeeCopyWith<$Res> implements $FeeCopyWith<$Res> {
  factory _$FeeCopyWith(_Fee value, $Res Function(_Fee) _then) = __$FeeCopyWithImpl;
@override @useResult
$Res call({
 String feeId, String fundId, String month, int totalAmount, FeeStatus status,@NullableIsoDateTimeConverter() DateTime? paidAt
});




}
/// @nodoc
class __$FeeCopyWithImpl<$Res>
    implements _$FeeCopyWith<$Res> {
  __$FeeCopyWithImpl(this._self, this._then);

  final _Fee _self;
  final $Res Function(_Fee) _then;

/// Create a copy of Fee
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? feeId = null,Object? fundId = null,Object? month = null,Object? totalAmount = null,Object? status = null,Object? paidAt = freezed,}) {
  return _then(_Fee(
feeId: null == feeId ? _self.feeId : feeId // ignore: cast_nullable_to_non_nullable
as String,fundId: null == fundId ? _self.fundId : fundId // ignore: cast_nullable_to_non_nullable
as String,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FeeStatus,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
