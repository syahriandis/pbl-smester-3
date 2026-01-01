<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Informasi;
use Illuminate\Support\Facades\Auth;

class InformasiController extends Controller
{
    /**
     * Ambil semua informasi + status baca per user login
     */
    public function index()
    {
        $userId = Auth::id();

        $informasi = Informasi::with('user')
            ->withCount([
                'readers as is_read' => function ($q) use ($userId) {
                    $q->where('user_id', $userId);
                }
            ])
            ->orderBy('date', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data'    => $informasi
        ]);
    }

    /**
     * Simpan informasi baru (RT/RW)
     */
    public function store(Request $request)
    {
        $request->validate([
            'title'       => 'required|string|max:255',
            'date'        => 'required|date',
            'day'         => 'nullable|string|max:20',
            'time'        => 'nullable|string|max:20',
            'location'    => 'required|string|max:255',
            'description' => 'nullable|string',
            'image'       => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        $path = null;
        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('informasi', 'public');
        }

        $informasi = Informasi::create([
            'user_id'     => Auth::id(),
            'title'       => $request->title,
            'description' => $request->description,
            'date'        => $request->date,
            'day'         => $request->day,
            'time'        => $request->time,
            'location'    => $request->location,
            'image'       => $path,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Informasi berhasil dibuat',
            'data'    => $informasi
        ], 201);
    }

    /**
     * Update informasi
     */
    public function update(Request $request, $id)
    {
        $informasi = Informasi::findOrFail($id);

        $request->validate([
            'title'       => 'required|string|max:255',
            'date'        => 'required|date',
            'day'         => 'nullable|string|max:20',
            'time'        => 'nullable|string|max:20',
            'location'    => 'required|string|max:255',
            'description' => 'nullable|string',
            'image'       => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('informasi', 'public');
            $informasi->image = $path;
        }

        $informasi->update($request->only([
            'title',
            'description',
            'date',
            'day',
            'time',
            'location'
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Informasi berhasil diupdate',
            'data'    => $informasi
        ]);
    }

    /**
     * Hapus informasi
     */
    public function destroy($id)
    {
        $informasi = Informasi::findOrFail($id);
        $informasi->delete();

        return response()->json([
            'success' => true,
            'message' => 'Informasi berhasil dihapus'
        ]);
    }

    /**
     * Tandai informasi sebagai dibaca oleh user login
     */
    public function markAsRead($id)
    {
        $user = Auth::user();

        $user->readInformasis()->syncWithoutDetaching([
            $id => ['read_at' => now()]
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Informasi ditandai sebagai dibaca'
        ]);
    }
}
