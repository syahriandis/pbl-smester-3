<?php

namespace App\Http\Controllers;

use App\Models\SuratPengajuan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class SuratRTController extends Controller
{
    public function index()
    {
        $data = SuratPengajuan::with(['user', 'jenisSurat'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'data' => $data
        ]);
    }

    public function show($id)
    {
        $surat = SuratPengajuan::with(['user', 'jenisSurat'])
            ->findOrFail($id);

        return response()->json([
            'data' => $surat
        ]);
    }

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

   public function uploadSurat(Request $request, $id)
{
    if (!$request->hasFile('file_surat')) {
        return response()->json([
            'error' => 'File tidak terkirim dari frontend'
        ], 400);
    }

    $request->validate([
        'file_surat' => 'required|file|mimes:pdf,jpg,jpeg,png'
    ]);

    $surat = SuratPengajuan::findOrFail($id);

    Storage::disk('public')->makeDirectory('surat_jadi');

    $file = $request->file('file_surat');

    // ✅ Bersihkan nama file
    $original = $file->getClientOriginalName();
    $clean = str_replace(["\r", "\n", "\t"], '', $original);
    $clean = str_replace(' ', '_', $clean);
    $fileName = time() . '_' . $clean;

    // ✅ SIMPAN KE DISK PUBLIC (fix double public)
    Storage::disk('public')->putFileAs('surat_jadi', $file, $fileName);

    // ✅ Update DB
    $surat->file_surat = $fileName;
    $surat->status = 'selesai';
    $surat->save();

    return response()->json([
        'message' => 'Surat berhasil diupload',
        'file_surat' => $fileName
    ]);
}
}