// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fund.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Fund {

/// شناسه سند صندوق در Firestore.
 String get fundId;/// نام قابل‌نمایش صندوق برای اعضا.
 String get name;/// uid مدیر/مالک صندوق.
 String get ownerId;/// مبلغ سهم دوره‌ای به تومان.
 int get shareAmount;/// نوع دوره پرداخت سهم.
 FundPeriodType get periodType;/// نرخ هزینه خدمات نرم‌افزاری مدیر، مثلاً `0.005` برای ۰٫۵٪.
 double get feeRate;/// زمان ایجاد صندوق.
@IsoDateTimeConverter() DateTime get createdAt;
/// Create a copy of Fund
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FundCopyWith<Fund> get copyWith => _$FundCopyWithImpl<Fund>(this as Fund, _$identity);

  /// Serializes this Fund to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Fund;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Fund&&(identical(other.fundId, _this.fundId) || other.fundId == _this.fundId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.ownerId, _this.ownerId) || other.ownerId == _this.ownerId)&&(identical(other.shareAmount, _this.shareAmount) || other.shareAmount == _this.shareAmount)&&(identical(other.periodType, _this.periodType) || other.periodType == _this.periodType)&&(identical(other.feeRate, _this.feeRate) || other.feeRate == _this.feeRate)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Fund;
  return Object.hash(runtimeType,_this.fundId,_this.name,_this.ownerId,_this.shareAmount,_this.periodType,_this.feeRate,_this.createdAt);
}

@override
String toString() {
  final _this = this as Fund;
  return 'Fund(fundId: ${_this.fundId}, name: ${_this.name}, ownerId: ${_this.ownerId}, shareAmount: ${_this.shareAmount}, periodType: ${_this.periodType}, feeRate: ${_this.feeRate}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $FundCopyWith<$Res>  {
  factory $FundCopyWith(Fund value, $Res Function(Fund) _then) = _$FundCopyWithImpl;
@useResult
$Res call({
 String fundId, String name, String ownerId, int shareAmount, FundPeriodType periodType, double feeRate,@IsoDateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class _$FundCopyWithImpl<$Res>
    implements $FundCopyWith<$Res> {
  _$FundCopyWithImpl(this._self, this._then);

  final Fund _self;
  final $Res Function(Fund) _then;

/// Create a copy of Fund
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fundId = null,Object? name = null,Object? ownerId = null,Object? shareAmount = null,Object? periodType = null,Object? feeRate = null,Object? createdAt = null,}) {
  return _then(Fund(
fundId: null == fundId ? _self.fundId : fundId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,shareAmount: null == shareAmount ? _self.shareAmount : shareAmount // ignore: cast_nullable_to_non_nullable
as int,periodType: null == periodType ? _self.periodType : periodType // ignore: cast_nullable_to_non_nullable
as FundPeriodType,feeRate: null == feeRate ? _self.feeRate : feeRate // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Fund].
extension FundPatterns on Fund {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Fund value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Fund() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Fund value)  $default,){
final _that = this;
switch (_that) {
case _Fund():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Fund value)?  $default,){
final _that = this;
switch (_that) {
case _Fund() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fundId,  String name,  String ownerId,  int shareAmount,  FundPeriodType periodType,  double feeRate, @IsoDateTimeConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Fund() when $default != null:
return $default(_that.fundId,_that.name,_that.ownerId,_that.shareAmount,_that.periodType,_that.feeRate,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fundId,  String name,  String ownerId,  int shareAmount,  FundPeriodType periodType,  double feeRate, @IsoDateTimeConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Fund():
return $default(_that.fundId,_that.name,_that.ownerId,_that.shareAmount,_that.periodType,_that.feeRate,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fundId,  String name,  String ownerId,  int shareAmount,  FundPeriodType periodType,  double feeRate, @IsoDateTimeConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Fund() when $default != null:
return $default(_that.fundId,_that.name,_that.ownerId,_that.shareAmount,_that.periodType,_that.feeRate,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Fund implements Fund {
  const _Fund({required this.fundId, required this.name, required this.ownerId, required this.shareAmount, required this.periodType, required this.feeRate, @IsoDateTimeConverter() required this.createdAt});
  factory _Fund.fromJson(Map<String, dynamic> json) => _$FundFromJson(json);

/// شناسه سند صندوق در Firestore.
@override final  String fundId;
/// نام قابل‌نمایش صندوق برای اعضا.
@override final  String name;
/// uid مدیر/مالک صندوق.
@override final  String ownerId;
/// مبلغ سهم دوره‌ای به تومان.
@override final  int shareAmount;
/// نوع دوره پرداخت سهم.
@override final  FundPeriodType periodType;
/// نرخ هزینه خدمات نرم‌افزاری مدیر، مثلاً `0.005` برای ۰٫۵٪.
@override final  double feeRate;
/// زمان ایجاد صندوق.
@override@IsoDateTimeConverter() final  DateTime createdAt;

/// Create a copy of Fund
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FundCopyWith<_Fund> get copyWith => __$FundCopyWithImpl<_Fund>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FundToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Fund&&(identical(other.fundId, fundId) || other.fundId == fundId)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.shareAmount, shareAmount) || other.shareAmount == shareAmount)&&(identical(other.periodType, periodType) || other.periodType == periodType)&&(identical(other.feeRate, feeRate) || other.feeRate == feeRate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,fundId,name,ownerId,shareAmount,periodType,feeRate,createdAt);
}

@override
String toString() {
    return 'Fund(fundId: $fundId, name: $name, ownerId: $ownerId, shareAmount: $shareAmount, periodType: $periodType, feeRate: $feeRate, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FundCopyWith<$Res> implements $FundCopyWith<$Res> {
  factory _$FundCopyWith(_Fund value, $Res Function(_Fund) _then) = __$FundCopyWithImpl;
@override @useResult
$Res call({
 String fundId, String name, String ownerId, int shareAmount, FundPeriodType periodType, double feeRate,@IsoDateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class __$FundCopyWithImpl<$Res>
    implements _$FundCopyWith<$Res> {
  __$FundCopyWithImpl(this._self, this._then);

  final _Fund _self;
  final $Res Function(_Fund) _then;

/// Create a copy of Fund
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fundId = null,Object? name = null,Object? ownerId = null,Object? shareAmount = null,Object? periodType = null,Object? feeRate = null,Object? createdAt = null,}) {
  return _then(_Fund(
fundId: null == fundId ? _self.fundId : fundId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,shareAmount: null == shareAmount ? _self.shareAmount : shareAmount // ignore: cast_nullable_to_non_nullable
as int,periodType: null == periodType ? _self.periodType : periodType // ignore: cast_nullable_to_non_nullable
as FundPeriodType,feeRate: null == feeRate ? _self.feeRate : feeRate // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
