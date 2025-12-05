<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Informasi;
use Illuminate\Support\Facades\Auth;
class InformasiController extends Controller
{
    // Warga melihat semua informasi dari RT/RW
    public function index()
    {
        $informasi = Informasi::with('user')
            ->orderBy('date', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $informasi
        ]);
    }

    // RT/RW membuat informasi
    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'date' => 'required|date',
            'time' => 'nullable',
            'day' => 'nullable|string|max:20',
            'location' => 'required|string|max:255',
            'description' => 'nullable|string',
            'image' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        $path = null;
        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('informasi', 'public');
        }

        $informasi = Informasi::create([
            'user_id' => Auth::id(),
            'title' => $request->title,
            'date' => $request->date,
            'time' => $request->time,
            'day' => $request->day,
            'location' => $request->location,
            'description' => $request->description,
            'image' => $path ? asset('storage/'.$path) : null,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Informasi berhasil dibuat',
            'data' => $informasi
        ]);
    }

    // RT/RW mengedit informasi
    public function update(Request $request, $id)
    {
        $informasi = Informasi::findOrFail($id);

        $request->validate([
            'title' => 'required|string|max:255',
            'date' => 'required|date',
            'time' => 'nullable',
            'day' => 'nullable|string|max:20',
            'location' => 'required|string|max:255',
            'description' => 'nullable|string',
            'image' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('informasi', 'public');
            $informasi->image = asset('storage/'.$path);
        }

        $informasi->update($request->only([
            'title', 'date', 'time', 'day', 'location', 'description'
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Informasi berhasil diupdate',
            'data' => $informasi
        ]);
    }

    // RT/RW menghapus informasi
    public function destroy($id)
    {
        $informasi = Informasi::findOrFail($id);
        $informasi->delete();

        return response()->json([
            'success' => true,
            'message' => 'Informasi berhasil dihapus'
        ]);
    }
}