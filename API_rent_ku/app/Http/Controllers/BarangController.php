<?php

namespace App\Http\Controllers;

use App\Models\Barang;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class BarangController extends Controller
{
    public function index()
    {
        return response()->json(Barang::all());
    }

    public function store(Request $request)
    {
        \Log::info('Upload Request:', $request->all());
        \Log::info('Has File Gambar:', [$request->hasFile('gambar')]);

        $request->validate([
            'nama_barang' => 'required|string|max:255',
            'kategori' => 'required|string|max:255',
            'deskripsi' => 'nullable|string',
            'harga_sewa' => 'required|numeric',
            'stok' => 'required|integer',
            'gambar' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        $data = $request->all();

        if ($request->hasFile('gambar')) {
            $file = $request->file('gambar');
            $path = $file->store('barang', 'public'); 
            $data['gambar'] = basename($path);
        }

        $barang = Barang::create($data);

        return response()->json($barang, 201);
    }

    public function show(Barang $barang)
    {
        return response()->json($barang);
    }

    public function update(Request $request, Barang $barang)
    {
        $request->validate([
            'nama_barang' => 'sometimes|required|string|max:255',
            'kategori' => 'sometimes|required|string|max:255',
            'deskripsi' => 'nullable|string',
            'harga_sewa' => 'sometimes|required|numeric',
            'stok' => 'sometimes|required|integer',
            'gambar' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        $data = $request->all();

        if ($request->hasFile('gambar')) {
            if ($barang->gambar) {
                Storage::delete('public/barang/' . $barang->gambar);
            }
            $path = $request->file('gambar')->store('public/barang');
            $data['gambar'] = basename($path);
        }

        $barang->update($data);

        return response()->json($barang);
    }

    public function destroy(Barang $barang)
    {
        if ($barang->gambar) {
            Storage::delete('public/barang/' . $barang->gambar);
        }
        $barang->delete();

        return response()->json(['message' => 'Barang berhasil dihapus']);
    }
}
