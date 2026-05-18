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
    Route::post('/profile/update', [AuthController::class, 'updateProfile']);

    // Barang Routes
    Route::get('/barang', [BarangController::class, 'index']);
    Route::get('/barang/{barang}', [BarangController::class, 'show']);
    
    // Category Routes
    Route::get('/categories', [\App\Http\Controllers\CategoryController::class, 'index']);
    
    Route::middleware('admin')->group(function () {
        Route::post('/barang', [BarangController::class, 'store']);
        Route::put('/barang/{barang}', [BarangController::class, 'update']);
        Route::delete('/barang/{barang}', [BarangController::class, 'destroy']);
        
        Route::post('/categories', [\App\Http\Controllers\CategoryController::class, 'store']);
    });

    // Transaksi Routes
    Route::get('/transaksi', [TransaksiController::class, 'index']);
    Route::post('/transaksi', [TransaksiController::class, 'store']);
    Route::get('/transaksi/{transaksi}', [TransaksiController::class, 'show']);
    Route::put('/transaksi/{transaksi}', [TransaksiController::class, 'update'])->middleware('admin');

    // Message Routes
    Route::get('/messages/admin', [\App\Http\Controllers\MessageController::class, 'getAdminId']);
    Route::get('/messages/list', [\App\Http\Controllers\MessageController::class, 'chatList']);
    Route::get('/messages/{otherUserId}', [\App\Http\Controllers\MessageController::class, 'index']);
    Route::post('/messages', [\App\Http\Controllers\MessageController::class, 'store']);
});
