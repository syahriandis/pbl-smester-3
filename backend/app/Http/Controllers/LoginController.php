<?php

namespace App\Http\Controllers;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class LoginController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'userID' => 'required|string',
            'password' => 'required|string',
        ]);

        $user = User::where('userID', $request->userID)->first();

        if (!$user) {
            return response()->json(['message' => 'User ID tidak ditemukan'], 404);
        }

        if (!Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Password salah'], 401);
        }

        $token = $user->createToken('authToken')->plainTextToken;

        return response()->json([
            'message' => 'Login berhasil',
            'token'   => $token,
            'role'    => $user->role,
            'user'    => [
                'userID' => $user->userID,
                'name'   => $user->name,
            ],
        ], 200);
    }
}