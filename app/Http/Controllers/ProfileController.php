<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use App\Models\Family;

class ProfileController extends Controller
{
    public function profile(Request $request)
    {
        $user = $request->user()->load('families');

        return response()->json([
            "success" => true,
            "data" => [
                "name" => $user->name,
                "gender" => $user->gender,
                "phone" => $user->phone,
                "photo" => $user->photo,
                "role" => $user->role,
                "address" => $user->address,
                "families" => $user->families->map(function ($f) {
                    return [
                        "id" => $f->id,
                        "nama" => $f->nama,
                        "hubungan" => $f->hubungan,
                    ];
                })->values()->all(), // ✅ penting agar Flutter bisa baca
            ]
        ]);
    }

    public function updateFamily(Request $request)
    {
        $request->validate([
            "families" => "required|array",
            "address" => "required|string",
        ]);

        $user = $request->user()->load('families');

        $user->address = $request->address;
        $user->save();

        $user->families()->delete();

        foreach ($request->families as $f) {
            $user->families()->create([
                "nama" => $f["nama"],
                "hubungan" => $f["hubungan"],
            ]);
        }

        return response()->json([
            "success" => true,
            "message" => "Data keluarga berhasil diperbarui"
        ]);
    }

    public function updatePassword(Request $request)
    {
        $request->validate([
            "password_lama" => "required",
            "password_baru" => "required|min:6",
        ]);

        $user = $request->user();

        if (!Hash::check($request->password_lama, $user->password)) {
            return response()->json([
                "success" => false,
                "message" => "Password lama salah"
            ], 400);
        }

        $user->password = Hash::make($request->password_baru);
        $user->save();

        return response()->json([
            "success" => true,
            "message" => "Password berhasil diubah"
        ]);
    }
}