import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaksi_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Penyewaan')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.transaksi.isEmpty
              ? const Center(child: Text('Belum ada riwayat penyewaan.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.transaksi.length,
                  itemBuilder: (context, index) {
                    final t = provider.transaksi[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: t.status == 'dipinjam' ? Colors.orange : Colors.green,
                          child: Icon(
                            t.status == 'dipinjam' ? Icons.timer : Icons.check_circle,
                            color: Colors.white,
                          ),
                        ),
                        title: Text('Transaksi #${t.id}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status: ${t.status.toUpperCase()}'),
                            Text('Pinjam: ${DateFormat('dd MMM yyyy').format(t.tanggalPinjam)}'),
                            Text('Kembali: ${DateFormat('dd MMM yyyy').format(t.tanggalKembali)}'),
                            const SizedBox(height: 8),
                            ...t.detailTransaksi.map((d) => Text('• ${d.barang?.namaBarang} (${d.jumlah}x)')),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
