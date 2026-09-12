// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draw.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Draw _$DrawFromJson(Map<String, dynamic> json) => _Draw(
  drawId: json['drawId'] as String,
  fundId: json['fundId'] as String,
  period: json['period'] as String,
  winnerId: json['winnerId'] as String?,
  drawnAt: const NullableIsoDateTimeConverter().fromJson(json['drawnAt']),
  method: $enumDecode(_$DrawMethodEnumMap, json['method']),
);

Map<String, dynamic> _$DrawToJson(_Draw instance) => <String, dynamic>{
  'drawId': instance.drawId,
  'fundId': instance.fundId,
  'period': instance.period,
  'winnerId': ?instance.winnerId,
  'drawnAt': ?const NullableIsoDateTimeConverter().toJson(instance.drawnAt),
  'method': _$DrawMethodEnumMap[instance.method]!,
};

const _$DrawMethodEnumMap = {
  DrawMethod.random: 'random',
  DrawMethod.manual: 'manual',
};
