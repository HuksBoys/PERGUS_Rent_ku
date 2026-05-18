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
        'category_id',
        'kategori',
        'deskripsi',
        'harga_sewa',
        'stok',
        'gambar',
    ];

    protected $appends = ['gambar_url'];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function getGambarUrlAttribute()
    {
        if (!$this->gambar) {
            return null;
        }
        return url('storage/barang/' . $this->gambar);
    }

    public function detailTransaksi()
    {
        return $this->hasMany(DetailTransaksi::class, 'barang_id');
    }
}
