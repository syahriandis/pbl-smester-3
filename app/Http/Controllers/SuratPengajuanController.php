<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Auth;
use App\Models\SuratPengajuan;
use Illuminate\Http\Request;

class SuratPengajuanController extends Controller
{
    // RT & Admin: lihat semua pengajuan
    public function index()
    {
        $pengajuan = SuratPengajuan::with(['user', 'jenisSurat'])->get();

        return response()->json([
            'data' => $pengajuan
        ]);
    }

    // Warga: ajukan surat
    public function store(Request $request)
    {
        $request->validate([
            'id_jenis_surat' => 'required|exists:jenis_surat,id'
        ]);

        $pengajuan = SuratPengajuan::create([
            'user_id' => Auth::id(),
            'id_jenis_surat' => $request->id_jenis_surat,
            'tanggal_pengajuan' => now()->toDateString(),
            'status' => 'pending'
        ]);

        return response()->json([
            'message' => 'Pengajuan surat berhasil dibuat',
            'data' => $pengajuan
        ]);
    }

    // RT: update status + isi data final
    public function update(Request $request, $id)
    {
        $pengajuan = SuratPengajuan::findOrFail($id);

        $pengajuan->update([
            'catatan_rt' => $request->catatan_rt,
            'data_final' => $request->data_final,
            'status' => $request->status ?? 'diproses'
        ]);

        return response()->json([
            'message' => 'Pengajuan surat berhasil diperbarui',
            'data' => $pengajuan
        ]);
    }
}