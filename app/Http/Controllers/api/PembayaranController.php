<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Pembayaran;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class PembayaranController extends Controller
{
    // Get status pembayaran bulan ini untuk user yang login
    public function statusBulanIni(Request $request)
    {
        $user = $request->user();
        $bulan = date('n'); // bulan sekarang
        $tahun = date('Y'); // tahun sekarang

        $pembayaran = Pembayaran::where('user_id', $user->id)
            ->byPeriode($bulan, $tahun)
            ->first();

        if (!$pembayaran) {
            // Auto create record jika belum ada
            $pembayaran = Pembayaran::create([
                'user_id' => $user->id,
                'role' => $user->role,
                'bulan' => $bulan,
                'tahun' => $tahun,
                'status' => 'belum_bayar',
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => $pembayaran
        ]);
    }

    // Upload bukti pembayaran
    public function uploadBukti(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'bulan' => 'required|integer|min:1|max:12',
            'tahun' => 'required|integer|min:2024',
            'metode_pembayaran' => 'required|in:qris,transfer',
            'bukti_pembayaran' => 'required|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();
        $bulan = $request->bulan;
        $tahun = $request->tahun;

        // Cek atau create pembayaran
        $pembayaran = Pembayaran::where('user_id', $user->id)
            ->byPeriode($bulan, $tahun)
            ->first();

        if (!$pembayaran) {
            $pembayaran = new Pembayaran([
                'user_id' => $user->id,
                'role' => $user->role,
                'bulan' => $bulan,
                'tahun' => $tahun,
            ]);
        }

        // Upload file
        if ($request->hasFile('bukti_pembayaran')) {
            // Hapus file lama jika ada
            if ($pembayaran->bukti_pembayaran) {
                Storage::disk('public')->delete($pembayaran->bukti_pembayaran);
            }

            $file = $request->file('bukti_pembayaran');
            $filename = 'pembayaran_' . $user->id . '_' . $bulan . '_' . $tahun . '_' . time() . '.' . $file->getClientOriginalExtension();
            $path = $file->storeAs('bukti_pembayaran', $filename, 'public');

            $pembayaran->bukti_pembayaran = $path;
        }

        $pembayaran->metode_pembayaran = $request->metode_pembayaran;
        $pembayaran->status = 'menunggu_verifikasi';
        $pembayaran->tanggal_bayar = now();
        $pembayaran->save();

        return response()->json([
            'success' => true,
            'message' => 'Bukti pembayaran berhasil diupload. Menunggu verifikasi admin.',
            'data' => $pembayaran
        ]);
    }

    // Get riwayat pembayaran user
    public function riwayat(Request $request)
    {
        $user = $request->user();
        
        $riwayat = Pembayaran::where('user_id', $user->id)
            ->orderBy('tahun', 'desc')
            ->orderBy('bulan', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $riwayat
        ]);
    }

    // Get detail pembayaran
    public function detail(Request $request, $id)
    {
        $user = $request->user();
        
        $pembayaran = Pembayaran::where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (!$pembayaran) {
            return response()->json([
                'success' => false,
                'message' => 'Pembayaran tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $pembayaran
        ]);
    }

    // === ADMIN ENDPOINTS (untuk web admin) ===
    
    // Get semua pembayaran (untuk admin)
    public function adminIndex(Request $request)
    {
        $bulan = $request->input('bulan', date('n'));
        $tahun = $request->input('tahun', date('Y'));
        $status = $request->input('status');
        $role = $request->input('role');

        $query = Pembayaran::with('user')
            ->byPeriode($bulan, $tahun);

        if ($status) {
            $query->byStatus($status);
        }

        if ($role) {
            $query->where('role', $role);
        }

        $pembayaran = $query->orderBy('status', 'asc')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $pembayaran
        ]);
    }

    // Verifikasi pembayaran (untuk admin)
    public function adminVerifikasi(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'status' => 'required|in:sudah_bayar,ditolak',
            'catatan_admin' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $pembayaran = Pembayaran::findOrFail($id);
        $pembayaran->status = $request->status;
        $pembayaran->catatan_admin = $request->catatan_admin;
        $pembayaran->tanggal_verifikasi = now();
        $pembayaran->save();

        return response()->json([
            'success' => true,
            'message' => 'Status pembayaran berhasil diupdate',
            'data' => $pembayaran
        ]);
    }

    // Statistik pembayaran (untuk admin)
    public function adminStatistik(Request $request)
    {
        $bulan = $request->input('bulan', date('n'));
        $tahun = $request->input('tahun', date('Y'));

        $total = Pembayaran::byPeriode($bulan, $tahun)->count();
        $sudah_bayar = Pembayaran::byPeriode($bulan, $tahun)->byStatus('sudah_bayar')->count();
        $menunggu = Pembayaran::byPeriode($bulan, $tahun)->byStatus('menunggu_verifikasi')->count();
        $belum_bayar = Pembayaran::byPeriode($bulan, $tahun)->byStatus('belum_bayar')->count();

        return response()->json([
            'success' => true,
            'data' => [
                'bulan' => $bulan,
                'tahun' => $tahun,
                'total' => $total,
                'sudah_bayar' => $sudah_bayar,
                'menunggu_verifikasi' => $menunggu,
                'belum_bayar' => $belum_bayar,
                'total_nominal' => $sudah_bayar * 110000,
            ]
        ]);
    }
}