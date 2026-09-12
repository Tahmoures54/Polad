import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/utils/formatters.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/people.dart';
import '../../domain/entities/reports.dart';
import '../../domain/enums.dart';

/// خروجی Excel / PDF با فونت وزیرمتن و ارقام فارسی.
class ReportExporter {
  const ReportExporter();

  Future<Result<String>> excel(Fund fund, PoladReport report, {bool share = true}) async {
    if (!fund.isPremium) return const Err('خروجی اکسل در نسخه پریمیوم فعال است');
    final excel = Excel.createExcel();
    final sheet = excel['گزارش'];
    sheet.appendRow([
      TextCellValue('عضو'),
      TextCellValue('نوع'),
      TextCellValue('مبلغ'),
      TextCellValue('وضعیت'),
      TextCellValue('کد پیگیری'),
      TextCellValue('تاریخ'),
    ]);
    for (final t in report.filteredTransactions) {
      sheet.appendRow([
        TextCellValue(t.memberName),
        TextCellValue(t.type.fa),
        IntCellValue(t.amount),
        TextCellValue(t.status.fa),
        TextCellValue(t.trackingCode ?? ''),
        TextCellValue(jalaliDate(t.occurredAt)),
      ]);
    }
    final overdue = excel['معوقات'];
    overdue.appendRow([
      TextCellValue('عضو'),
      TextCellValue('قسط'),
      TextCellValue('مبلغ'),
      TextCellValue('سررسید'),
    ]);
    for (final i in report.overdue) {
      overdue.appendRow([
        TextCellValue(i.memberId),
        IntCellValue(i.sequence),
        IntCellValue(i.amount),
        TextCellValue(jalaliDate(i.dueDate)),
      ]);
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/polad-${fund.id}.xlsx';
    final bytes = excel.encode();
    if (bytes == null) return const Err('ساخت فایل ناموفق بود');
    await File(path).writeAsBytes(bytes);
    if (share) {
      await SharePlus.instance.share(ShareParams(files: [XFile(path)], text: 'گزارش ${fund.name}'));
    }
    return Ok(path);
  }

  Future<Result<String>> pdf(Fund fund, PoladReport report, {bool share = true}) async {
    if (!fund.isPremium) return const Err('خروجی PDF در نسخه پریمیوم فعال است');
    final fontData = await rootBundle.load('assets/fonts/Vazirmatn-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Vazirmatn-Bold.ttf');
    final font = pw.Font.ttf(fontData);
    final bold = pw.Font.ttf(boldData);
    final s = report.summary;
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(fund.name, style: pw.TextStyle(font: bold, fontSize: 20)),
              pw.SizedBox(height: 8),
              pw.Text('گزارش صندوق خانوادگی پولاد', style: pw.TextStyle(font: font, fontSize: 12)),
              pw.SizedBox(height: 16),
              pw.Text('موجودی: ${toman(s.balance)}', style: pw.TextStyle(font: font)),
              pw.Text('ورودی: ${toman(s.totalIn)}', style: pw.TextStyle(font: font)),
              pw.Text('خروجی: ${toman(s.totalOut)}', style: pw.TextStyle(font: font)),
              pw.Text('خالص: ${toman(s.net)}', style: pw.TextStyle(font: font)),
              pw.Text('اقساط معوق: ${faDigits(s.overdueCount)} / ${toman(s.overdueAmount)}', style: pw.TextStyle(font: font)),
              pw.Text(
                s.charityZeroFee
                    ? 'کارمزد نرم‌افزار: صفر (خیریه)'
                    : 'کارمزد مدیر: ${toman(s.softwareFeeToAdmin)}',
                style: pw.TextStyle(font: font),
              ),
              pw.SizedBox(height: 16),
              pw.Text('عملکرد اعضا', style: pw.TextStyle(font: bold, fontSize: 14)),
              ...report.members.take(12).map(
                    (m) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 4),
                      child: pw.Text(
                        '${m.member.displayName} — پرداخت ${toman(m.paidAmount)} — معوق ${faDigits(m.overdueCount)}',
                        style: pw.TextStyle(font: font, fontSize: 11),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/polad-${fund.id}.pdf';
    await File(path).writeAsBytes(await doc.save());
    if (share) {
      await SharePlus.instance.share(ShareParams(files: [XFile(path)], text: 'گزارش ${fund.name}'));
    }
    return Ok(path);
  }
}
