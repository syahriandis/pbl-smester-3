<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\FamilyController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\AdminWargaController;
use App\Http\Controllers\PengaduanController;
use App\Http\Controllers\JenisPengaduanController;
/*
|--------------------------------------------------------------------------
| 1. Route PUBLIC (Bisa diakses tanpa login)
|--------------------------------------------------------------------------
*/
Route::post('/login', [AuthController::class, 'login']);
/*
|--------------------------------------------------------------------------
| 2. Route PROTECTED (Harus Login / Punya Token)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {
    // Get current authenticated user
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    Route::post('/logout', [AuthController::class, 'logout']);

    //Jenis Pengaduan Routes
    Route::prefix('jenis-pengaduan')->group(function () {
        Route::get('/', [JenisPengaduanController::class, 'index']); 
        Route::post('/', [JenisPengaduanController::class, 'create']); 
        Route::put('/{id}', [JenisPengaduanController::class, 'update']); 
        Route::delete('/{id}', [JenisPengaduanController::class, 'destroy']); 
    });

    //Pengaduan Routes
    Route::prefix('pengaduan')->group(function() {
        Route::get('/', [PengaduanController::class, 'index']);
        Route::post('/', [PengaduanController::class, 'create']);
        Route::get('/{id}', [PengaduanController::class, 'show']);
        Route::delete('/{id}', [PengaduanController::class, 'destroy']); 
        Route::put('/{id}/status', [PengaduanController::class, 'updateStatus']);
    });


    // Profile routes
    Route::get('/profile', [ProfileController::class, 'profile']);
    Route::post('/profile/update-family', [ProfileController::class, 'updateFamily']);
    Route::post('/profile/update-password', [ProfileController::class, 'updatePassword']);

    // Family routes
    Route::post('/family', [FamilyController::class, 'store']);
    Route::delete('/family/{id}', [FamilyController::class, 'destroy']);

    //Admin Routes
    Route::middleware(['role:admin'])->group(function () {
        Route::get('admin/user', [AdminWargaController::class, 'index']);
        Route::get('admin/user/{id}', [AdminWargaController::class, 'show']);
        Route::post('/admin/create-user', [AdminWargaController::class, 'create']);
        Route::put('admin/update-user/{id}', [AdminWargaController::class, 'update']); 
        Route::delete('admin/delete-user/{id}', [AdminWargaController::class, 'destroy']);
    });
    
});

