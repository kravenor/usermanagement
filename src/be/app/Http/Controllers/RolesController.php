<?php

namespace App\Http\Controllers;

use Illuminate\Database\UniqueConstraintViolationException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RolesController extends Controller
{

    /**
     * Display all roles.
     * @return JsonResponse
     */
    public function index(): JsonResponse
    {
        $roles = \App\Models\Role::all();
        return response()->json($roles);
    }

    /**
     * Show role detail by id
     *
     * @param  Request $request
     * @return JsonResponse
     */
    public function show(Request $request): JsonResponse
    {
        $role = \App\Models\Role::findOrFail($request->id);
        return response()->json($role);
    }


    /**
     * Store new role
     *
     * @param  mixed $request
     * @return JsonResponse
     */
    public function store(Request $request): JsonResponse
    {
        $role = \App\Models\Role::create($request->all());
        return response()->json($role, 201);
    }

    /**
     * Update an existing role
     *
     * @param  mixed $request
     * @return JsonResponse
     */
    public function update(Request $request): JsonResponse
    {
        $id = $request->input('id');
        $role = \App\Models\Role::findOrFail($id);
        $role->update($request->all());
        return response()->json($role);
    }


    /**
     * Destroy a role by id
     *
     * @param  mixed $request
     * @return JsonResponse
     */
    public function destroy(Request $request): JsonResponse
    {
        $id = $request->input('id');
        $role = \App\Models\Role::findOrFail($id);
        $role->delete();
        return response()->json(['message' => 'Role deleted successfully']);
    }


    /**
     * Assign Role to User
     *
     * @param  mixed $request
     * @return JsonResponse
     */
    public function assignRole(Request $request): JsonResponse
    {
        $userId = $request->input('user_id');
        $roleId = $request->input('role_id');
        try {
            $assignement = \App\Models\UserRole::create([
                'user_id' => $userId,
                'role_id' => $roleId,
            ]);
        } catch (UniqueConstraintViolationException $ue) {
            return response()->json(['error' => 'Role alredy assigned to user'], 500);
        } catch (\Exception $e) {
            return response()->json(['error' => 'An error occurred while assigning the role'], 500);
        }

        return response()->json(['message' => 'Role assigned successfully']);
    }


    /**
     * Deassign Role for user
     *
     * @param  mixed $request
     * @return JsonResponse
     */
    public function deassignRole(Request $request): JsonResponse
    {
        $userId = $request->input('user_id');
        $roleId = $request->input('role_id');

        $assignement = \App\Models\UserRole::where('user_id', $userId)->where('role_id', $roleId)->delete();

        if (!$assignement) {
            return response()->json(['error' => 'Role not assigned to user'], 404);
        }

        return response()->json(['message' => 'Role deassigned successfully']);
    }
}
