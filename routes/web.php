<?php
// web.php sekarang kosong atau cuma untuk web admin
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});