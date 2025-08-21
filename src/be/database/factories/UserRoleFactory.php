<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\UserRole>
 */
class UserRoleFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $userId = \App\Models\User::inRandomOrder()->first()?->id ?? null;
        $roleId = \App\Models\Role::inRandomOrder()->first()?->id ?? null;
        if (!$userId || !$roleId) {
            // If no user or role exists, create them
            $userId = \App\Models\User::factory()->create()->id;
            $roleId = \App\Models\Role::factory()->create()->id;
        }
        return [
            'user_id' => $userId,
            'role_id' => $roleId,
        ];
    }
}
