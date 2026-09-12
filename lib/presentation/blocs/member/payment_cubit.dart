import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/locator.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/models.dart' as models;
import '../../../data/services/firestore_service.dart';
import '../../../domain/entities/finance.dart';
import '../../../domain/enums.dart';
import '../../../domain/repositories/repositories.dart';

class PaymentFormState extends Equatable {
  const PaymentFormState({
    this.amountText = '',
    this.tracking = '',
    this.occurredAt,
    this.receiptPath,
    this.installmentId,
    this.type = TransactionType.sharePayment,
    this.submitted = false,
    this.busy = false,
    this.error,
    this.success = false,
    this.created,
  });

  final String amountText;
  final String tracking;
  final DateTime? occurredAt;
  final String? receiptPath;
  final String? installmentId;
  final TransactionType type;
  final bool submitted;
  final bool busy;
  final String? error;
  final bool success;
  final MoneyTransaction? created;

  DateTime get date => occurredAt ?? DateTime.now();

  String? get amountError {
    if (!submitted && amountText.isEmpty) return null;
    return Validators.amount(amountText);
  }

  String? get trackingError {
    if (!submitted && tracking.isEmpty) return null;
    return Validators.trackingCode(tracking);
  }

  PaymentFormState copyWith({
    String? amountText,
    String? tracking,
    DateTime? occurredAt,
    String? receiptPath,
    String? installmentId,
    TransactionType? type,
    bool? submitted,
    bool? busy,
    String? error,
    bool? success,
    MoneyTransaction? created,
    bool clearError = false,
    bool clearReceipt = false,
  }) {
    return PaymentFormState(
      amountText: amountText ?? this.amountText,
      tracking: tracking ?? this.tracking,
      occurredAt: occurredAt ?? this.occurredAt,
      receiptPath: clearReceipt ? null : (receiptPath ?? this.receiptPath),
      installmentId: installmentId ?? this.installmentId,
      type: type ?? this.type,
      submitted: submitted ?? this.submitted,
      busy: busy ?? this.busy,
      error: clearError ? null : (error ?? this.error),
      success: success ?? this.success,
      created: created ?? this.created,
    );
  }

  @override
  List<Object?> get props => [
        amountText,
        tracking,
        occurredAt,
        receiptPath,
        installmentId,
        type,
        submitted,
        busy,
        error,
        success,
        created,
      ];
}

/// ثبت پرداخت عضو؛ سند نهایی در Firestore با `pending_approval` ذخیره می‌شود.
class PaymentCubit extends Cubit<PaymentFormState> {
  PaymentCubit({
    String? installmentId,
    int? presetAmount,
    TransactionRepository? txs,
    FirestoreService? firestore,
    bool resolveFirestore = true,
  })  : _txs = txs ?? sl<TransactionRepository>(),
        _firestore = firestore ??
            (resolveFirestore && sl.isRegistered<FirestoreService>() ? sl<FirestoreService>() : null),
        super(
          PaymentFormState(
            installmentId: installmentId,
            type: installmentId == null
                ? TransactionType.sharePayment
                : TransactionType.installmentPayment,
            amountText: presetAmount?.toString() ?? '',
            occurredAt: DateTime.now(),
          ),
        );

  final TransactionRepository _txs;
  final FirestoreService? _firestore;

  void amountChanged(String value) =>
      emit(state.copyWith(amountText: value, success: false, clearError: true));

  void trackingChanged(String value) =>
      emit(state.copyWith(tracking: value, success: false, clearError: true));

  void dateChanged(DateTime value) => emit(state.copyWith(occurredAt: value, success: false));

  void typeChanged(TransactionType type) => emit(state.copyWith(type: type));

  void receiptPicked(String? path) =>
      emit(state.copyWith(receiptPath: path, clearReceipt: path == null, success: false));

  Future<void> submit() async {
    emit(state.copyWith(submitted: true, clearError: true));
    if (Validators.amount(state.amountText) != null || Validators.trackingCode(state.tracking) != null) {
      return;
    }
    final amount = Validators.parseAmount(state.amountText);
    if (amount == null) return;
    emit(state.copyWith(busy: true));
    final res = await _txs.submit(
      SubmitPaymentInput(
        amount: amount,
        occurredAt: state.date,
        trackingCode: Validators.toEnglishDigits(state.tracking).trim(),
        type: state.type,
        receiptPath: state.receiptPath,
        relatedInstallmentId: state.installmentId,
      ),
    );
    await res.when(
      ok: (tx) async {
        await _writePendingApproval(tx);
        emit(state.copyWith(busy: false, success: true, created: tx));
      },
      err: (m) async => emit(state.copyWith(busy: false, error: m)),
    );
  }

  /// مدل Freezed نوع «سهم» جدا ندارد؛ ورود پول به صندوق به‌صورت installment ذخیره می‌شود.
  models.TransactionType _modelType(TransactionType type) => switch (type) {
        TransactionType.sharePayment => models.TransactionType.installment,
        TransactionType.installmentPayment => models.TransactionType.installment,
        TransactionType.loanDisbursement => models.TransactionType.loan,
        TransactionType.withdrawal => models.TransactionType.withdrawal,
        TransactionType.adjustment => models.TransactionType.fee,
      };

  /// لایهٔ Freezed را با وضعیت رسمی `pending_approval` به‌روز می‌کند.
  Future<void> _writePendingApproval(MoneyTransaction tx) async {
    final db = _firestore;
    if (db == null) return;
    await db.upsertTransaction(
      models.Transaction(
        transactionId: tx.id,
        fundId: tx.fundId,
        memberId: tx.memberId,
        amount: tx.amount,
        receiptCode: tx.trackingCode,
        date: tx.occurredAt,
        status: models.TransactionStatus.pendingApproval,
        type: _modelType(tx.type),
        receiptImageUrl: tx.receiptUrl,
        submittedAt: tx.submittedAt,
      ),
    );
  }
}
