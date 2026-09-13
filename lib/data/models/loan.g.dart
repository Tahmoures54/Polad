// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Loan _$LoanFromJson(Map<String, dynamic> json) => _Loan(
  loanId: json['loanId'] as String,
  fundId: json['fundId'] as String,
  memberId: json['memberId'] as String,
  amount: (json['amount'] as num).toInt(),
  installmentsCount: (json['installmentsCount'] as num).toInt(),
  status: $enumDecode(_$LoanStatusEnumMap, json['status']),
  feeRate: (json['feeRate'] as num).toDouble(),
  createdAt: const IsoDateTimeConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$LoanToJson(_Loan instance) => <String, dynamic>{
  'loanId': instance.loanId,
  'fundId': instance.fundId,
  'memberId': instance.memberId,
  'amount': instance.amount,
  'installmentsCount': instance.installmentsCount,
  'status': _$LoanStatusEnumMap[instance.status]!,
  'feeRate': instance.feeRate,
  'createdAt': ?const IsoDateTimeConverter().toJson(instance.createdAt),
};

const _$LoanStatusEnumMap = {
  LoanStatus.pending: 'pending',
  LoanStatus.approved: 'approved',
  LoanStatus.rejected: 'rejected',
  LoanStatus.active: 'active',
  LoanStatus.completed: 'completed',
};
