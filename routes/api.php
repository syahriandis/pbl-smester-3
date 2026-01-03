<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Response;
use Illuminate\Support\Facades\Log;

use App\Http\Controllers\LoginController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\FamilyController;
use App\Http\Controllers\InformasiController;
use App\Http\Controllers\JenisSuratController;
use App\Http\Controllers\SuratPengajuanController;
use App\Http\Controllers\SuratRTController;
use App\Http\Controllers\PengaduanController;
use App\Http\Controllers\Api\PembayaranController;
// Routes untuk semua role yang terautentikasi (warga, rt, rw, security)
    

// =========================
// PUBLIC ROUTES
// =========================

// Login
Route::post('/login', [LoginController::class, 'login']);

// Jenis Surat
Route::get('/jenis-surat', [JenisSuratController::class, 'index']);
// ✅ PENGADUAN IMAGES - Pastikan ada dan SEBELUM route storage general
Route::get('/pengaduan/{filename}', function ($filename) {
    $filePath = storage_path('app/public/pengaduan/' . $filename);
    
    if (!file_exists($filePath)) {
        Log::error('Pengaduan image not found: ' . $filePath);
        abort(404, 'Image not found');
    }

    return response()->file($filePath, [
        'Content-Type' => mime_content_type($filePath),
        'Access-Control-Allow-Origin' => '*',
        'Cache-Control' => 'public, max-age=3600',
    ]);
});
// ✅ SURAT PREVIEW & DOWNLOAD - TARUH DI ATAS STORAGE ROUTE!
Route::get('/surat/preview/{filename}', function ($filename) {
    $filePath = storage_path('app/public/surat_jadi/' . $filename);
    
    if (!file_exists($filePath)) {
        Log::error('Surat not found: ' . $filePath);
        abort(404, 'File not found');
    }

    return response()->file($filePath, [
        'Content-Type' => mime_content_type($filePath),
        'Access-Control-Allow-Origin' => '*',
        'Content-Disposition' => 'inline; filename="' . $filename . '"',
    ]);
});

Route::get('/surat/download/{filename}', function ($filename) {
    $filePath = storage_path('app/public/surat_jadi/' . $filename);
    
    if (!file_exists($filePath)) {
        Log::error('Surat not found for download: ' . $filePath);
        abort(404, 'File not found');
    }

    return response()->download($filePath, $filename, [
        'Content-Type' => mime_content_type($filePath),
        'Access-Control-Allow-Origin' => '*',
    ]);
});

// ✅ STORAGE - GENERAL PURPOSE
Route::get('/storage/{path}', function ($path) {
    $filePath = storage_path('app/public/' . $path);
    
    if (!file_exists($filePath)) {
        Log::error('File not found: ' . $filePath);
        abort(404, 'File not found');
    }

    $mimeType = mime_content_type($filePath);
    
    return response()->file($filePath, [
        'Content-Type' => $mimeType,
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, OPTIONS',
        'Access-Control-Allow-Headers' => '*',
        'Cache-Control' => 'public, max-age=3600',
    ]);
})->where('path', '.*');
// =========================
// PROTECTED ROUTES
// =========================
Route::middleware('auth:sanctum')->group(function () {
    Route::prefix('pembayaran')->group(function () {
        Route::get('/status-bulan-ini', [PembayaranController::class, 'statusBulanIni']);
        Route::post('/upload-bukti', [PembayaranController::class, 'uploadBukti']);
        Route::get('/riwayat', [PembayaranController::class, 'riwayat']);
        Route::get('/detail/{id}', [PembayaranController::class, 'detail']);
    });
    
    // JENIS SURAT
    Route::post('/jenis-surat', [JenisSuratController::class, 'store']);
    Route::delete('/jenis-surat/{id}', [JenisSuratController::class, 'destroy']);

    // SURAT WARGA
    Route::get('/warga/surat', [SuratPengajuanController::class, 'indexWarga']);
    Route::post('/warga/surat', [SuratPengajuanController::class, 'store']);

    // SURAT RT
    Route::get('/rt/surat', [SuratRTController::class, 'index']);
    Route::get('/rt/surat/{id}', [SuratRTController::class, 'show']);
    Route::put('/rt/surat/{id}', [SuratRTController::class, 'update']);
    Route::post('/rt/surat/{id}/upload', [SuratRTController::class, 'uploadSurat']);

    // INFORMASI
    Route::get('/informasi', [InformasiController::class, 'index']);
    Route::post('/informasi', [InformasiController::class, 'store']);
    Route::put('/informasi/{id}', [InformasiController::class, 'update']);
    Route::delete('/informasi/{id}', [InformasiController::class, 'destroy']);
    Route::post('/informasi/{id}/read', [InformasiController::class, 'markAsRead']);

    // PROFILE
    Route::get('/profile', [ProfileController::class, 'profile']);
    Route::post('/profile/update', [ProfileController::class, 'update']);
    Route::post('/profile/password/update', [ProfileController::class, 'updatePassword']);
    Route::delete('/profile/photo', [ProfileController::class, 'deletePhoto']);
    
    // FAMILY
    Route::post('/family', [FamilyController::class, 'store']);
    Route::put('/family/{id}', [FamilyController::class, 'update']);
    Route::delete('/family/{id}', [FamilyController::class, 'destroy']);

    // USER INFO
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // PENGADUAN
    Route::post('/pengaduan', [PengaduanController::class, 'store']);
    Route::get('/pengaduan', [PengaduanController::class, 'indexWarga']);
    Route::get('/rt/pengaduan', [PengaduanController::class, 'indexRT']);
    Route::put('/rt/pengaduan/{id}/approve', [PengaduanController::class, 'approve']);
    Route::put('/rt/pengaduan/{id}/reject', [PengaduanController::class, 'reject']);
    Route::get('/security/pengaduan', [PengaduanController::class, 'indexSecurity']);
    Route::put('/security/pengaduan/{id}/feedback', [PengaduanController::class, 'feedback']);
    Route::put('/security/pengaduan/{id}/done', [PengaduanController::class, 'done']);
});