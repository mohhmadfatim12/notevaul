import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:notevault/domain/entities/note_entity.dart';
import 'package:notevault/core/extensions/date_extensions.dart';

class ExportService {
  /// Generates clean PDF bytes for a single note.
  Future<Uint8List> generateNotePdf(NoteEntity note) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    note.title.isNotEmpty ? note.title : 'Untitled Note',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.indigo900,
                    ),
                  ),
                  pw.Text(
                    'NoteVault',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 8),
            // Metadata bar
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  if (note.folderName != null)
                    pw.Text('Folder: ${note.folderName}',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                  pw.Text('Created: ${note.createdAt.formatDate()}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                  pw.Text('Updated: ${note.updatedAt.formatDate()}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                ],
              ),
            ),
            if (note.tags.isNotEmpty) ...[
              pw.SizedBox(height: 8),
              pw.Row(
                children: [
                  pw.Text('Tags: ',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    note.tags.map((t) => '#${t.name}').join('  '),
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.indigo700),
                  ),
                ],
              ),
            ],
            pw.Divider(thickness: 1, color: PdfColors.grey400),
            pw.SizedBox(height: 12),
            // Body Content
            pw.Paragraph(
              text: note.body,
              style: const pw.TextStyle(
                fontSize: 12,
                lineSpacing: 4,
                color: PdfColors.black,
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Exports and triggers native PDF sharing/printing dialog.
  Future<void> exportAndSharePdf(NoteEntity note) async {
    final pdfBytes = await generateNotePdf(note);
    final sanitizedTitle = note.title.isNotEmpty
        ? note.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        : 'Note';
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: '$sanitizedTitle.pdf',
    );
  }

  /// Exports note as formatted plain text via native share sheet.
  Future<void> shareAsText(NoteEntity note) async {
    final buffer = StringBuffer();
    if (note.title.isNotEmpty) {
      buffer.writeln(note.title);
      buffer.writeln('=' * note.title.length);
    }
    if (note.folderName != null) {
      buffer.writeln('Folder: ${note.folderName}');
    }
    if (note.tags.isNotEmpty) {
      buffer.writeln('Tags: ${note.tags.map((t) => '#${t.name}').join(', ')}');
    }
    buffer.writeln('Last Updated: ${note.updatedAt.formatRelative()}');
    buffer.writeln();
    buffer.writeln(note.body);

    await SharePlus.instance.share(
      ShareParams(
        text: buffer.toString(),
        subject: note.title.isNotEmpty ? note.title : 'Note from NoteVault',
      ),
    );
  }

  /// Saves note as TXT file to local app documents directory.
  Future<File> saveAsTxtFile(NoteEntity note) async {
    final dir = await getApplicationDocumentsDirectory();
    final sanitizedTitle = note.title.isNotEmpty
        ? note.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        : 'Note_${note.id.substring(0, 6)}';
    final file = File('${dir.path}/$sanitizedTitle.txt');

    final content = StringBuffer()
      ..writeln(note.title)
      ..writeln('Updated: ${note.updatedAt.formatFull()}')
      ..writeln()
      ..writeln(note.body);

    return await file.writeAsString(content.toString());
  }
}
