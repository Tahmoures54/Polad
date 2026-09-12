// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fund.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Fund _$FundFromJson(Map<String, dynamic> json) => _Fund(
  fundId: json['fundId'] as String,
  name: json['name'] as String,
  ownerId: json['ownerId'] as String,
  shareAmount: (json['shareAmount'] as num).toInt(),
  periodType: $enumDecode(_$FundPeriodTypeEnumMap, json['periodType']),
  feeRate: (json['feeRate'] as num).toDouble(),
  createdAt: const IsoDateTimeConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$FundToJson(_Fund instance) => <String, dynamic>{
  'fundId': instance.fundId,
  'name': instance.name,
  'ownerId': instance.ownerId,
  'shareAmount': instance.shareAmount,
  'periodType': _$FundPeriodTypeEnumMap[instance.periodType]!,
  'feeRate': instance.feeRate,
  'createdAt': ?const IsoDateTimeConverter().toJson(instance.createdAt),
};

const _$FundPeriodTypeEnumMap = {
  FundPeriodType.weekly: 'weekly',
  FundPeriodType.monthly: 'monthly',
  FundPeriodType.custom: 'custom',
};
