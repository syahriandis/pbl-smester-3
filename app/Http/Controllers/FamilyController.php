<?php

namespace App\Http\Controllers;
use App\Models\Family;
use Illuminate\Http\Request;
class FamilyController extends Controller
{
    // ✅ Tambah anggota keluarga
    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama' => 'required|string|max:255',
            'hubungan' => 'required|string|max:255',
        ]);

        // ✅ Ambil user dari token
        $family = $request->user()->families()->create([
            'nama' => $validated['nama'],
            'hubungan' => $validated['hubungan'],
        ]);

        return response()->json([
            'data' => [
                'id' => $family->id,
                'nama' => $family->nama,
                'hubungan' => $family->hubungan,
            ]
        ], 201);
    }

    // ✅ Hapus anggota keluarga
    public function destroy(Request $request, $id)
    {
        $family = $request->user()->families()->findOrFail($id);
        $family->delete();

        return response()->json(['message' => 'Deleted'], 200);
    }
}