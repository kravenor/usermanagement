<?php

namespace Database\Seeders;

use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class RolesSeeder extends Seeder
{
    /**
     * Seed the application's database with roles.
     */
    public function run(): void
    {
        // Example roles, you can modify this as per your requirements
        $roles = [
            ['name' => 'admin', 'description' => 'Administrator with full access'],
            ['name' => 'editor', 'description' => 'Editor with limited access'],
            ['name' => 'viewer', 'description' => 'Viewer with read-only access']
        ];

        foreach ($roles as $role) {
            \App\Models\Role::create($role);
        }
    }
}
