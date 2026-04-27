import 'barang_model.dart';
import 'user_model.dart';

class TransaksiModel {
  final int id;
  final int userId;
  final DateTime tanggalPinjam;
  final DateTime tanggalKembali;
  final String status;
  final UserModel? user;
  final List<DetailTransaksiModel> detailTransaksi;

  TransaksiModel({
    required this.id,
    required this.userId,
    required this.tanggalPinjam,
    required this.tanggalKembali,
    required this.status,
    this.user,
    required this.detailTransaksi,
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    return TransaksiModel(
      id: json['id'],
      userId: json['user_id'],
      tanggalPinjam: DateTime.parse(json['tanggal_pinjam']),
      tanggalKembali: DateTime.parse(json['tanggal_kembali']),
      status: json['status'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      detailTransaksi: (json['detail_transaksi'] as List)
          .map((i) => DetailTransaksiModel.fromJson(i))
          .toList(),
    );
  }
}

class DetailTransaksiModel {
  final int id;
  final int transaksiId;
  final int barangId;
  final int jumlah;
  final BarangModel? barang;

  DetailTransaksiModel({
    required this.id,
    required this.transaksiId,
    required this.barangId,
    required this.jumlah,
    this.barang,
  });

  factory DetailTransaksiModel.fromJson(Map<String, dynamic> json) {
    return DetailTransaksiModel(
      id: json['id'],
      transaksiId: json['transaksi_id'],
      barangId: json['barang_id'],
      jumlah: json['jumlah'],
      barang: json['barang'] != null ? BarangModel.fromJson(json['barang']) : null,
    );
  }
}
