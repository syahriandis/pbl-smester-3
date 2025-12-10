<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckRole
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, ...$roles): Response
    {
        // 1. Ambil User yang sedang login
        $user = $request->user();

        // 2. Cek Logika:
        // - Apakah user ada? (Sudah login)
        // - Apakah role user cocok dengan yang diminta?
        if (! $user || ! in_array($user->role, $roles)) {
            
            // Jika GAGAL (Bukan Admin), kirim error JSON (karena ini API)
            return response()->json([
                'success' => false,
                'message' => 'Akses Ditolak. Anda tidak memiliki izin (Bukan Admin).'
            ], 403); // 403 = Forbidden
        }

        // Jika LOLOS, silakan lanjut
        return $next($request);
    }
}
