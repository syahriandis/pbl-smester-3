<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run()
    {
      DB::table('users')->insert([
    [
        'userID' => 'USR001',
        'nik' => '1234567890123456',
        'name' => 'Dwiky Warga',
        'gender' => 'Laki-laki', // <- ubah dari 'L'
        'phone' => '081234567890',
        'role' => 'warga',
        'photo' => 'default.jpg',
        'password' => Hash::make('password123'),
    ],
    [
        'userID' => 'USR002',
        'nik' => '9876543210987654',
        'name' => 'Ketua RT 01',
        'gender' => 'Laki-laki',
        'phone' => '081298765432',
        'role' => 'rt',
        'photo' => 'default.jpg',
        'password' => Hash::make('password123'),
    ],
    [
        'userID' => 'USR003',
        'nik' => '1122334455667788',
        'name' => 'Ketua RW 01',
        'gender' => 'Laki-laki',
        'phone' => '081212345678',
        'role' => 'rw',
        'photo' => 'default.jpg',
        'password' => Hash::make('password123'),
    ],
    [
        'userID' => 'USR004',
        'nik' => '9988776655443322',
        'name' => 'Security',
        'gender' => 'Laki-laki',
        'phone' => '081299887766',
        'role' => 'security',
        'photo' => 'default.jpg',
        'password' => Hash::make('password123'),
    ],
]);
    }
}
