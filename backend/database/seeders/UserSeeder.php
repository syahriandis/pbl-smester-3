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
    'userID' => 'dwiky002',
    'password' => bcrypt('123456'),
    'name' => 'Dwikyy',
    'gender' => 'LAKI-LAKI',
    'phone' => '08123456788',
    'role' => 'warga',
]);
    }
}