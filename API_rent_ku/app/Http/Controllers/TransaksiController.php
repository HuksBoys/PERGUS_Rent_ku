<?php

namespace App\Http\Controllers;

use App\Models\Barang;
use App\Models\DetailTransaksi;
use App\Models\Transaksi;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TransaksiController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        if ($user->role === 'admin') {
            $transaksi = Transaksi::with(['user', 'detailTransaksi.barang'])->get();
        } else {
            $transaksi = Transaksi::with(['detailTransaksi.barang'])
                ->where('user_id', $user->id)
                ->get();
        }

        return response()->json($transaksi);
    }

    public function store(Request $request)
    {
        $request->validate([
            'tanggal_pinjam' => 'required|date',
            'tanggal_kembali' => 'required|date|after_or_equal:tanggal_pinjam',
            'items' => 'required|array',
            'items.*.barang_id' => 'required|exists:barang,id',
            'items.*.jumlah' => 'required|integer|min:1',
        ]);

        return DB::transaction(function () use ($request) {
            $transaksi = Transaksi::create([
                'user_id' => $request->user()->id,
                'tanggal_pinjam' => $request->tanggal_pinjam,
                'tanggal_kembali' => $request->tanggal_kembali,
                'status' => 'dipinjam',
            ]);

            foreach ($request->items as $item) {
                $barang = Barang::findOrFail($item['barang_id']);

                if ($barang->stok < $item['jumlah']) {
                    throw new \Exception("Stok {$barang->nama_barang} tidak mencukupi.");
                }

                $barang->decrement('stok', $item['jumlah']);

                DetailTransaksi::create([
                    'transaksi_id' => $transaksi->id,
                    'barang_id' => $item['barang_id'],
                    'jumlah' => $item['jumlah'],
                ]);
            }

            return response()->json($transaksi->load('detailTransaksi.barang'), 201);
        });
    }

    public function show(Transaksi $transaksi)
    {
        $this->authorizeAccess($transaksi);
        return response()->json($transaksi->load(['user', 'detailTransaksi.barang']));
    }

    public function update(Request $request, Transaksi $transaksi)
    {
        if ($request->user()->role !== 'admin') {
            return response()->json(['message' => 'Hanya admin yang bisa mengubah status'], 403);
        }

        $request->validate([
            'status' => 'required|in:dipinjam,kembali',
        ]);

        if ($request->status === 'kembali' && $transaksi->status !== 'kembali') {
            foreach ($transaksi->detailTransaksi as $detail) {
                $detail->barang->increment('stok', $detail->jumlah);
            }
        }

        $transaksi->update(['status' => $request->status]);

        return response()->json($transaksi);
    }

    private function authorizeAccess(Transaksi $transaksi)
    {
        $user = auth()->user();
        if ($user->role !== 'admin' && $transaksi->user_id !== $user->id) {
            abort(403, 'Unauthorized action.');
        }
    }
}
