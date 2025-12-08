<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LoginController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\FamilyController;

use App\Http\Controllers\InformasiController;

// Semua route ini butuh autentikasi (token)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/informasi', [InformasiController::class, 'index']);
    Route::post('/informasi', [InformasiController::class, 'store']);
    Route::put('/informasi/{id}', [InformasiController::class, 'update']);
    Route::delete('/informasi/{id}', [InformasiController::class, 'destroy']);
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