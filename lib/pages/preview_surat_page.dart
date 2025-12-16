import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:photo_view/photo_view.dart';

class PreviewSuratPage extends StatelessWidget {
  final String fileSurat; 

  const PreviewSuratPage({
    super.key,
    required this.fileSurat,
  });

  @override
  Widget build(BuildContext context) {
    final url = "http://127.0.0.1:8000/storage/surat_jadi/$fileSurat";

    final isPDF = fileSurat.toLowerCase().endsWith(".pdf");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Preview Surat"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isPDF
          ? SfPdfViewer.network(url)
          : PhotoView(
              imageProvider: NetworkImage(url),
              backgroundDecoration: const BoxDecoration(color: Colors.white),
            ),
    );
  }
}