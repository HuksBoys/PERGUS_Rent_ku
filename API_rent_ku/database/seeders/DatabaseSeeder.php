<?php

namespace Database\Seeders;

use App\Models\Barang;
use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Admin User
        User::create([
            'name' => 'Admin RentKU',
            'email' => 'admin@rentku.com',
            'password' => Hash::make('password'),
            'role' => 'admin',
        ]);

        // Sample User
        User::create([
            'name' => 'Budi Santoso',
            'email' => 'budi@example.com',
            'password' => Hash::make('password'),
            'role' => 'user',
        ]);

        // Sample Products
        Barang::create([
            'nama_barang' => 'Kamera Sony A7 III',
            'kategori' => 'Kamera',
            'deskripsi' => 'Kamera Mirrorless Full-frame dengan fitur video 4K.',
            'harga_sewa' => 250000,
            'stok' => 5,
        ]);

        Barang::create([
            'nama_barang' => 'Laptop ASUS ROG',
            'kategori' => 'Laptop',
            'deskripsi' => 'Laptop gaming performa tinggi.',
            'harga_sewa' => 500000,
            'stok' => 3,
        ]);

        Barang::create([
            'nama_barang' => 'Drone DJI Mavic Air 2',
            'kategori' => 'Drone',
            'deskripsi' => 'Drone dengan kamera 48MP dan waktu terbang 34 menit.',
            'harga_sewa' => 350000,
            'stok' => 2,
        ]);
    }
}
