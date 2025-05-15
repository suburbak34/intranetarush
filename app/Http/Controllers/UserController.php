<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class UserController extends Controller
{
    public function funListar()
    {
        $usuarios = DB::select('SELECT * FROM users');
        //$usuarios = DB::table('users')->get();
        //$usuarios = User::get();
        return $usuarios;
    }

    public function funGuardar(Request $request)
    {
        $nombre = $request->name;
        $email = $request->email;
        $password = $request->password;

        $usuario = new User ();
        $usuario->name = $nombre;
        $usuario->email = $email;
        $usuario->password = $password;
        $usuario->save();
        return response()->json(['message' => 'Usuario Registrado en la base de datos']);
    }

    public function funMostrar(Request $request, $id)
    {
        
        $usuario = User::findOrFail($id);
        return response()->json($usuario, 200);
    }


    public function funModificar(Request $request, $id)
    {
        $nombre = $request->name;
        $email = $request->email;
        $password = $request->password;

        $usuario = User::findOrFail($id);
        $usuario->name = $request->name;
        $usuario->email = $request->email;
        $usuario->password = $request->password;
        $usuario->update();

        return response()->json(['message' => 'Usuario Modificado'], 201);
    }
    

    public function funEliminar($id)
    {
        $usuario = User::findOrFail($id);
        $usuario->delete();
        return response()->json(['message' => 'Usuario Eliminado'], 200);
    }
}
