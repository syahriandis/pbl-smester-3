<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\User>
 */
class UserFactory extends Factory
{
    public function definition(): array
{
    return [
        'userID' => fake()->unique()->numerify('user###'),
        'password' => static::$password ??= Hash::make('password'),
        'name' => fake()->name(),
        'gender' => fake()->randomElement(['LAKI-LAKI', 'PEREMPUAN']),
        'phone' => fake()->phoneNumber(),
        'photo' => null,
        'role' => 'user',
    ];
}
}
