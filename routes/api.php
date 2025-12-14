<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\LoginController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\FamilyController;
use App\Http\Controllers\InformasiController;
use App\Http\Controllers\JenisSuratController;
use App\Http\Controllers\SuratPengajuanController;
use App\Http\Controllers\SuratRTController;

// =========================
// LOGIN (TIDAK BUTUH TOKEN)
// =========================
Route::post('/login', [LoginController::class, 'login']);

// =========================
// JENIS SURAT (PUBLIC GET)
// =========================
Route::get('/jenis-surat', [JenisSuratController::class, 'index']);

// =========================
// ROUTE YANG BUTUH TOKEN
// =========================
Route::middleware('auth:sanctum')->group(function () {

    // ======== JENIS SURAT (RT) ========
    Route::post('/jenis-surat', [JenisSuratController::class, 'store']);
    Route::delete('/jenis-surat/{id}', [JenisSuratController::class, 'destroy']);

    // ======== SURAT WARGA (UNTUK FLUTTER WARGA) ========
    Route::get('/warga/surat', [SuratPengajuanController::class, 'indexWarga']);  // khusus warga login
    Route::post('/warga/surat', [SuratPengajuanController::class, 'store']);      // ajukan surat

    // ======== SURAT RT (LIST SEMUA SURAT UNTUK RT/RW) ========
    Route::get('/surat', [SuratRTController::class, 'index']);         // RT lihat semua
    Route::get('/rt/surat/{id}', [SuratRTController::class, 'show']);  // detail surat RT
    Route::put('/rt/surat/{id}', [SuratRTController::class, 'update']); // setujui / tolak
    Route::post('/rt/surat/{id}/upload', [SuratRTController::class, 'uploadSurat']); // upload file surat

    // ======== INFORMASI ========
    Route::get('/informasi', [InformasiController::class, 'index']);
    Route::post('/informasi', [InformasiController::class, 'store']);
    Route::put('/informasi/{id}', [InformasiController::class, 'update']);
    Route::delete('/informasi/{id}', [InformasiController::class, 'destroy']);

    // ======== PROFILE ========
    Route::get('/profile', [ProfileController::class, 'profile']);
    Route::put('/profile/password', [ProfileController::class, 'updatePassword']);

    // ======== KELUARGA ========
    Route::post('/family', [FamilyController::class, 'store']);
    Route::delete('/family/{id}', [FamilyController::class, 'destroy']);

    // ======== USER INFO ========
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
});