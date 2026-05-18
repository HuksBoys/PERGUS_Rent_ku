import 'category_model.dart';

class BarangModel {
  final int id;
  final int? categoryId;
  final String namaBarang;
  final String kategori;
  final String? deskripsi;
  final double hargaSewa;
  final int stok;
  final String? gambar;
  final String? gambarUrl;
  final CategoryModel? category;

  BarangModel({
    required this.id,
    this.categoryId,
    required this.namaBarang,
    required this.kategori,
    this.deskripsi,
    required this.hargaSewa,
    required this.stok,
    this.gambar,
    this.gambarUrl,
    this.category,
  });

  factory BarangModel.fromJson(Map<String, dynamic> json) {
    return BarangModel(
      id: json['id'],
      categoryId: json['category_id'],
      namaBarang: json['nama_barang'],
      kategori: json['kategori'] ?? '',
      deskripsi: json['deskripsi'],
      hargaSewa: double.parse(json['harga_sewa'].toString()),
      stok: int.parse(json['stok'].toString()),
      gambar: json['gambar'],
      gambarUrl: json['gambar_url'],
      category: json['category'] != null ? CategoryModel.fromJson(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'nama_barang': namaBarang,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'harga_sewa': hargaSewa,
      'stok': stok,
      'gambar': gambar,
    };
  }
}
