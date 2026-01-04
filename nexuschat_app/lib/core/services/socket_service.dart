import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexuschat_app/features/auth/presentation/providers/auth_provider.dart';

// Constants for Socket URL
// For Android Emulator use 10.0.2.2, for real device/Windows use localhost or IP
const String _socketUrl = 'http://10.0.2.2:3000'; 
// const String _socketUrl = 'http://localhost:3000'; // For Windows

class SocketService {
  IO.Socket? _socket;
  final Ref _ref;

  SocketService(this._ref);

  // Initialize and connect
  void connect(String token) {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      _socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      print('✅ Connected to Socket.IO');
    });

    _socket!.onDisconnect((_) {
      print('❌ Disconnected from Socket.IO');
    });

    _socket!.onConnectError((err) {
      print('⚠️ Socket Connection Error: $err');
    });
    
    // Debugging generic events
    _socket!.onAny((event, data) {
      print('Socket Event: $event, Data: $data');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  // Messaging Methods
  
  void sendMessage(String chatId, String content, Function(dynamic) onAck) {
    if (_socket == null) return;
    
    final payload = {
      'chatId': chatId,
      'content': content,
      'type': 'text',
    };
    
    _socket!.emitWithAck('message:send', payload, ack: (response) {
      print('Ack response: $response');
      onAck(response);
    });
  }
  
  void joinChat(String chatId) {
    _socket?.emit('chat:join', chatId);
  }
  
  void leaveChat(String chatId) {
    _socket?.emit('chat:leave', chatId);
  }
  
  // Listeners
  
  void onNewMessage(Function(dynamic) callback) {
    _socket?.on('message:new', callback);
  }
  
  void offNewMessage() {
    _socket?.off('message:new');
  }

  // Check connection status
  bool get isConnected => _socket?.connected ?? false;
}

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService(ref);
});
