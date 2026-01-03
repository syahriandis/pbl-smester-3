<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Pengaduan;

class PengaduanController extends Controller
{
  // Create pengaduan baru (warga)
public function store(Request $request)
{
    $validated = $request->validate([
        'title' => 'required|string|max:255',
        'location' => 'required|string|max:255',
        'description' => 'required|string',
        'image' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
    ]);

    $imagePath = null;
    if ($request->hasFile('image')) {
        $imagePath = $request->file('image')->store('pengaduan', 'public');
    }

    $pengaduan = Pengaduan::create([
        'user_id' => $request->user()->id,
        'title' => $validated['title'],
        'location' => $validated['location'],
        'description' => $validated['description'],
        'image' => $imagePath,
        'status' => 'pending',
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Pengaduan berhasil dikirim',
        'data' => [
            'id' => $pengaduan->id,
            'title' => $pengaduan->title,
            'location' => $pengaduan->location,
            'description' => $pengaduan->description,
            'image' => $pengaduan->image ? 'api/pengaduan/' . basename($pengaduan->image) : null, // ✅ Tambah api/ prefix
            'status' => $pengaduan->status,
            'created_at' => $pengaduan->created_at->format('Y-m-d H:i'),
        ]
    ], 201);
}

    // Warga lihat daftar pengaduan miliknya
   // Warga lihat daftar pengaduan miliknya
public function indexWarga(Request $request)
{
    $pengaduan = Pengaduan::where('user_id', $request->user()->id)
        ->latest()->get();

    return response()->json([
        'data' => $pengaduan->map(function ($p) {
            return [
                'id' => $p->id,
                'title' => $p->title,
                'location' => $p->location,
                'description' => $p->description,
                'image' => $p->image ? 'api/pengaduan/' . basename($p->image) : null, // ✅ Tambah api/ prefix
                'status' => $p->status,
                'feedback' => $p->feedback,
                'created_at' => $p->created_at->format('Y-m-d H:i'),
                'updated_at' => $p->updated_at->format('Y-m-d H:i'),
            ];
        })
    ]);
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