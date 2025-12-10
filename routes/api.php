<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LoginController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\FamilyController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\AdminWargaController;
/*
|--------------------------------------------------------------------------
| 1. Route PUBLIC (Bisa diakses tanpa login)
|--------------------------------------------------------------------------
*/
Route::post('/login', [LoginController::class, 'login']);
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

    // Profile routes
    Route::get('/profile', [ProfileController::class, 'profile']);
    Route::post('/profile/update-family', [ProfileController::class, 'updateFamily']);
    Route::post('/profile/update-password', [ProfileController::class, 'updatePassword']);

    // Family routes
    Route::post('/family', [FamilyController::class, 'store']);
    Route::delete('/family/{id}', [FamilyController::class, 'destroy']);

    Route::middleware(['role:admin'])->group(function () {
        Route::get('admin/warga', [AdminWargaController::class, 'index']);
        Route::get('admin/warga/{id}', [AdminWargaController::class, 'show']);
        Route::post('/admin/create-warga', [AdminWargaController::class, 'create']);
        Route::put('admin/update-warga/{id}', [AdminWargaController::class, 'update']); 
        Route::delete('admin/delete-warga/{id}', [AdminWargaController::class, 'destroy']);
    });
    
});

