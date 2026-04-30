class BarangModel {
  final int id;
  final String namaBarang;
  final String kategori;
  final String? deskripsi;
  final double hargaSewa;
  final int stok;
  final String? gambar;
  final String? gambarUrl;

  BarangModel({
    required this.id,
    required this.namaBarang,
    required this.kategori,
    this.deskripsi,
    required this.hargaSewa,
    required this.stok,
    this.gambar,
    this.gambarUrl,
  });

  factory BarangModel.fromJson(Map<String, dynamic> json) {
    return BarangModel(
      id: json['id'],
      namaBarang: json['nama_barang'],
      kategori: json['kategori'],
      deskripsi: json['deskripsi'],
      hargaSewa: double.parse(json['harga_sewa'].toString()),
      stok: int.parse(json['stok'].toString()),
      gambar: json['gambar'],
      gambarUrl: json['gambar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_barang': namaBarang,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'harga_sewa': hargaSewa,
      'stok': stok,
      'gambar': gambar,
    };
  }
}
