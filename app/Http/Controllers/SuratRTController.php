<?php

namespace App\Http\Controllers;

use App\Models\SuratPengajuan;
use Illuminate\Http\Request;

class SuratRTController extends Controller
{
    // ✅ RT lihat semua surat
    public function index()
    {
        $data = SuratPengajuan::with(['user', 'jenisSurat'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'data' => $data
        ]);
    }

    // ✅ RT lihat detail surat
    public function show($id)
    {
        $surat = SuratPengajuan::with(['user', 'jenisSurat'])
            ->findOrFail($id);

        return response()->json([
            'data' => $surat
        ]);
    }

    // ✅ RT setujui / tolak
    public function update(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:pending,disetujui,ditolak,selesai',
            'catatan_rt' => 'nullable|string'
        ]);

        $surat = SuratPengajuan::findOrFail($id);

        $surat->update([
            'status' => $request->status,
            'catatan_rt' => $request->catatan_rt
        ]);

        return response()->json([
            'message' => 'Status diperbarui'
        ]);
    }

    // ✅ RT upload surat jadi
    public function uploadSurat(Request $request, $id)
    {
        $request->validate([
            'file_surat' => 'required|file|mimes:pdf,jpg,jpeg,png'
        ]);

        $surat = SuratPengajuan::findOrFail($id);

        $file = $request->file('file_surat');
        $fileName = time() . '_' . $file->getClientOriginalName();
        $file->storeAs('public/surat_jadi', $fileName);

        $surat->update([
            'file_surat' => $fileName,
            'status' => 'selesai'
        ]);

        return response()->json([
            'message' => 'Surat berhasil diupload',
            'file_surat' => $fileName
        ]);
    }
}