<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Response;

class SuratFileController extends Controller
{
    public function preview($filename)
    {
        $path = 'surat/' . $filename;
        
        if (!Storage::disk('public')->exists($path)) {
            return response()->json(['error' => 'File not found'], 404);
        }

        $file = Storage::disk('public')->path($path);
        
        return Response::file($file, [
            'Content-Type' => 'application/pdf',
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => 'GET, OPTIONS',
            'Access-Control-Allow-Headers' => '*',
        ]);
    }

    public function download($filename)
    {
        $path = 'surat/' . $filename;
        
        if (!Storage::disk('public')->exists($path)) {
            return response()->json(['error' => 'File not found'], 404);
        }

        $file = Storage::disk('public')->path($path);
        
        // ✅ Pakai Response::download dengan CORS headers
        return Response::download($file, $filename, [
            'Content-Type' => 'application/pdf',
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => 'GET, OPTIONS',
            'Access-Control-Allow-Headers' => '*',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
        ]);
    }
}