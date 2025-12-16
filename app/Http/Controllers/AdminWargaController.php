<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class AdminWargaController extends Controller
{
    /**
     * INDEX: Menampilkan daftar SEMUA warga
     */
    public function index(Request $request)
    {
        try {
            $role = ['warga','security','rt', 'rw'];

            $query = User::query();

            if ($request->has('role') && in_array($request->role, $role)) {
                $query->where('role', $request->role);
            } else {
                $query->whereIn('role', $role);
            }

            $users = $query->latest()->get();

            return response()->json([
                'success' => true,
                'message' => 'Daftar semua warga berhasil diambil',
                'data'    => $users
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data',
                'error'   => $e->getMessage()
            ], 500);
        }
    }

    /**
     * SHOW: Menampilkan detail SATU warga berdasarkan ID
     */
    public function show($id)
    {
        try {
            // Cari user berdasarkan ID
            $user = User::find($id);

            if (!$user) {
                return response()->json(['success' => false, 'message' => 'User tidak ditemukan'], 404);
            }

            if ($user->role === 'admin') {
                 return response()->json(['success' => false, 'message' => 'Akses ditolak'], 403);
            }

           return response()->json([
                'success' => true,
                'message' => 'Detail user ditemukan',
                'data'    => $user
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan server',
                'error'   => $e->getMessage()
            ], 500);
        }
    }
    /**
     * Create: Admin Membuat data warga
     */
    public function create(Request $request)
    {
        if ($request->has('gender')) {
            $request->merge([
                'gender' => strtolower($request->gender)
            ]);
        }

        // --- SECURITY LEVEL 1: VALIDASI INPUT ---
        // Kita kunci inputan agar sesuai format database dan mencegah SQL Injection
        $validator = Validator::make($request->all(), [
            'userID'   => 'required|string|unique:users,userID|max:50', // Wajib unik
            'password' => 'required|string|min:6', // Minimal 6 karakter
            'name'     => 'required|string|max:100',
            'gender'   => 'nullable|string|in:male,female', // Batasi pilihan
            'phone' => ['nullable', 'string', 'max:15', 'regex:/^(62|0)8[1-9][0-9]{6,12}$/'], // Hanya angka
            'nik' => 'nullable|digits:16',
            'photo'    => 'nullable|image|mimes:jpeg,png,jpg|max:2048', // Max 2MB
            'role' => 'required|string|in:warga,security,rt,rw',
        ]);

        // Jika validasi gagal, kembalikan 422 (Unprocessable Entity)
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Data tidak valid',
                'errors'  => $validator->errors()
            ], 422);
        }

        try {
            // Handle Upload Foto
            $photoPath = null;
            if ($request->hasFile('photo')) {
                // Simpan di folder: storage/app/public/photos
                $photoPath = $request->file('photo')->store('photos', 'public');
            }

            // Simpan Data
            $user = User::create([
                'userID'   => $request->userID,
                'password' => Hash::make($request->password), // Enkripsi Wajib!
                'name'     => $request->name,
                'gender'   => $request->gender,
                'phone'    => $request->phone,
                'nik'      => $request->nik,
                // 'photo'    => $photoPath,
                'role'     => $request->role, // Hardcode role agar admin tidak salah input
            ]);

            return response()->json([
                'success' => true,
                'message' => "Akun {$request->role} berhasil dibuat",
                'data'    => $user
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan server',
                'error'   => $e->getMessage() 
            ], 500);
        }
    }

    /**
     * UPDATE: Admin Mengubah data warga berdasarkan ID
     */

    public function update(Request $request, $id)
    {
        // 1. Cari user berdasarkan ID
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak ditemukan',
            ], 404);
        }

        // 2. Normalisasi input (sama seperti store)
        if ($request->has('gender')) {
            $request->merge(['gender' => strtolower($request->gender)]);
        }

        // 3. Validasi
        $validator = Validator::make($request->all(), [
            // unique:users,userID,'.$id  <-- Artinya: Cek unik, KECUALI punya user ini sendiri
            'userID'   => 'required|string|max:50|unique:users,userID,' . $id,
            'name'     => 'required|string|max:100',
            'gender'   => 'nullable|string|in:male,female',
            'password' => 'nullable|string|min:6', // Password jadi nullable (opsional)
            'nik' => 'nullable|numeric|max:16',
            'photo'    => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
            'role' => 'required|string|in:warga,security,rt,rw',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Data tidak valid',
                'errors'  => $validator->errors()
            ], 422);
        }

        try {
            // Persiapkan data yang akan diupdate
            $dataToUpdate = [
                'userID' => $request->userID,
                'name'   => $request->name,
                'gender' => $request->gender,
                'phone'  => $request->phone,
                'nik'    => $request->nik,
                'role' => $request->role,
            ];

            // 4. Cek apakah ada request ganti password?
            if ($request->filled('password')) {
                $dataToUpdate['password'] = Hash::make($request->password);
            }

            // 5. Cek apakah ada upload foto baru?
            if ($request->hasFile('photo')) {
                // A. Hapus foto lama jika ada (biar storage gak penuh)
                if ($user->photo && Storage::disk('public')->exists($user->photo)) {
                    Storage::disk('public')->delete($user->photo);
                }

                // B. Simpan foto baru
                $photoPath = $request->file('photo')->store('photos', 'public');
                $dataToUpdate['photo'] = $photoPath;
            }

            // 6. Lakukan Update Database
            $user->update($dataToUpdate);

            return response()->json([
                'success' => true,
                'message' => 'Data berhasil diperbarui',
                'data'    => $user
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan server',
                'error'   => $e->getMessage()
            ], 500);
        }
    }
    /**
     * DESTROY: Menghapus data warga & fotonya
     */
    public function destroy($id)
    {
        // 1. Cari user
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak ditemukan',
            ], 404);
        }

        try {
            // 2. Hapus File Foto dari Storage (PENTING: Bersih-bersih file)
            if ($user->photo && Storage::disk('public')->exists($user->photo)) {
                Storage::disk('public')->delete($user->photo);
            }

            // 3. Hapus Data dari Database
            $user->delete();

            return response()->json([
                'success' => true,
                'message' => 'Data berhasil dihapus',
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus data',
                'error'   => $e->getMessage()
            ], 500);
        }
    }
}