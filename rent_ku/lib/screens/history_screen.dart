import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/transaksi_provider.dart';

class HistoryScreen extends StatefulWidget {
  final bool showAppBar;
  const HistoryScreen({super.key, this.showAppBar = true});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TransaksiProvider>().fetchTransaksi());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransaksiProvider>();

    if (!widget.showAppBar) {
      return _buildBody(provider);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Penyewaan')),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(TransaksiProvider provider) {
    return provider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : provider.transaksi.isEmpty
            ? const Center(child: Text('Belum ada riwayat penyewaan.'))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: provider.transaksi.length,
                itemBuilder: (context, index) {
                  final t = provider.transaksi[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            t.status == 'dipinjam' ? Colors.orange : Colors.green,
                        child: Icon(
                          t.status == 'dipinjam'
                              ? Icons.timer
                              : Icons.check_circle,
                          color: Colors.white,
                        ),
                      ),
                      title: Text('Transaksi #${t.id}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${t.status.toUpperCase()}'),
                          Text(
                              'Pinjam: ${DateFormat('dd MMM yyyy').format(t.tanggalPinjam)}'),
                          Text(
                              'Kembali: ${DateFormat('dd MMM yyyy').format(t.tanggalKembali)}'),
                          const SizedBox(height: 8),
                          ...t.detailTransaksi.map((d) =>
                              Text('• ${d.barang?.namaBarang} (${d.jumlah}x)')),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.qr_code, color: Colors.blue),
                        onPressed: () => _showQR(context, t.id),
                      ),
                    ),
                  );
                },
              );
  }

  void _showQR(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR Code Transaksi #$id'),
        content: SizedBox(
          width: 250,
          height: 250,
          child: Center(
            child: QrImageView(
              data: 'rentku_id:$id',
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup')),
        ],
      ),
    );
  }
}
