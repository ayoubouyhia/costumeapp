<?php

namespace App\Http\Controllers;

use App\Models\Costume;
use Illuminate\Http\Request;

class CostumeController extends Controller
{
    /**
     * Display a listing of the resource.
     * Used for initial sync and browsing.
     */
    public function index()
    {
        // For sync purposes, we might want to support `updated_since` query param in a real app.
        // For this MVP, we return all available costumes.
        return Costume::with('category')->get();
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        return Costume::with(['category', 'rentals'])->findOrFail($id);
    }
}
