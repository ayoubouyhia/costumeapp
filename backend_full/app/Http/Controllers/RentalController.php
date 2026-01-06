<?php

namespace App\Http\Controllers;

use App\Models\Costume;
use App\Models\Rental;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class RentalController extends Controller
{
    /**
     * Store a newly created rental in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'costume_id' => 'required|exists:costumes,id',
            'start_date' => 'required|date|after_or_equal:today',
            'expected_return_date' => 'required|date|after:start_date',
        ]);

        $costume = Costume::findOrFail($request->costume_id);

        if (!$costume->is_available) {
            return response()->json(['message' => 'Costume is not available'], 400);
        }

        $rental = Rental::create([
            'user_id' => Auth::id(),
            'costume_id' => $costume->id,
            'start_date' => $request->start_date,
            'expected_return_date' => $request->expected_return_date,
            'total_price' => $costume->price, // Simple logic: flat price per rental for now
        ]);

        // Mark costume as unavailable
        $costume->update(['is_available' => false]);

        return response()->json($rental, 201);
    }

    /**
     * Store a guest rental (from mobile app).
     */
    public function storeGuest(Request $request)
    {
        $request->validate([
            'costume_id' => 'required|exists:costumes,id',
            'start_date' => 'required|date|after_or_equal:today',
            'expected_return_date' => 'required|date|after:start_date',
            'guest_name' => 'required|string',
            'guest_phone' => 'required|string',
            'guest_address' => 'required|string',
        ]);

        $costume = Costume::findOrFail($request->costume_id);

        if (!$costume->is_available) {
            return response()->json(['message' => 'Costume is not available'], 400);
        }

        $rental = Rental::create([
            'user_id' => null, // No user for guest checkout
            'guest_name' => $request->guest_name,
            'guest_phone' => $request->guest_phone,
            'guest_address' => $request->guest_address,
            'costume_id' => $costume->id,
            'start_date' => $request->start_date,
            'expected_return_date' => $request->expected_return_date,
            'total_price' => $costume->price, // Flat price logic
        ]);

        // Mark costume as unavailable
        $costume->update(['is_available' => false]);

        return response()->json($rental, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        $rental = Rental::with(['costume', 'user'])->findOrFail($id);

        if ($rental->user_id !== Auth::id()) { // Simple auth check
             return response()->json(['message' => 'Unauthorized'], 403);
        }

        return $rental;
    }
}
