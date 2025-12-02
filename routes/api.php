<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LoginController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\FamilyController;

Route::middleware('auth:sanctum')->group(function () {
    // Profile routes
    Route::get('/profile', [ProfileController::class, 'profile']);
    Route::post('/profile/update-family', [ProfileController::class, 'updateFamily']);
    Route::post('/profile/update-password', [ProfileController::class, 'updatePassword']);

    // Family routes
    Route::post('/family', [FamilyController::class, 'store']);
    Route::delete('/family/{id}', [FamilyController::class, 'destroy']);

    // Get current authenticated user
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
});

// Login route (public)
Route::post('/login', [LoginController::class, 'login']);