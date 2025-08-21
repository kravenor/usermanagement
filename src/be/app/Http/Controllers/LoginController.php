<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LoginController extends Controller
{

    public function authenticate(Request $request): JsonResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);


        $token = Auth::attempt($credentials);
        if (!$token) {
            return response()->json(['status' => 'error', 'message' => 'Unauthorized'], 401);
        }

        return response()->json([
            'user' => Auth::user(),
            'token' => $token,
            'status' => 'success',
            'roles' => Auth::user()->role_names
        ]);
    }
    /**
     * Handle user logout.
     *
     * @return JsonResponse
     */
    public function logout(): JsonResponse
    {
        Auth::logout();
        return response()->json([
            'status' => 'success',
            'message' => 'Logout successful'
        ]);
    }


    /**
     * Refresh auth toekn
     *
     * @return JsonResponse
     */
    public function refresh(): JsonResponse
    {
        $token = Auth::refresh();
        return response()->json([
            'status' => 'success',
            'message' => 'Token refreshed successfully',
            'token' => $token,
            'user' => Auth::user(),
            'roles' => Auth::user()->role_names
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'status' => 'success',
            'token' => Auth::getToken(),
            'user' => Auth::user(),
            'roles' => Auth::user()->role_names
        ]);
    }
}
