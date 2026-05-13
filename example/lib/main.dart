import 'package:flutter/material.dart';
import 'package:softy_scanner/softy_scanner.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Softy Scanner Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00BFFF)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Softy Scanner Demo')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.document_scanner),
          label: const Text('Open Scanner'),
          onPressed: () => _openScanner(context),
        ),
      ),
    );
  }

  Future<void> _openScanner(BuildContext context) async {
    final result = await SoftyScannerScreen.launch(
      context,
      config: ScannerConfig(locale: ScannerLocale.ar),
    );

    if (!context.mounted) return;

    if (result.isCancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scan cancelled')),
      );
      return;
    }

    final pdfInfo = result.hasPdf
        ? '\nPDF: ${result.pdfFile!.path}'
        : '\nNo PDF generated';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(result.title ?? '${result.pageCount} page(s) scanned'),
        content: SizedBox(
          width: double.maxFinite,
          height: 340,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${result.pageCount} page(s)$pdfInfo',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: result.pageCount,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(result.scannedPages[i], height: 280),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
