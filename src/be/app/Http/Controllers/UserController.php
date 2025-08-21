<?php

namespace App\Http\Controllers;

use Illuminate\Database\QueryException;
use Illuminate\Database\UniqueConstraintViolationException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserController extends Controller
{
    /**
     * Display a listing of the users.
     *
     * @return JsonResponse
     */
    public function index(): JsonResponse
    {
        $users = \App\Models\User::with('roles')->paginate(20);
        return response()->json($users);
    }

    /**
     * Display a listing of the users.
     *
     * @return JsonResponse
     */
    public function getAll(): JsonResponse
    {
        $users = \App\Models\User::with('roles')->get();
        return response()->json(["data" => $users]);
    }
    /**
     * Store a newly created user.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function store(Request $request): JsonResponse
    {
        try {
            $user = \App\Models\User::create([
                'name' => $request->input('name'),
                'email' => $request->input('email'),
                'password' => bcrypt($request->input('password')),
            ]);
            if ($request->has('roles')) {
                $user->syncRoles($request->input('roles'));
            }
        } catch (UniqueConstraintViolationException $e) {
            return response()->json(['error' => 'Email already exists'], 400);
        }
        return response()->json(['message' => 'User created successfully']);
    }


    /**
     * Show user details
     *
     * @param  mixed $request
     * @return JsonResponse
     */
    public function show(Request $request): JsonResponse
    {
        $user = \App\Models\User::findOrFail($request->id);
        if ($user->roles) {
            $user->roles = $user->roles->pluck('name');
        } else {
            $user->roles = [];
        }
        return response()->json($user);
    }

    /**
     * Update user details
     *
     * @param  mixed $request
     * @return JsonResponse
     */
    public function update(Request $request): JsonResponse
    {
        $id = $request->input('id');
        $user = \App\Models\User::findOrFail($id);
        try {
            $user->update([
                'name' => $request->input('name'),
                'email' => $request->input('email'),
                'password' => bcrypt($request->input('password')),
            ]);
            if ($request->has('roles')) {
                $user->syncRoles($request->input('roles'));
            }
        } catch (QueryException $e) {
            return response()->json(['error' => 'All fields must be filled'], 400);
        }
        return response()->json(['message' => 'User updated successfully']);
    }


    /**
     * Delete a user by id
     *
     * @param  mixed $request
     * @return JsonResponse
     */
    public function destroy(Request $request): JsonResponse
    {

        $id = $request->input('id');
        $user = \App\Models\User::findOrFail($id);
        $user->delete();
        return response()->json(['message' => 'User deleted successfully']);
    }

    /**
     * Delete a user by id
     *
     * @param  mixed $request
     * @return JsonResponse
     */
    public function destroyMultiple(Request $request): JsonResponse
    {

        $ids = $request->input('ids');
        foreach ($ids as $id) {
            try {
                $user = \App\Models\User::findOrFail($id);
            } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
                continue; // Skip if user not found
            }
            $user->delete();
        }
        return response()->json(['message' => 'User deleted successfully']);
    }
}
