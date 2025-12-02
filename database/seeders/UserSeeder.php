<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        User::create([
            'userID' => 'dwiky',
            'password' => Hash::make('password123'),
            'name' => 'Dwiky',
            'role' => 'warga',
        ]);

        User::create([
            'userID' => 'warga',
            'password' => Hash::make('warga123'),
            'name' => 'Warga Biasa',
            'role' => 'warga',
        ]);

        User::create([
            'userID' => 'security',
            'password' => Hash::make('security123'),
            'name' => 'Petugas Security',
            'role' => 'security',
        ]);

        User::create([
            'userID' => 'rtaja',
            'password' => Hash::make('apalah123'),
            'name' => 'Ketua RT',
            'role' => 'rt',
        ]);
    }
}