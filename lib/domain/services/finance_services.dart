import 'dart:math';

import '../enums.dart';

/// جدول بازپرداخت قرض‌الحسنه: اصل وام به‌صورت مساوی بین اقساط تقسیم می‌شود.
/// رقم ۲٪ هزینهٔ اداری صندوق است، نه بهره بانکی (ربا).
class InstallmentPlan {
  const InstallmentPlan({
    required this.principal,
    required this.fee,
    required this.total,
    required this.items,
  });

  final int principal;
  final int fee;
  final int total;
  final List<InstallmentDraft> items;
}

class InstallmentDraft {
  const InstallmentDraft({
    required this.sequence,
    required this.amount,
    required this.dueDate,
    required this.principalPart,
    required this.feePart,
  });

  final int sequence;
  final int amount;
  final DateTime dueDate;
  final int principalPart;
  final int feePart;
}

class InstallmentCalculator {
  const InstallmentCalculator();

  /// [feeRate] پیش‌فرض ۲٪ طبق رویه صندوق؛ روی هر قسط سرشکن می‌شود.
  InstallmentPlan plan({
    required int principal,
    required int termMonths,
    required DateTime start,
    double feeRate = 0.02,
    int periodDays = 30,
  }) {
    if (principal <= 0) {
      throw ArgumentError('principal must be positive');
    }
    if (termMonths <= 0) {
      throw ArgumentError('termMonths must be positive');
    }
    if (feeRate < 0 || feeRate > 0.05) {
      throw ArgumentError('feeRate out of allowed range');
    }

    final fee = (principal * feeRate).round();
    final total = principal + fee;
    final base = total ~/ termMonths;
    final remainder = total - base * termMonths;
    final pBase = principal ~/ termMonths;
    final pRem = principal - pBase * termMonths;
    final fBase = fee ~/ termMonths;
    final fRem = fee - fBase * termMonths;

    final items = <InstallmentDraft>[];
    for (var i = 0; i < termMonths; i++) {
      final extra = i == termMonths - 1 ? remainder : 0;
      final pExtra = i == termMonths - 1 ? pRem : 0;
      final fExtra = i == termMonths - 1 ? fRem : 0;
      items.add(
        InstallmentDraft(
          sequence: i + 1,
          amount: base + extra,
          dueDate: start.add(Duration(days: periodDays * (i + 1))),
          principalPart: pBase + pExtra,
          feePart: fBase + fExtra,
        ),
      );
    }
    return InstallmentPlan(principal: principal, fee: fee, total: total, items: items);
  }

  InstallmentStatus statusOf(DateTime due, {DateTime? now, bool paid = false}) {
    if (paid) return InstallmentStatus.paid;
    final today = now ?? DateTime.now();
    final dueDay = DateTime(due.year, due.month, due.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    if (todayDay.isAfter(dueDay)) return InstallmentStatus.overdue;
    return InstallmentStatus.upcoming;
  }
}

class FeeCalculator {
  const FeeCalculator();

  /// Software service fee billed to the FUND ADMIN.
  /// Never deducted from the member's payment (Shaparak circular).
  int softwareServiceFee(int transactionAmount, double rate) {
    if (transactionAmount < 0) throw ArgumentError('amount');
    if (rate < 0.005 || rate > 0.01) {
      throw ArgumentError('service fee rate must be between 0.5% and 1%');
    }
    return (transactionAmount * rate).round();
  }

  int accrue(Iterable<int> approvedAmounts, double rate) {
    var sum = 0;
    for (final a in approvedAmounts) {
      sum += softwareServiceFee(a, rate);
    }
    return sum;
  }
}

class InviteCode {
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static String generate([Random? random]) {
    final r = random ?? Random.secure();
    return List.generate(6, (_) => _alphabet[r.nextInt(_alphabet.length)]).join();
  }

  static String normalize(String raw) =>
      raw.trim().toUpperCase().replaceAll(RegExp(r'\s'), '');
}

class LoanEligibility {
  const LoanEligibility();

  /// Simple, transparent rule: no overdue installment, share balance >= one share,
  /// requested amount <= 10× share and <= 80% of current fund balance.
  String? denyReason({
    required int requested,
    required int shareAmount,
    required int memberShareBalance,
    required int overdueCount,
    required int fundBalance,
    required bool isActiveMember,
  }) {
    if (!isActiveMember) return 'عضویت شما فعال نیست';
    if (overdueCount > 0) return 'قسط معوق دارید؛ ابتدا معوقات را تسویه کنید';
    if (memberShareBalance < shareAmount) return 'حداقل یک سهم کامل پرداخت نشده است';
    if (requested < shareAmount) return 'مبلغ وام از یک سهم کمتر است';
    if (requested > shareAmount * 10) return 'سقف وام ۱۰ برابر سهم ماهانه است';
    if (requested > (fundBalance * 0.8).floor()) {
      return 'موجودی صندوق برای این مبلغ کافی نیست';
    }
    return null;
  }
}

class DrawSelector {
  const DrawSelector();

  String pickRandom(List<String> eligibleIds, Random random) {
    if (eligibleIds.isEmpty) {
      throw StateError('no eligible members');
    }
    return eligibleIds[random.nextInt(eligibleIds.length)];
  }
}
