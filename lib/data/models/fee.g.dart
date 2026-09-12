// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Fee _$FeeFromJson(Map<String, dynamic> json) => _Fee(
  feeId: json['feeId'] as String,
  fundId: json['fundId'] as String,
  month: json['month'] as String,
  totalAmount: (json['totalAmount'] as num).toInt(),
  status: $enumDecode(_$FeeStatusEnumMap, json['status']),
  paidAt: const NullableIsoDateTimeConverter().fromJson(json['paidAt']),
);

Map<String, dynamic> _$FeeToJson(_Fee instance) => <String, dynamic>{
  'feeId': instance.feeId,
  'fundId': instance.fundId,
  'month': instance.month,
  'totalAmount': instance.totalAmount,
  'status': _$FeeStatusEnumMap[instance.status]!,
  'paidAt': ?const NullableIsoDateTimeConverter().toJson(instance.paidAt),
};

const _$FeeStatusEnumMap = {
  FeeStatus.pending: 'pending',
  FeeStatus.paid: 'paid',
};
