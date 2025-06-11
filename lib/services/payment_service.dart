import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createPayment({
    required String title,
    required double price,
    required String type,
    required DateTime date,
  }) async {
    // Create payment document
    final payment = await _firestore.collection('payments').add({
      'title': title,
      'price': price,
      'type': type,
      'date': date,
      'status': 'completed',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return payment.id;
  }

  Future<void> generatePaymentReceipt({
    required String paymentId,
    required String title,
    required double price,
    required String type,
    required DateTime date,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build:
            (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Payment Receipt',
                  style: pw.TextStyle(
                    fontSize: 24,
                    font: pw.Font.helveticaBold(),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Payment ID: $paymentId'),
                pw.Text('Title: $title'),
                pw.Text('Type: $type'),
                pw.Text('Price: Rp$price'),
                pw.Text('Date: ${date.toString()}'),
              ],
            ),
      ),
    );

    // Convert PDF to bytes
    final bytes = await pdf.save();

    // Create blob
    final blob = html.Blob([bytes], 'application/pdf');

    // Create download URL
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create anchor element
    final anchor =
        html.AnchorElement()
          ..href = url
          ..style.display = 'none'
          ..download = 'payment_$paymentId.pdf';

    // Add to document body
    html.document.body?.children.add(anchor);

    // Trigger download
    anchor.click();

    // Clean up
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}
