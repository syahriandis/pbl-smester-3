<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LoginController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\FamilyController;

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