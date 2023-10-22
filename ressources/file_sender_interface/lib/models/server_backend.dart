import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:file_sender/file_sender.dart';

class ServerBackend {
  final HttpServer _server;

  WebSocket? _socket;
  bool get isConnected => _socket != null;

  final List<Function()> _listeners = [];
  final Future<String?> Function() onGetPickFilePath;
  final Future<String?> Function() onGetSaveFilePath;
  final Function()? onTerminatedConnexion;

  ServerBackend._(
    this._server, {
    required this.onGetPickFilePath,
    required this.onGetSaveFilePath,
    required this.onTerminatedConnexion,
  }) {
    _server.transform(WebSocketTransformer()).listen(_clientHandShake);
    dev.log('Server started');
  }

  void listen(void Function() onConnexion) {
    _listeners.add(onConnexion);
  }

  static Future<ServerBackend> factory({
    int port = fileSenderDefaultPort,
    required Future<String?> Function() onGetPickFilePath,
    required Future<String?> Function() onGetSaveFilePath,
    Function()? onTerminatedConnexion,
  }) async {
    HttpServer server = await HttpServer.bind(InternetAddress.anyIPv6, port);
    return ServerBackend._(
      server,
      onGetPickFilePath: onGetPickFilePath,
      onGetSaveFilePath: onGetSaveFilePath,
      onTerminatedConnexion: onTerminatedConnexion,
    );
  }

  void _clientHandShake(WebSocket socket) {
    dev.log('Client connected');
    _socket = socket;

    // Send handshake
    final message = jsonEncode({'protocol': fileSenderProtocolVersion});
    _socket!.add(message);
    _socket!.listen(_manageRequest);

    for (final listener in _listeners) {
      listener();
    }
  }

  void _manageRequest(event) async {
    final message = jsonDecode(event) as Map;
    if (!message.containsKey('request')) {
      await _sendFailed();
      return;
    }

    if (message['request'] == 'pickFile') {
      await _sendFile(await onGetPickFilePath());
    } else if (message['request'] == 'saveFile') {
      await _saveFile(await onGetSaveFilePath(), message['data']);
    } else {
      await _sendFailed();
      return;
    }
  }

  Future<void> _sendFile(String? dataFilepath) async {
    if (_socket == null) return;

    final data = dataFilepath == null
        ? 'cancel'
        : await File(dataFilepath).readAsBytes();

    _socket!.add(jsonEncode({'requested': 'pickFile', 'data': data}));
    dispose();
  }

  Future<void> _saveFile(String? dataFilepath, String data) async {
    if (_socket == null) return;

    final response = dataFilepath == null ? 'cancel' : 'done';
    _socket!.add(jsonEncode({'requested': 'saveFile', 'data': response}));

    if (dataFilepath == null) return;
    await File(dataFilepath).writeAsString(data);

    _shutConnexion();
  }

  Future<void> _sendFailed() async {
    _socket!.add(jsonEncode({'requested': 'invalid'}));
    _shutConnexion();
  }

  void _shutConnexion() {
    if (_socket == null) return;

    if (onTerminatedConnexion != null) onTerminatedConnexion!();
    _socket!.close();
    _socket = null;
  }

  void dispose() {
    _shutConnexion();

    _server.close();
  }
}
