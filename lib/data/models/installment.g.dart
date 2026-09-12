// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'installment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Installment _$InstallmentFromJson(Map<String, dynamic> json) => _Installment(
  installmentId: json['installmentId'] as String,
  loanId: json['loanId'] as String,
  memberId: json['memberId'] as String,
  amount: (json['amount'] as num).toInt(),
  dueDate: const IsoDateTimeConverter().fromJson(json['dueDate']),
  status: $enumDecode(_$InstallmentStatusEnumMap, json['status']),
);

Map<String, dynamic> _$InstallmentToJson(_Installment instance) =>
    <String, dynamic>{
      'installmentId': instance.installmentId,
      'loanId': instance.loanId,
      'memberId': instance.memberId,
      'amount': instance.amount,
      'dueDate': ?const IsoDateTimeConverter().toJson(instance.dueDate),
      'status': _$InstallmentStatusEnumMap[instance.status]!,
    };

const _$InstallmentStatusEnumMap = {
  InstallmentStatus.pending: 'pending',
  InstallmentStatus.paid: 'paid',
  InstallmentStatus.overdue: 'overdue',
};
