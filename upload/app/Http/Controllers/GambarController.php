<?php

namespace App\Http\Controllers;

use App\Models\Gambar;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class GambarController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $gambar = Gambar::all();

        return response()->json([
            'data' => $gambar
        ]);    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
    
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validator = $request->validate(['gambar'=>'required|image|mimes:jpg,png,jpeg,webp']);
        if ($request->has('gambar')) {
            $gambar = $request->file('gambar');
            $nama_gambar = time() . rand(1, 9) . "." . $gambar->getClientOriginalExtension();
            $gambar->move('uploads', $nama_gambar);
            $validator['gambar'] = $nama_gambar;
        }
        Gambar::create($validator);
        return response()->json(['message'=> 'success']);

    }

    /**
     * Display the specified resource.
     */
    public function show(Gambar $gambar)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Gambar $gambar)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Gambar $gambar)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Gambar $gambar)
    {
        //
    }
}
