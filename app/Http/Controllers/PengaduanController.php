<?php

namespace App\Http\Controllers;

use App\Models\Pengaduan;
use App\Models\JenisPengaduan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class PengaduanController extends Controller
{
    public function index(Request $request)
    {
        try {
            $user = $request->user();

            // Load data beserta relasi user (pelapor) dan jenis pengaduan (kategori)
            // Kita select field user tertentu saja biar data tidak terlalu berat
            $query = Pengaduan::with(['user:id,name,role,phone,address', 'jenisPengaduan']);

            // LOGIKA FILTER:
            // Jika Warga -> Tampilkan hanya miliknya
            if ($user->role === 'warga') {
                $query->where('id_user', $user->id);
            }
            // Jika Admin/RT/RW/Security -> Tampilkan semua (Otomatis)

            $data = $query->latest()->get();

            return response()->json([
                'success' => true,
                'message' => 'List pengaduan berhasil diambil',
                'data'    => $data
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false, 
                'message' => 'Error', 
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * POST: Buat Pengaduan Baru
     */
    public function create(Request $request)
    {
        $user = $request->user();

        // 🛑 GUARD CLAUSE: HANYA WARGA
        if ($user->role !== 'warga') {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak. Hanya Warga yang dapat membuat pengaduan.'
            ], 403);
        }

        // Validasi Input
        $validator = Validator::make($request->all(), [
            'id_jenis_pengaduan' => 'required|exists:jenis_pengaduans,id', // Harus ada di tabel master
            'isi_pengaduan'      => 'required|string',
            // 'foto_bukti'         => 'nullable|image|mimes:jpeg,png,jpg|max:5120', // Max 5MB
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false, 
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            // Handle Upload Foto
            $photoPath = null;
            if ($request->hasFile('foto_bukti')) {
                // Simpan di folder public/storage/pengaduan-images
                $photoPath = $request->file('foto_bukti')->store('pengaduan-images', 'public');
            }

            // Simpan ke Database
            $pengaduan = Pengaduan::create([
                'id_user'            => $request->user()->id, // Ambil ID user yang sedang login
                'id_jenis_pengaduan' => $request->id_jenis_pengaduan,
                'isi_pengaduan'      => $request->isi_pengaduan,
                // 'foto_bukti'         => $photoPath,
                'status_pengaduan'   => 'pending', // Default
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Pengaduan berhasil dikirim',
                'data'    => $pengaduan
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false, 
                'message' => 'Gagal membuat pengaduan', 
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * GET: Detail satu pengaduan
     */
    public function show($id)
    {
        $pengaduan = Pengaduan::with([
            'user:id,name,phone,address', 'jenisPengaduan'
            ])->find($id);

        if (!$pengaduan) {
            return response()->json([
                'success' => false, 
                'message' => 'Data tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true, 
            'data' => $pengaduan
        ]);
    }

    /**
     * PUT: Update Status (Khusus Admin/RT/RW/Security)
     */
    public function updateStatus(Request $request, $id)
    {
        $user = $request->user();
        $allowedRoles = ['security', 'rt', 'rw'];
        
        // 🛑 GUARD CLAUSE: HANYA SECURITY, RT, RW
        if (!in_array($user->role, $allowedRoles)) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak. Hanya Security, RT, dan RW yang dapat memproses pengaduan.'
            ], 403);
        }

        // 1. Validasi Input Status
        $validator = Validator::make($request->all(), [
            'status_pengaduan' => ['required', Rule::in(['pending', 'proses', 'selesai', 'ditolak'])]
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false, 
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $pengaduan = Pengaduan::find($id);
            if (!$pengaduan) {
                return response()->json([
                    'success' => false, 
                    'message' => 'Data tidak ditemukan'
                ], 404);
            }

            // 3. Update Status
            $pengaduan->update([
                'status_pengaduan' => $request->status_pengaduan
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Status pengaduan berhasil diperbarui jadi ' . $request->status_pengaduan,
                'data'    => $pengaduan
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false, 
                'message' => 'Error', 
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * DELETE: Hapus Pengaduan
     */
    public function destroy(Request $request, $id)
    {
        $pengaduan = Pengaduan::find($id);

        if (!$pengaduan) {
            return response()->json([
                'success' => false, 
                'message' => 'Data tidak ditemukan'
            ], 404);
        }

        // Cek Hak Akses: Hanya pembuat laporan atau Admin yang boleh hapus
        // (Opsional, tergantung kebijakanmu)
        if ($request->user()->role === 'warga' && $pengaduan->id_user !== $request->user()->id) {
            return response()->json([
                'success' => false, 
                'message' => 'Tidak punya akses hapus data ini'
            ], 403);
        }

        // Hapus file gambar dari storage biar server gak penuh
        if ($pengaduan->foto_bukti && Storage::disk('public')->exists($pengaduan->foto_bukti)) {
            Storage::disk('public')->delete($pengaduan->foto_bukti);
        }

        $pengaduan->delete();

        return response()->json([
            'success' => true, 
            'message' => 'Pengaduan berhasil dihapus'
        ]);
    }
}
