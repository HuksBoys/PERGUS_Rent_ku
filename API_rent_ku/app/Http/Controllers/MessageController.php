<?php

namespace App\Http\Controllers;

use App\Models\Message;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MessageController extends Controller
{
    /**
     * Ambil daftar chat (khusus admin melihat daftar user, user melihat daftar admin)
     */
    public function chatList(Request $request)
    {
        $userId = $request->user()->id;

        // Ambil ID user lain yang pernah berkomunikasi dengan kita
        $messages = Message::where('sender_id', $userId)
            ->orWhere('receiver_id', $userId)
            ->orderBy('created_at', 'desc')
            ->get();

        $otherUserIds = [];
        foreach ($messages as $msg) {
            $otherId = ($msg->sender_id == $userId) ? $msg->receiver_id : $msg->sender_id;
            if (!in_array($otherId, $otherUserIds)) {
                $otherUserIds[] = $otherId;
            }
        }

        $users = User::whereIn('id', $otherUserIds)->get();

        // Tambahkan info pesan terakhir dan unread count jika perlu
        return response()->json($users);
    }

    /**
     * Ambil percakapan dengan user tertentu
     */
    public function index(Request $request, $otherUserId)
    {
        $userId = $request->user()->id;

        $messages = Message::where(function ($query) use ($userId, $otherUserId) {
            $query->where('sender_id', $userId)->where('receiver_id', $otherUserId);
        })->orWhere(function ($query) use ($userId, $otherUserId) {
            $query->where('sender_id', $otherUserId)->where('receiver_id', $userId);
        })->orderBy('created_at', 'asc')->get();

        // Tandai sudah dibaca
        Message::where('sender_id', $otherUserId)
            ->where('receiver_id', $userId)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json($messages);
    }

    /**
     * Kirim pesan baru
     */
    public function store(Request $request)
    {
        $request->validate([
            'receiver_id' => 'required|exists:users,id',
            'message' => 'required|string',
        ]);

        $message = Message::create([
            'sender_id' => $request->user()->id,
            'receiver_id' => $request->receiver_id,
            'message' => $request->message,
        ]);

        return response()->json($message, 201);
    }

    /**
     * Ambil ID admin untuk memudahkan user memulai chat
     */
    public function getAdminId()
    {
        $admin = User::where('role', 'admin')->first();
        return response()->json(['admin_id' => $admin ? $admin->id : null]);
    }
}
