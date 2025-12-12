<?php

namespace App\Http\Controllers;

use App\Models\SuratPengajuan;
use Illuminate\Http\Request;

class SuratRTController extends Controller
{
    // GET semua surat
    public function index()
    {
        $surat = SuratPengajuan::with(['user', 'jenisSurat'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'message' => 'Daftar surat',
            'data' => $surat
        ]);
    }

    // GET detail surat
    public function show($id)
    {
        $surat = SuratPengajuan::with(['user', 'jenisSurat'])
            ->findOrFail($id);

        return response()->json([
            'message' => 'Detail surat',
            'data' => $surat
        ]);
    }

    // PUT update surat oleh RT
    public function update(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:pending,diproses,selesai',
            'catatan_rt' => 'nullable|string',
            'data_final' => 'nullable|array',
        ]);

        $surat = SuratPengajuan::findOrFail($id);

        $surat->update([
            'status' => $request->status,
            'catatan_rt' => $request->catatan_rt,
            'data_final' => $request->data_final,
        ]);

        return response()->json([
            'message' => 'Surat berhasil diperbarui'
        ]);
    }
}