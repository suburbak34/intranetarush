<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/saludo', function () {
    //return "HOLA DESDE PHP LARAVEL";
      return ["Hola"];
    //return ["mensaje" => "Hola Mundo"];                   
});

Route::get('/personas', function () {
    
    $p1 = [
        "nombre" => "Mario Rivera",
        "edad" => 49,
        "direccion" => "C.Campo Bello S/N Edificio A-4 Depto 107",
        "telefono" => "+52 5530373823",
        "email" => "suburbak@hotmail.com",
    ];
    $p2 = [
        "nombre" => "Juan Prado",
        "edad" => 30,
        "direccion" => "C.Campo Bello S/N Edificio B-4 Depto 507",
        "telefono" => "+52 5595623598",
        "email" => "cmedina@arush.com.mx",];
    return [$p1, $p2];
    //return response()->json([$p1, $p2]);
    //return response()->json([$p1, $p2], 200);
    //return response()->json([$p1, $p2], 200, [], JSON_PRETTY_PRINT);
    //return response()->json([$p1, $p2], 200, [], JSON_UNESCAPED_SLASHES);
});
