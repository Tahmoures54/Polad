import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/app_result.dart';
import '../../core/error/failure.dart';
import '../../domain/entities/finance.dart';
import '../../domain/entities/people.dart';
import '../../domain/enums.dart';
import '../../domain/repositories/repositories.dart';
import 'bank_sms_parser.dart';

/// نتیجهٔ بررسی یک پیامک روی گوشی مدیر.
///
/// وضعیت صندوق هرگز اینجا به `approved` تغییر نمی‌کند.
enum SmsSuggestionKind {
  /// با تراکنش در صف تأیید هم‌خوان است — هنوز باید مدیر تأیید کند.
  matchedPending,

  /// پیامک جدید به‌عنوان پیشنهاد `pending_approval` ثبت شد.
  createdSuggestion,

  /// قبلاً با همین کد پیگیری ثبت شده بود.
  duplicate,

  /// پیامک بانکی نبود / برداشت بود / فیلد کم داشت.
  ignored,
}

class SmsSuggestion extends Equatable {
  const SmsSuggestion({
    required this.sms,
    required this.kind,
    this.transaction,
    this.message = '',
  });

  final BankSms sms;
  final SmsSuggestionKind kind;
  final MoneyTransaction? transaction;
  final String message;

  bool get awaitsAdmin =>
      kind == SmsSuggestionKind.matchedPending || kind == SmsSuggestionKind.createdSuggestion;

  @override
  List<Object?> get props => [sms, kind, transaction?.id, message];
}

class SmsIngestReport extends Equatable {
  const SmsIngestReport({
    required this.items,
    this.autoApproved = false,
  });

  final List<SmsSuggestion> items;

  /// همیشه `false`. فیلد فقط برای تست قرارداد «بدون تأیید خودکار» است.
  final bool autoApproved;

  int get createdCount => items.where((e) => e.kind == SmsSuggestionKind.createdSuggestion).length;
  int get matchedCount => items.where((e) => e.kind == SmsSuggestionKind.matchedPending).length;

  @override
  List<Object?> get props => [items, autoApproved];
}

/// خواندن پیامک بانکی مدیر، استخراج فیلدها، و ثبت پیشنهاد در صف انتظار.
///
/// **تأیید خودکار مطلقاً ممنوع است.** حتی اگر مبلغ و کد پیگیری کامل منطبق باشند.
class SmsParserService {
  SmsParserService({
    required this._inbox,
    required this._transactions,
    BankSmsParser? parser,
  }) : _parser = parser ?? BankSmsParser();

  final SmsInbox _inbox;
  final TransactionRepository _transactions;
  final BankSmsParser _parser;

  BankSmsParser get parser => _parser;

  Future<bool> requestPermission() => _inbox.requestPermission();

  Future<List<BankSms>> readRecent({Duration window = const Duration(days: 7)}) async {
    final raw = await _inbox.readRecent(window: window);
    return raw
        .map((s) => s.amount != null || s.trackingCode != null ? s : _parser.parse(s.sender, s.body, s.receivedAt))
        .toList();
  }

  /// اسکن اینباکس مدیر و ثبت پیشنهادهای جدید با وضعیت `pending_approval`.
  Future<AppResult<SmsIngestReport>> ingestAdminInbox({
    required bool isAdmin,
    required List<MoneyTransaction> existing,
    required List<FundMember> members,
    Duration window = const Duration(days: 7),
  }) async {
    if (!isAdmin) {
      return left(const PermissionFailure(message: 'فقط مدیر می‌تواند پیامک بانکی را بخواند'));
    }
    final permitted = await _inbox.requestPermission();
    if (!permitted) {
      return left(const PermissionFailure(message: 'دسترسی پیامک داده نشد. می‌توانید کد پیگیری را دستی وارد کنید.'));
    }
    final smsList = await readRecent(window: window);
    return ingestParsed(
      smsList: smsList,
      existing: existing,
      members: members,
    );
  }

  /// هستهٔ ثبت پیشنهاد؛ برای تست بدون اینباکس واقعی.
  Future<AppResult<SmsIngestReport>> ingestParsed({
    required List<BankSms> smsList,
    required List<MoneyTransaction> existing,
    required List<FundMember> members,
  }) async {
    final items = <SmsSuggestion>[];
    final known = [...existing];

    for (final sms in smsList) {
      final suggestion = await _handleOne(sms, known, members);
      items.add(suggestion);
      final tx = suggestion.transaction;
      if (suggestion.kind == SmsSuggestionKind.createdSuggestion && tx != null) {
        known.add(tx);
      }
    }

    return right(SmsIngestReport(items: items));
  }

  Future<SmsSuggestion> _handleOne(
    BankSms sms,
    List<MoneyTransaction> known,
    List<FundMember> members,
  ) async {
    if (sms.isCredit == false) {
      return SmsSuggestion(sms: sms, kind: SmsSuggestionKind.ignored, message: 'پیامک برداشت نادیده گرفته شد');
    }
    if (!sms.isParseable) {
      return SmsSuggestion(
        sms: sms,
        kind: SmsSuggestionKind.ignored,
        message: 'مبلغ یا کد پیگیری در پیامک ${sms.bank.fa} پیدا نشد',
      );
    }

    final duplicate = known.firstWhereOrNull(
      (t) => t.trackingCode != null && t.trackingCode == sms.trackingCode,
    );
    if (duplicate != null) {
      final pending = duplicate.status == TransactionStatus.pending;
      return SmsSuggestion(
        sms: sms,
        kind: pending ? SmsSuggestionKind.matchedPending : SmsSuggestionKind.duplicate,
        transaction: duplicate,
        message: pending
            ? 'با تراکنش ${duplicate.memberName} منطبق شد — منتظر تأیید مدیر'
            : 'این کد پیگیری قبلاً ثبت شده است',
      );
    }

    final pending = known.where((t) => t.status == TransactionStatus.pending).toList();
    final match = _parser.match(sms: sms, pending: pending);
    final matched = match.valueOrNull;
    if (matched != null) {
      return SmsSuggestion(
        sms: sms,
        kind: SmsSuggestionKind.matchedPending,
        transaction: matched,
        message: 'تطبیق ${matched.memberName} — تأیید خودکار انجام نشد',
      );
    }

    final guessed = members.where((m) => m.debt == sms.amount).toList();
    final member = guessed.length == 1 ? guessed.first : null;
    final created = await _transactions.submit(
      SubmitPaymentInput(
        amount: sms.amount!,
        occurredAt: sms.occurredAt ?? sms.receivedAt,
        trackingCode: sms.trackingCode!,
        type: TransactionType.sharePayment,
        source: PaymentSource.smsMatch,
        memberId: member?.userId,
        memberName: member?.displayName ?? 'نامشخص — پیشنهاد پیامک',
        note: 'پیشنهاد پیامک بانک ${sms.bank.fa}. تأیید خودکار نیست.',
      ),
    );

    return created.when(
      ok: (tx) {
        assert(
          tx.status == TransactionStatus.pending,
          'پیشنهاد پیامک هرگز نباید تأییدشده ذخیره شود',
        );
        return SmsSuggestion(
          sms: sms,
          kind: SmsSuggestionKind.createdSuggestion,
          transaction: tx,
          message: 'پیشنهاد ${sms.bank.fa} در صف انتظار مدیر ثبت شد',
        );
      },
      err: (m) => SmsSuggestion(sms: sms, kind: SmsSuggestionKind.ignored, message: m),
    );
  }

}
