import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/transaksi_provider.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Transaksi')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (!_isScanning) return;
              
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null && code.startsWith('rentku_id:')) {
                  setState(() => _isScanning = false);
                  final id = int.tryParse(code.split(':').last);
                  if (id != null) {
                    _processTransaction(id);
                  }
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 4),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          if (!_isScanning)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  void _processTransaction(int id) async {
    try {
      // Find transaction details first
      final provider = context.read<TransaksiProvider>();
      await provider.fetchTransaksi();
      final transaksi = provider.transaksi.firstWhere((t) => t.id == id);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Konfirmasi Transaksi #$id'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User: ${transaksi.user?.name}'),
              Text('Status Saat Ini: ${transaksi.status.toUpperCase()}'),
              const Divider(),
              const Text('Update status menjadi:'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            if (transaksi.status == 'dipinjam')
              ElevatedButton(
                onPressed: () => _updateStatus(id, 'kembali'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: const Text('KEMBALI'),
              ),
          ],
        ),
      ).then((_) => setState(() => _isScanning = true));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isScanning = true);
    }
  }

  void _updateStatus(int id, String status) async {
    try {
      await context.read<TransaksiProvider>().updateStatus(id, status);
      if (!mounted) return;
      Navigator.pop(context); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status berhasil diupdate!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal update: $e')));
    }
  }
}
