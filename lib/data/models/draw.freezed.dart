// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draw.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Draw {

/// شناسه سند قرعه‌کشی.
 String get drawId;/// صندوق برگزارکننده.
 String get fundId;/// شناسه دوره (مثلاً سال-ماه شمسی).
 String get period;/// برنده — پس از اجرا پر می‌شود.
 String? get winnerId;/// زمان انجام قرعه.
@NullableIsoDateTimeConverter() DateTime? get drawnAt;/// روش انتخاب برنده.
 DrawMethod get method;
/// Create a copy of Draw
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DrawCopyWith<Draw> get copyWith => _$DrawCopyWithImpl<Draw>(this as Draw, _$identity);

  /// Serializes this Draw to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Draw;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Draw&&(identical(other.drawId, _this.drawId) || other.drawId == _this.drawId)&&(identical(other.fundId, _this.fundId) || other.fundId == _this.fundId)&&(identical(other.period, _this.period) || other.period == _this.period)&&(identical(other.winnerId, _this.winnerId) || other.winnerId == _this.winnerId)&&(identical(other.drawnAt, _this.drawnAt) || other.drawnAt == _this.drawnAt)&&(identical(other.method, _this.method) || other.method == _this.method));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Draw;
  return Object.hash(runtimeType,_this.drawId,_this.fundId,_this.period,_this.winnerId,_this.drawnAt,_this.method);
}

@override
String toString() {
  final _this = this as Draw;
  return 'Draw(drawId: ${_this.drawId}, fundId: ${_this.fundId}, period: ${_this.period}, winnerId: ${_this.winnerId}, drawnAt: ${_this.drawnAt}, method: ${_this.method})';
}


}

/// @nodoc
abstract mixin class $DrawCopyWith<$Res>  {
  factory $DrawCopyWith(Draw value, $Res Function(Draw) _then) = _$DrawCopyWithImpl;
@useResult
$Res call({
 String drawId, String fundId, String period, String? winnerId,@NullableIsoDateTimeConverter() DateTime? drawnAt, DrawMethod method
});




}
/// @nodoc
class _$DrawCopyWithImpl<$Res>
    implements $DrawCopyWith<$Res> {
  _$DrawCopyWithImpl(this._self, this._then);

  final Draw _self;
  final $Res Function(Draw) _then;

/// Create a copy of Draw
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? drawId = null,Object? fundId = null,Object? period = null,Object? winnerId = freezed,Object? drawnAt = freezed,Object? method = null,}) {
  return _then(Draw(
drawId: null == drawId ? _self.drawId : drawId // ignore: cast_nullable_to_non_nullable
as String,fundId: null == fundId ? _self.fundId : fundId // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,drawnAt: freezed == drawnAt ? _self.drawnAt : drawnAt // ignore: cast_nullable_to_non_nullable
as DateTime?,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as DrawMethod,
  ));
}

}


/// Adds pattern-matching-related methods to [Draw].
extension DrawPatterns on Draw {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Draw value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Draw() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Draw value)  $default,){
final _that = this;
switch (_that) {
case _Draw():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Draw value)?  $default,){
final _that = this;
switch (_that) {
case _Draw() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String drawId,  String fundId,  String period,  String? winnerId, @NullableIsoDateTimeConverter()  DateTime? drawnAt,  DrawMethod method)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Draw() when $default != null:
return $default(_that.drawId,_that.fundId,_that.period,_that.winnerId,_that.drawnAt,_that.method);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String drawId,  String fundId,  String period,  String? winnerId, @NullableIsoDateTimeConverter()  DateTime? drawnAt,  DrawMethod method)  $default,) {final _that = this;
switch (_that) {
case _Draw():
return $default(_that.drawId,_that.fundId,_that.period,_that.winnerId,_that.drawnAt,_that.method);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String drawId,  String fundId,  String period,  String? winnerId, @NullableIsoDateTimeConverter()  DateTime? drawnAt,  DrawMethod method)?  $default,) {final _that = this;
switch (_that) {
case _Draw() when $default != null:
return $default(_that.drawId,_that.fundId,_that.period,_that.winnerId,_that.drawnAt,_that.method);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Draw implements Draw {
  const _Draw({required this.drawId, required this.fundId, required this.period, this.winnerId, @NullableIsoDateTimeConverter() this.drawnAt, required this.method});
  factory _Draw.fromJson(Map<String, dynamic> json) => _$DrawFromJson(json);

/// شناسه سند قرعه‌کشی.
@override final  String drawId;
/// صندوق برگزارکننده.
@override final  String fundId;
/// شناسه دوره (مثلاً سال-ماه شمسی).
@override final  String period;
/// برنده — پس از اجرا پر می‌شود.
@override final  String? winnerId;
/// زمان انجام قرعه.
@override@NullableIsoDateTimeConverter() final  DateTime? drawnAt;
/// روش انتخاب برنده.
@override final  DrawMethod method;

/// Create a copy of Draw
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DrawCopyWith<_Draw> get copyWith => __$DrawCopyWithImpl<_Draw>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DrawToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Draw&&(identical(other.drawId, drawId) || other.drawId == drawId)&&(identical(other.fundId, fundId) || other.fundId == fundId)&&(identical(other.period, period) || other.period == period)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.drawnAt, drawnAt) || other.drawnAt == drawnAt)&&(identical(other.method, method) || other.method == method));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,drawId,fundId,period,winnerId,drawnAt,method);
}

@override
String toString() {
    return 'Draw(drawId: $drawId, fundId: $fundId, period: $period, winnerId: $winnerId, drawnAt: $drawnAt, method: $method)';
}


}

/// @nodoc
abstract mixin class _$DrawCopyWith<$Res> implements $DrawCopyWith<$Res> {
  factory _$DrawCopyWith(_Draw value, $Res Function(_Draw) _then) = __$DrawCopyWithImpl;
@override @useResult
$Res call({
 String drawId, String fundId, String period, String? winnerId,@NullableIsoDateTimeConverter() DateTime? drawnAt, DrawMethod method
});




}
/// @nodoc
class __$DrawCopyWithImpl<$Res>
    implements _$DrawCopyWith<$Res> {
  __$DrawCopyWithImpl(this._self, this._then);

  final _Draw _self;
  final $Res Function(_Draw) _then;

/// Create a copy of Draw
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? drawId = null,Object? fundId = null,Object? period = null,Object? winnerId = freezed,Object? drawnAt = freezed,Object? method = null,}) {
  return _then(_Draw(
drawId: null == drawId ? _self.drawId : drawId // ignore: cast_nullable_to_non_nullable
as String,fundId: null == fundId ? _self.fundId : fundId // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,drawnAt: freezed == drawnAt ? _self.drawnAt : drawnAt // ignore: cast_nullable_to_non_nullable
as DateTime?,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as DrawMethod,
  ));
}


}

// dart format on
