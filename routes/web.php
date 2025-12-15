<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\SuratFileController;

Route::get('/surat/preview/{filename}', [SuratFileController::class, 'preview']);
Route::get('/surat/download/{filename}', [SuratFileController::class, 'download']);