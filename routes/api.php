<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LoginController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\FamilyController;
use App\Http\Controllers\InformasiController;

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/informasi', [InformasiController::class, 'index']);   // warga lihat
    Route::post('/informasi', [InformasiController::class, 'store']);  // RT/RW buat
    Route::put('/informasi/{id}', [InformasiController::class, 'update']); // RT/RW edit
    Route::delete('/informasi/{id}', [InformasiController::class, 'destroy']); // RT/RW hapus
});

Route::middleware('auth:sanctum')->group(function () {

    // RT / RW dapat membuat & menghapus
    Route::post('/informasi', [InformasiController::class, 'store']);
    Route::delete('/informasi/{id}', [InformasiController::class, 'destroy']);

    // Semua role bisa lihat
    Route::get('/informasi', [InformasiController::class, 'index']);
    Route::get('/informasi/{id}', [InformasiController::class, 'show']);
});

Route::middleware('auth:sanctum')->group(function () {

    Route::get('/profile', [ProfileController::class, 'profile']);
    Route::post('/profile/update-family', [ProfileController::class, 'updateFamily']);

    Route::post('/family', [FamilyController::class, 'store']);
    Route::delete('/family/{id}', [FamilyController::class, 'destroy']);

    Route::put('/profile/password', [ProfileController::class, 'updatePassword'])->middleware('auth:sanctum');

    Route::get('/user', function (Request $request) {
        return $request->user();
    });
});




Route::post('/login', [LoginController::class, 'login']);