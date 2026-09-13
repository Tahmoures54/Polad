// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Transaction _$TransactionFromJson(Map<String, dynamic> json) => _Transaction(
  transactionId: json['transactionId'] as String,
  fundId: json['fundId'] as String,
  memberId: json['memberId'] as String,
  amount: (json['amount'] as num).toInt(),
  receiptCode: json['receiptCode'] as String?,
  date: const IsoDateTimeConverter().fromJson(json['date']),
  status: $enumDecode(_$TransactionStatusEnumMap, json['status']),
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  receiptImageUrl: json['receiptImageUrl'] as String?,
  submittedAt: const IsoDateTimeConverter().fromJson(json['submittedAt']),
  approvedBy: json['approvedBy'] as String?,
  approvedAt: const NullableIsoDateTimeConverter().fromJson(json['approvedAt']),
  feeAmount: (json['feeAmount'] as num?)?.toInt() ?? 0,
  feeApplied: json['feeApplied'] as bool? ?? false,
);

Map<String, dynamic> _$TransactionToJson(_Transaction instance) =>
    <String, dynamic>{
      'transactionId': instance.transactionId,
      'fundId': instance.fundId,
      'memberId': instance.memberId,
      'amount': instance.amount,
      'receiptCode': ?instance.receiptCode,
      'date': ?const IsoDateTimeConverter().toJson(instance.date),
      'status': _$TransactionStatusEnumMap[instance.status]!,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'receiptImageUrl': ?instance.receiptImageUrl,
      'submittedAt': ?const IsoDateTimeConverter().toJson(instance.submittedAt),
      'approvedBy': ?instance.approvedBy,
      'approvedAt': ?const NullableIsoDateTimeConverter().toJson(
        instance.approvedAt,
      ),
      'feeAmount': instance.feeAmount,
      'feeApplied': instance.feeApplied,
    };

const _$TransactionStatusEnumMap = {
  TransactionStatus.pendingApproval: 'pending_approval',
  TransactionStatus.approved: 'approved',
  TransactionStatus.rejected: 'rejected',
};

const _$TransactionTypeEnumMap = {
  TransactionType.installment: 'installment',
  TransactionType.loan: 'loan',
  TransactionType.withdrawal: 'withdrawal',
  TransactionType.fee: 'fee',
};
