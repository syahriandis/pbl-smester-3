<?php

namespace App\Http\Controllers;

class SuratFileController extends Controller
{
    // ✅ PREVIEW FILE (dibuka di browser)
    public function preview($filename)
    {
        $path = storage_path("app/public/surat_jadi/" . $filename);

        if (!file_exists($path)) {
            abort(404, "File tidak ditemukan");
        }

        return response()->file($path);
    }

    // ✅ DOWNLOAD FILE (force download)
    public function download($filename)
    {
        $path = storage_path("app/public/surat_jadi/" . $filename);

        if (!file_exists($path)) {
            abort(404, "File tidak ditemukan");
        }

        return response()->download($path);
    }
}