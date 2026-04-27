<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\BarangController;
use App\Http\Controllers\TransaksiController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/profile', [AuthController::class, 'profile']);

    // Barang Routes
    Route::get('/barang', [BarangController::class, 'index']);
    Route::get('/barang/{barang}', [BarangController::class, 'show']);
    
    Route::middleware('admin')->group(function () {
        Route::post('/barang', [BarangController::class, 'store']);
        Route::put('/barang/{barang}', [BarangController::class, 'update']);
        Route::delete('/barang/{barang}', [BarangController::class, 'destroy']);
    });

    // Transaksi Routes
    Route::get('/transaksi', [TransaksiController::class, 'index']);
    Route::post('/transaksi', [TransaksiController::class, 'store']);
    Route::get('/transaksi/{transaksi}', [TransaksiController::class, 'show']);
    Route::put('/transaksi/{transaksi}', [TransaksiController::class, 'update'])->middleware('admin');
});
