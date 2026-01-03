<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;
use App\Models\User;
use Illuminate\Support\Facades\Log; 

class ProfileController extends Controller
{
    /**
     * Get user profile with families
     */
    public function profile(Request $request)
    {
         $user = $request->user()->load('families');

        // ✅ Debug
        Log::info('=== PROFILE DEBUG ===');
        Log::info('Photo value: ' . $user->photo);
        Log::info('Full path: ' . storage_path('app/public/' . $user->photo));
        Log::info('File exists: ' . (file_exists(storage_path('app/public/' . $user->photo)) ? 'YES' : 'NO'));
        $user = $request->user()->load('families');

        return response()->json([
            "success" => true,
            "data" => [
                "name" => $user->name,
                "nik" => $user->nik,
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
                })->values()->all(),
            ]
        ]);
    }

    /**
     * Update user profile (name, nik, gender, phone, address, photo)
     */
    public function update(Request $request)
    {
        $user = $request->user();

        // Validation
        $validated = $request->validate([
            'name' => 'nullable|string|max:255',
            'nik' => [
                'nullable',
                'string',
                'size:16',
                Rule::unique('users', 'nik')->ignore($user->id),
            ],
            'gender' => 'nullable|in:LAKI-LAKI,PEREMPUAN',
            'phone' => 'nullable|string|max:20',
            'address' => 'nullable|string',
            'photo' => 'nullable|image|mimes:jpeg,png,jpg|max:2048', // Max 2MB
        ]);

        // Handle photo upload
        if ($request->hasFile('photo')) {
            // Delete old photo if exists
            if ($user->photo && Storage::disk('public')->exists($user->photo)) {
                Storage::disk('public')->delete($user->photo);
            }

            // Store new photo
            $path = $request->file('photo')->store('users/photos', 'public');
            $validated['photo'] = $path;
        }

        // Update user data
        $user->update(array_filter($validated, function($value) {
            return $value !== null;
        }));

        // Reload user to get fresh data
        $user->refresh();

        return response()->json([
            "success" => true,
            "message" => "Profil berhasil diperbarui",
            "data" => [
                "name" => $user->name,
                "nik" => $user->nik,
                "gender" => $user->gender,
                "phone" => $user->phone,
                "photo" => $user->photo,
                "role" => $user->role,
                "address" => $user->address,
            ]
        ]);
    }

    /**
     * Update family data
     */
    public function updateFamily(Request $request)
    {
        $request->validate([
            "families" => "required|array",
            "families.*.nama" => "required|string|max:255",
            "families.*.hubungan" => "required|string|max:100",
            "address" => "required|string",
        ]);

        $user = $request->user()->load('families');

        // Update address
        $user->address = $request->address;
        $user->save();

        // Delete all existing families
        $user->families()->delete();

        // Create new families
        foreach ($request->families as $family) {
            $user->families()->create([
                "nama" => $family["nama"],
                "hubungan" => $family["hubungan"],
            ]);
        }

        return response()->json([
            "success" => true,
            "message" => "Data keluarga berhasil diperbarui"
        ]);
    }

    /**
     * Update password
     */
    public function updatePassword(Request $request)
    {
        $request->validate([
            'old_password' => 'required|string',
            'new_password' => 'required|string|min:6|confirmed',
        ]);

        $user = $request->user();

        // Check if old password is correct
        if (!Hash::check($request->old_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Password lama tidak sesuai'
            ], 400);
        }

        // Update password
        $user->password = Hash::make($request->new_password);
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Password berhasil diubah'
        ]);
    }

    /**
     * Delete profile photo
     */
    public function deletePhoto(Request $request)
    {
        $user = $request->user();

        if ($user->photo && Storage::disk('public')->exists($user->photo)) {
            Storage::disk('public')->delete($user->photo);
            
            $user->photo = null;
            $user->save();

            return response()->json([
                'success' => true,
                'message' => 'Foto profil berhasil dihapus'
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Foto profil tidak ditemukan'
        ], 404);
    }
    
}