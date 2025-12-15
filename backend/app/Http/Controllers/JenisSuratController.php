<?php

namespace App\Http\Controllers;

use App\Models\JenisSurat;
use Illuminate\Http\Request;

class JenisSuratController extends Controller
{
    // Ambil semua jenis surat
    public function index()
    {
        return response()->json([
            'data' => JenisSurat::all()
        ]);
    }

    // Tambah jenis surat baru
    public function store(Request $request)
    {
        $request->validate([
            'nama_jenis_surat' => 'required'
        ]);

        $jenis = JenisSurat::create([
            'nama_jenis_surat' => $request->nama_jenis_surat
        ]);

        return response()->json([
            'message' => 'Jenis surat berhasil ditambahkan',
            'data' => $jenis
        ]);
    }

    // Hapus jenis surat
    public function destroy($id)
    {
        JenisSurat::findOrFail($id)->delete();

        return response()->json([
            'message' => 'Jenis surat berhasil dihapus'
        ]);
    }
}