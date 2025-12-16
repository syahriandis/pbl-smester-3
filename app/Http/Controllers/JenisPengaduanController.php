<?php

namespace App\Http\Controllers;

use App\Models\JenisPengaduan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class JenisPengaduanController extends Controller
{
    protected function checkAccess(Request $request)
    {
        $user = $request->user();
        $allowedRoles = ['admin', 'rt', 'rw', 'security'];

        if (!in_array($user->role, $allowedRoles)) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak. Hanya Admin, RT, RW, dan Security yang dapat mengelola Jenis Pengaduan.'
            ], 403);
        }
        return null; // Akses diizinkan
    }

    /**
     * INDEX: Menampilkan daftar semua jenis pengaduan (Read All).
     * Akses: Admin, RT, RW, Security.
     */
    public function index(Request $request)
    {
        // Pengecekan akses di sini opsional, tapi disertakan untuk konsistensi manajemen
        $accessCheck = $this->checkAccess($request);
        if ($accessCheck) {
            return $accessCheck;
        }

        try {
            $jenis = JenisPengaduan::all();
            return response()->json([
                'success' => true,
                'message' => 'Daftar jenis pengaduan berhasil diambil',
                'data'    => $jenis
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Gagal mengambil data', 'error' => $e->getMessage()], 500);
        }
    }

    /**
     * Create: Membuat jenis pengaduan baru (Create).
     * Akses: Admin, RT, RW, Security.
     */
    public function create(Request $request)
    {
        // 🛑 Guard Clause untuk membatasi akses
        $accessCheck = $this->checkAccess($request);
        if ($accessCheck) {
            return $accessCheck;
        }

        $validator = Validator::make($request->all(), [
            'nama_jenis_pengaduan' => 'required|string|unique:jenis_pengaduans,nama_jenis_pengaduan|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $jenis = JenisPengaduan::create([
                'nama_jenis_pengaduan' => $request->nama_jenis_pengaduan,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Jenis pengaduan baru berhasil ditambahkan',
                'data'    => $jenis
            ], 201);

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Gagal menyimpan data', 'error' => $e->getMessage()], 500);
        }
    }

    /**
     * UPDATE: Mengubah jenis pengaduan berdasarkan ID (Update).
     * Akses: Admin, RT, RW, Security.
     */
    public function update(Request $request, $id)
    {
        // 🛑 Guard Clause untuk membatasi akses
        $accessCheck = $this->checkAccess($request);
        if ($accessCheck) {
            return $accessCheck;
        }

        $jenis = JenisPengaduan::find($id);

        if (!$jenis) {
            return response()->json(['success' => false, 'message' => 'Jenis pengaduan tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            // Cek unik, kecuali untuk dirinya sendiri
            'nama_jenis_pengaduan' => [
                'required', 
                'string', 
                'max:100', 
                Rule::unique('jenis_pengaduans')->ignore($jenis->id)
            ],
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        try {
            $jenis->update([
                'nama_jenis_pengaduan' => $request->nama_jenis_pengaduan,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Jenis pengaduan berhasil diperbarui',
                'data'    => $jenis
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Gagal memperbarui data', 'error' => $e->getMessage()], 500);
        }
    }

    /**
     * DESTROY: Menghapus jenis pengaduan (Delete).
     * Akses: Admin, RT, RW, Security.
     */
    public function destroy(Request $request, $id)
    {
        // 🛑 Guard Clause untuk membatasi akses
        $accessCheck = $this->checkAccess($request);
        if ($accessCheck) {
            return $accessCheck;
        }
        
        $jenis = JenisPengaduan::find($id);

        if (!$jenis) {
            return response()->json(['success' => false, 'message' => 'Jenis pengaduan tidak ditemukan'], 404);
        }

        try {
            $jenis->delete();

            return response()->json([
                'success' => true,
                'message' => 'Jenis pengaduan berhasil dihapus'
            ], 200);

        } catch (\Exception $e) {
            // Error ini muncul jika kategori masih digunakan oleh tabel 'pengaduans' (Foreign Key Constraint)
            return response()->json(['success' => false, 'message' => 'Gagal menghapus. Kategori mungkin masih digunakan.', 'error' => $e->getMessage()], 500);
        }
    }
}
