<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Auth;
use App\Models\SuratPengajuan;
use Illuminate\Http\Request;

class SuratPengajuanController extends Controller
{
    // ✅ RT & Admin: lihat semua pengajuan
    public function index()
    {
        $pengajuan = SuratPengajuan::with(['user', 'jenisSurat'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'data' => $pengajuan
        ]);
    }

    // ✅ Warga: lihat semua surat miliknya
    public function indexWarga(Request $request)
    {
        $user = $request->user();

        $pengajuan = SuratPengajuan::with(['user', 'jenisSurat'])
            ->where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'data' => $pengajuan
        ]);
    }

    // ✅ Warga: ajukan surat
    public function store(Request $request)
    {
        $request->validate([
            'id_jenis_surat' => 'required|exists:jenis_surat,id',
            'keperluan' => 'nullable|string'
        ]);

        $pengajuan = SuratPengajuan::create([
            'user_id' => Auth::id(),
            'id_jenis_surat' => $request->id_jenis_surat,
            'tanggal_pengajuan' => now()->toDateString(),
            'status' => 'pending',
            'catatan_rt' => null,
            'file_surat' => null,
            'keperluan' => $request->keperluan,
        ]);

        return response()->json([
            'message' => 'Pengajuan surat berhasil dibuat',
            'data' => $pengajuan
        ], 201);
    }

    // ✅ RT: update status (setujui / tolak)
    public function update(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:pending,disetujui,ditolak,selesai',
            'catatan_rt' => 'nullable|string',
        ]);

        $pengajuan = SuratPengajuan::findOrFail($id);

        $pengajuan->update([
            'status' => $request->status,
            'catatan_rt' => $request->catatan_rt,
        ]);

        return response()->json([
            'message' => 'Status pengajuan berhasil diperbarui',
            'data' => $pengajuan
        ]);
    }
}