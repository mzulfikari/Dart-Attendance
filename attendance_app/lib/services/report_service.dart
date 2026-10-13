import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';
import '../utils/jalali_utils.dart';

class ReportService {
  static Future<pw.Document> _createDocument() async {
    final regularFontData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    final boldFontData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');

    return pw.Document(
      theme: pw.ThemeData.withFont(
        base: pw.Font.ttf(regularFontData),
        bold: pw.Font.ttf(boldFontData),
      ),
    );
  }

  static Future<void> generateDailyReportPdf({
    required DateTime date,
    required List<AttendanceRecord> records,
    required List<Worker> workers,
  }) async {
    final pdf = await _createDocument();
    final jalaliDate = JalaliUtils.formatDate(date, withWeekDay: true);

    final workerMap = {for (var w in workers) w.id: w};

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          textDirection: pw.TextDirection.rtl,
        ),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'گزارش روزانه حضور و غیاب',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green800,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                jalaliDate,
                style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
              ),
            ),
            pw.Divider(thickness: 2, color: PdfColors.green800),
            pw.SizedBox(height: 16),
            _buildDailyTable(records, workerMap),
            pw.SizedBox(height: 24),
            _buildSummary(records),
          ],
        ),
      ),
    );

    await _saveAndSharePdf(pdf, 'daily_report_${JalaliUtils.formatShortDate(date).replaceAll('/', '-')}.pdf');
  }

  static Future<void> generateMonthlyReportPdf({
    required DateTime startDate,
    required DateTime endDate,
    required List<Worker> workers,
    required List<AttendanceRecord> records,
  }) async {
    final pdf = await _createDocument();
    final startJalali = JalaliUtils.formatDate(startDate);
    final endJalali = JalaliUtils.formatDate(endDate);

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(16),
          textDirection: pw.TextDirection.rtl,
        ),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'گزارش ماهانه حضور و غیاب',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green800,
                ),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(
                'از $startJalali تا $endJalali',
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
              ),
            ),
            pw.Divider(thickness: 2, color: PdfColors.green800),
            pw.SizedBox(height: 12),
            _buildMonthlyTable(workers, records, startDate, endDate),
          ],
        ),
      ),
    );

    await _saveAndSharePdf(pdf, 'monthly_report_${JalaliUtils.formatShortDate(startDate).replaceAll('/', '-')}.pdf');
  }

  static Future<void> generateWorkerReportPdf({
    required Worker worker,
    required List<AttendanceRecord> records,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = await _createDocument();
    final startJalali = JalaliUtils.formatDate(startDate);
    final endJalali = JalaliUtils.formatDate(endDate);

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          textDirection: pw.TextDirection.rtl,
        ),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'گزارش کارمندی',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green800,
                ),
              ),
            ),
            pw.SizedBox(height: 16),
            _buildWorkerInfo(worker),
            pw.SizedBox(height: 16),
            pw.Text(
              'بازه زمانی: $startJalali تا $endJalali',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.Divider(thickness: 1, color: PdfColors.grey400),
            pw.SizedBox(height: 12),
            _buildWorkerDetailTable(records),
            pw.SizedBox(height: 24),
            _buildWorkerSummary(records),
          ],
        ),
      ),
    );

    await _saveAndSharePdf(pdf, 'worker_report_${worker.name.replaceAll(' ', '_')}.pdf');
  }

  static pw.Widget _buildDailyTable(List<AttendanceRecord> records, Map<int?, Worker> workerMap) {
    final headers = ['نام نیرو', 'کد ملی', 'سمت', 'وضعیت', 'ساعت ورود', 'ساعت خروج', 'موقعیت', 'توضیحات'];
    final data = records.map((r) {
      final w = workerMap[r.workerId];
      return [
        w?.name ?? '-',
        w?.nationalCode ?? '-',
        w?.role.label ?? '-',
        r.status.label,
        r.checkInTime != null ? JalaliUtils.formatTime(r.checkInTime!) : '-',
        r.checkOutTime != null ? JalaliUtils.formatTime(r.checkOutTime!) : '-',
        r.location ?? '-',
        r.note ?? '-',
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
      cellStyle: pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerRight,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
        5: const pw.FlexColumnWidth(1.5),
        6: const pw.FlexColumnWidth(1.5),
        7: const pw.FlexColumnWidth(2),
      },
    );
  }

  static pw.Widget _buildMonthlyTable(
    List<Worker> workers,
    List<AttendanceRecord> records,
    DateTime startDate,
    DateTime endDate,
  ) {
    final days = <DateTime>[];
    var current = DateTime(startDate.year, startDate.month, startDate.day);
    final lastDay = DateTime(endDate.year, endDate.month, endDate.day);
    while (!current.isAfter(lastDay)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    final recordMap = <String, AttendanceRecord>{};
    for (final r in records) {
      final key = '${r.workerId}_${JalaliUtils.formatShortDate(r.date)}';
      recordMap[key] = r;
    }

    final headers = ['نام نیرو', 'کد ملی', 'سمت', ...days.map((d) => JalaliUtils.toPersianDigitsInt(JalaliUtils.toJalali(d).day))];
    final data = workers.map((w) {
      final row = <String>[
        w.name,
        w.nationalCode,
        w.role.label,
      ];
      for (final d in days) {
        final key = '${w.id}_${JalaliUtils.formatShortDate(d)}';
        final record = recordMap[key];
        row.add(record == null ? '-' : _statusAbbreviation(record.status));
      }
      return row;
    }).toList();

    return pw.TableHelper.fromTextArray(
        headers: headers,
        data: data,
        headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 8,
          color: PdfColors.white,
        ),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
        cellStyle: pw.TextStyle(fontSize: 7),
        cellAlignment: pw.Alignment.center,
        border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.3),
      );
  }

  static pw.Widget _buildWorkerInfo(Worker worker) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('نام: ${worker.name}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.Text('کد ملی: ${worker.nationalCode}', style: pw.TextStyle(fontSize: 10)),
          pw.Text('تلفن: ${worker.phone}', style: pw.TextStyle(fontSize: 10)),
          pw.Text('سمت: ${worker.role.label}', style: pw.TextStyle(fontSize: 10)),
          if (worker.address != null) pw.Text('آدرس: ${worker.address}', style: pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _buildWorkerDetailTable(List<AttendanceRecord> records) {
    final headers = ['تاریخ', 'وضعیت', 'ساعت ورود', 'ساعت خروج', 'موقعیت', 'توضیحات'];
    final data = records.map((r) => [
      JalaliUtils.formatDate(r.date),
      r.status.label,
      r.checkInTime != null ? JalaliUtils.formatTime(r.checkInTime!) : '-',
      r.checkOutTime != null ? JalaliUtils.formatTime(r.checkOutTime!) : '-',
      r.location ?? '-',
      r.note ?? '-',
    ]).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
      cellStyle: pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerRight,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    );
  }

  static pw.Widget _buildSummary(List<AttendanceRecord> records) {
    final stats = <AttendanceStatus, int>{};
    for (final r in records) {
      stats[r.status] = (stats[r.status] ?? 0) + 1;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('خلاصه:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: AttendanceStatus.values.map((s) {
              return pw.Column(
                children: [
                  pw.Text(
                    '${stats[s] ?? 0}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: _statusToPdfColor(s),
                    ),
                  ),
                  pw.Text(s.label, style: pw.TextStyle(fontSize: 9)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildWorkerSummary(List<AttendanceRecord> records) {
    final stats = <AttendanceStatus, int>{};
    for (final r in records) {
      stats[r.status] = (stats[r.status] ?? 0) + 1;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('خلاصه حضور:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: AttendanceStatus.values.map((s) {
              return pw.Column(
                children: [
                  pw.Text(
                    '${stats[s] ?? 0}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: _statusToPdfColor(s),
                    ),
                  ),
                  pw.Text(s.label, style: pw.TextStyle(fontSize: 9)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static String _statusAbbreviation(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'ح';
      case AttendanceStatus.absent:
        return 'غ';
      case AttendanceStatus.late:
        return 'ت';
      case AttendanceStatus.leave:
        return 'ر';
      case AttendanceStatus.mission:
        return 'م';
    }
  }

  static PdfColor _statusToPdfColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return PdfColors.green800;
      case AttendanceStatus.absent:
        return PdfColors.red800;
      case AttendanceStatus.late:
        return PdfColors.orange800;
      case AttendanceStatus.leave:
        return PdfColors.blue800;
      case AttendanceStatus.mission:
        return PdfColors.purple800;
    }
  }

  static Future<void> _saveAndSharePdf(pw.Document pdf, String fileName) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: 'گزارش حضور و غیاب');
  }

  static Future<void> generateExcelReport({
    required DateTime startDate,
    required DateTime endDate,
    required List<Worker> workers,
    required List<AttendanceRecord> records,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['گزارش حضور و غیاب'];

    final recordMap = <String, AttendanceRecord>{};
    for (final r in records) {
      final key = '${r.workerId}_${JalaliUtils.formatShortDate(r.date)}';
      recordMap[key] = r;
    }

    final days = <DateTime>[];
    var current = DateTime(startDate.year, startDate.month, startDate.day);
    final lastDay = DateTime(endDate.year, endDate.month, endDate.day);
    while (!current.isAfter(lastDay)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    final headers = ['نام نیرو', 'کد ملی', 'سمت', ...days.map((d) => JalaliUtils.toPersianDigitsInt(JalaliUtils.toJalali(d).day))];
    sheet.appendRow(headers);

    for (final w in workers) {
      final row = <dynamic>[
        w.name,
        w.nationalCode,
        w.role.label,
      ];
      for (final d in days) {
        final key = '${w.id}_${JalaliUtils.formatShortDate(d)}';
        final record = recordMap[key];
        row.add(record == null ? '-' : _statusAbbreviation(record.status));
      }
      sheet.appendRow(row);
    }

    final output = await getTemporaryDirectory();
    final fileName = 'monthly_report_${JalaliUtils.formatShortDate(startDate).replaceAll('/', '-')}.xlsx';
    final file = File('${output.path}/$fileName');
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: 'گزارش اکسل حضور و غیاب');
    }
  }
}