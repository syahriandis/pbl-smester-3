<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Pengaduan;

class PengaduanController extends Controller
{
    // ========== WARGA ==========
    // Kirim pengaduan baru
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'location' => 'nullable|string|max:255',
            'description' => 'required|string',
            'image' => 'nullable|image|max:2048',
        ]);

        $validated['user_id'] = $request->user()->id;
        $validated['status'] = 'pending';

        if ($request->hasFile('image')) {
            $validated['image'] = $request->file('image')->store('pengaduan', 'public');
        }

        $pengaduan = Pengaduan::create($validated);

        return response()->json([
            'message' => 'Pengaduan berhasil dikirim',
            'data' => $pengaduan
        ], 201);
    }

    // Warga lihat daftar pengaduan miliknya
    public function indexWarga(Request $request)
    {
        $pengaduan = Pengaduan::where('user_id', $request->user()->id)
            ->latest()->get();

        return response()->json(['data' => $pengaduan]);
    }

    // ========== RT ==========
    // RT lihat daftar pengaduan pending
    public function indexRT()
    {
        $pengaduan = Pengaduan::where('status', 'pending')
            ->latest()->get();

        return response()->json(['data' => $pengaduan]);
    }

    public function approve($id)
    {
        $pengaduan = Pengaduan::findOrFail($id);
        $pengaduan->status = 'approved';
        $pengaduan->save();

        return response()->json([
            'message' => 'Pengaduan disetujui RT',
            'data' => $pengaduan
        ]);
    }

    public function reject($id)
    {
        $pengaduan = Pengaduan::findOrFail($id);
        $pengaduan->status = 'rejected';
        $pengaduan->save();

        return response()->json([
            'message' => 'Pengaduan ditolak RT',
            'data' => $pengaduan
        ]);
    }

    // ========== SECURITY ==========
    // Security lihat daftar pengaduan (approved, in_progress, done, rejected)
    public function indexSecurity()
    {
        $pengaduan = Pengaduan::whereIn('status', [
                'approved',
                'in_progress',
                'done',
                'rejected'
            ])
            ->latest()->get();

        return response()->json(['data' => $pengaduan]);
    }

    // Security kasih feedback → status jadi in_progress
    public function feedback(Request $request, $id)
    {
        $validated = $request->validate([
            'feedback' => 'required|string',
        ]);

        $pengaduan = Pengaduan::findOrFail($id);
        $pengaduan->status = 'in_progress';
        $pengaduan->feedback = $validated['feedback'];
        $pengaduan->save();

        return response()->json([
            'message' => 'Feedback ditambahkan',
            'data' => $pengaduan
        ]);
    }

    // Security tandai selesai → status jadi done
    public function done($id)
    {
        $pengaduan = Pengaduan::findOrFail($id);
        $pengaduan->status = 'done';
        $pengaduan->save();

        return response()->json([
            'message' => 'Pengaduan selesai ditangani',
            'data' => $pengaduan
        ]);
    }
}