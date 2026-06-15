import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/fare_model.dart';

class WebSocketService {
  static const _wsUrl = 'ws://localhost:8000/ws/live';
  // For local dev use: 'ws://10.0.2.2:8000/ws/live'  (Android emulator)
  // For local dev use: 'ws://localhost:8000/ws/live'  (iOS simulator / web)

  WebSocketChannel? _channel;
  final _controller = StreamController<FareBreakdown>.broadcast();

  Stream<FareBreakdown> get fareStream => _controller.stream;
  bool _connected = false;

  void connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      _connected = true;
      _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data as String) as Map<String, dynamic>;
            _controller.add(FareBreakdown.fromJson(json));
          } catch (e) {
            // parse error — skip frame
          }
        },
        onError: (_) {
          _connected = false;
          // retry after 3s
          Future.delayed(const Duration(seconds: 3), connect);
        },
        onDone: () {
          _connected = false;
          Future.delayed(const Duration(seconds: 3), connect);
        },
      );
    } catch (_) {
      _connected = false;
      Future.delayed(const Duration(seconds: 3), connect);
    }
  }

  void sendRequest(Map<String, dynamic> params) {
    if (_connected && _channel != null) {
      _channel!.sink.add(jsonEncode(params));
    }
  }

  void dispose() {
    _controller.close();
    _channel?.sink.close();
  }
}