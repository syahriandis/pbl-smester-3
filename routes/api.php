<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Response;

use App\Http\Controllers\LoginController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\FamilyController;
use App\Http\Controllers\InformasiController;
use App\Http\Controllers\JenisSuratController;
use App\Http\Controllers\SuratPengajuanController;
use App\Http\Controllers\SuratRTController;
use App\Http\Controllers\PengaduanController;
use App\Http\Controllers\SuratFileController;

// =========================
// PUBLIC ROUTES (TANPA TOKEN)
// =========================

// Login
Route::post('/login', [LoginController::class, 'login']);

// Jenis Surat (public)
Route::get('/jenis-surat', [JenisSuratController::class, 'index']);

// ✅ Storage untuk image informasi (PUBLIC - CORS handled)
Route::get('/storage/{path}', function ($path) {
    $file = Storage::disk('public')->path($path);
    
    if (!file_exists($file)) {
        abort(404);
    }

    return Response::file($file, [
        'Content-Type' => mime_content_type($file),
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, OPTIONS',
        'Access-Control-Allow-Headers' => '*',
    ]);
})->where('path', '.*');

// ✅ Surat Preview & Download (PUBLIC - biar warga bisa akses tanpa login)
Route::get('/surat/preview/{filename}', [SuratFileController::class, 'preview']);
Route::get('/surat/download/{filename}', [SuratFileController::class, 'download']);

// =========================
// PROTECTED ROUTES (BUTUH TOKEN)
// =========================
Route::middleware('auth:sanctum')->group(function () {

    // ======== JENIS SURAT (RT) ========
    Route::post('/jenis-surat', [JenisSuratController::class, 'store']);
    Route::delete('/jenis-surat/{id}', [JenisSuratController::class, 'destroy']);

    // ======== SURAT WARGA ========
    Route::get('/warga/surat', [SuratPengajuanController::class, 'indexWarga']);
    Route::post('/warga/surat', [SuratPengajuanController::class, 'store']);

    // ======== SURAT RT ========
    Route::get('/rt/surat', [SuratRTController::class, 'index']);
    Route::get('/rt/surat/{id}', [SuratRTController::class, 'show']);
    Route::put('/rt/surat/{id}', [SuratRTController::class, 'update']);
    Route::post('/rt/surat/{id}/upload', [SuratRTController::class, 'uploadSurat']);

    // ======== INFORMASI ========
    Route::get('/informasi', [InformasiController::class, 'index']);
    Route::post('/informasi', [InformasiController::class, 'store']);
    Route::put('/informasi/{id}', [InformasiController::class, 'update']);
    Route::delete('/informasi/{id}', [InformasiController::class, 'destroy']);
    Route::post('/informasi/{id}/read', [InformasiController::class, 'markAsRead']);
    // ======== PROFILE ========
    Route::get('/profile', [ProfileController::class, 'profile']);
    Route::put('/profile/password', [ProfileController::class, 'updatePassword']);
    Route::put('/profile', [ProfileController::class, 'update']);

    // ======== FAMILY ========
    Route::post('/family', [FamilyController::class, 'store']);
    Route::delete('/family/{id}', [FamilyController::class, 'destroy']);

    // ======== USER INFO ========
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // ======== PENGADUAN ========
    // Warga
    Route::post('/pengaduan', [PengaduanController::class, 'store']);
    Route::get('/pengaduan', [PengaduanController::class, 'indexWarga']);

    // RT
    Route::get('/rt/pengaduan', [PengaduanController::class, 'indexRT']);
    Route::put('/rt/pengaduan/{id}/approve', [PengaduanController::class, 'approve']);
    Route::put('/rt/pengaduan/{id}/reject', [PengaduanController::class, 'reject']);

    // Security
    Route::get('/security/pengaduan', [PengaduanController::class, 'indexSecurity']);
    Route::put('/security/pengaduan/{id}/feedback', [PengaduanController::class, 'feedback']);
    Route::put('/security/pengaduan/{id}/done', [PengaduanController::class, 'done']);
});