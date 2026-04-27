<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Barang extends Model
{
    use HasFactory;

    protected $table = 'barang';

    protected $fillable = [
        'nama_barang',
        'kategori',
        'deskripsi',
        'harga_sewa',
        'stok',
        'gambar',
    ];

    public function detailTransaksi()
    {
        return $this->hasMany(DetailTransaksi::class, 'barang_id');
    }
}
