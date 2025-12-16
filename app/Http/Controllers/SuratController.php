<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Surat;
use App\Models\JenisSurat;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Carbon\Carbon;

class SuratController extends Controller
{
   /**
     * GET: Lihat semua surat (Otomatis filter berdasarkan Role)
     */
    public function index(Request $request) {
        try {
            $user = $request->user(); // Ambil user dari token

            // Siapkan query dengan relasi
            $query = Surat::with(['pengaju:id,name,role,phone,address', 'jenisSurat', 'penyetuju:id,name']);

            // LOGIKA FILTER:
            // Jika Warga -> Tampilkan hanya miliknya
            if ($user->role === 'warga') {
                $query->where('id_user', $user->id);
            }
            // Jika RT/RW -> Tampilkan semua (bisa ditambah filter khusus RT/RW jika perlu)
            // else { // Admin/RT/RW melihat semua }

            $surats = $query->orderBy('created_at', 'desc')->get();
                        
            return response()->json([
                'success' => true,
                'message' => 'List surat berhasil diambil',
                'data'    => $surats
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
     * POST: Ajukan Surat Baru (Khusus Warga)
     */
    public function create(Request $request) {
        $user = $request->user();

        if ($user->role !== 'warga') {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak. Hanya Warga yang dapat mengajukan surat.'
            ], 403);
        }

        // 1. Validasi Input
        $validator = Validator::make($request->all(), [
            'id_jenis_surat' => 'required|exists:jenis_surats,id_jenis_surat',
            'keterangan'     => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors'  => $validator->errors()
            ], 422);
        }

        try {
            // 2. Simpan ke Database
            $surat = Surat::create([
                'id_user'           => $user->id,
                'id_jenis_surat'    => $request->id_jenis_surat,
                'status_surat'      => 'Pending',  // Default status
                'tanggal_pengajuan' => Carbon::now(),
                'keterangan'        => $request->keterangan,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Surat berhasil diajukan',
                'data'    => $surat
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengajukan surat',
                'error'   => $e->getMessage()
            ], 500);
        }
    }

    /**
     * PUT: Verifikasi Surat (Khusus RT/RW)
     */
    public function verifikasi(Request $request, $id_surat){
        $user = $request->user();
        
        // Daftar role yang boleh memverifikasi surat
        $allowedRoles = ['rt', 'rw', 'admin']; 

        // 🛑 GUARD CLAUSE: CEK ROLE
        if (!in_array($user->role, $allowedRoles)) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak. Hanya RT/RW yang dapat memverifikasi surat.'
            ], 403);
        }

        // 1. Validasi Input Status
        $validator = Validator::make($request->all(), [
            'status_surat' => ['required', Rule::in(['Disetujui', 'Ditolak', 'Pending'])]
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors'  => $validator->errors()
            ], 422);
        }

        try {
            $surat = Surat::find($id_surat);

            if(!$surat) {
                return response()->json([
                    'success' => false,
                    'message' => 'Surat tidak ditemukan'
                ], 404);
            }

            // 2. Update Status & Penyetuju
            $surat->update([
                'status_surat'   => $request->status_surat,
                'disetujui_oleh' => $user->id
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Status surat berhasil diubah menjadi ' . $request->status_surat,
                'data'    => $surat
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memverifikasi surat',
                'error'   => $e->getMessage()
            ], 500);
        }
    }

    /**
     * GET: Detail satu surat (Opsional)
     */
    public function show($id)
    {
        try {
            $surat = Surat::with(['pengaju', 'jenisSurat', 'penyetuju'])->find($id);

            if (!$surat) {
                return response()->json([
                    'success' => false, 
                    'message' => 'Data tidak ditemukan'
                ], 404);
            }

            return response()->json([
                'success' => true, 
                'data'    => $surat
            ]);
        } catch (\Exception $e) {
            return response()->json(['success'=>false, 'message'=>'Error'], 500);
        }
    }
}
