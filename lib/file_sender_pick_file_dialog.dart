import 'dart:convert';
import 'dart:developer';

import 'package:file_sender/file_sender.dart';
import 'package:file_sender/connexion_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_client/web_socket_client.dart' as ws;

Future<Uint8List?> showFileSenderPickDialog(context,
    {int port = fileSenderDefaultPort}) async {
  return await showDialog<Uint8List?>(
    context: context,
    builder: (context) {
      return const _FileSenderPickFileDialog(port: fileSenderDefaultPort);
    },
    barrierDismissible: false,
  );
}

///
/// Open an AlertDialog to pick a file from the computer.
/// If [port] is defined, the Dialog skips to the connexion part.
class _FileSenderPickFileDialog extends StatelessWidget {
  const _FileSenderPickFileDialog({this.port});

  final int? port;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: _FileSenderPage(port: port),
    );
  }
}

class _FileSenderPage extends StatefulWidget {
  const _FileSenderPage({this.port});

  // If port is defined, the Dialog skips to the connexion part
  final int? port;

  @override
  State<_FileSenderPage> createState() => __FileSenderPageState();
}

class __FileSenderPageState extends State<_FileSenderPage> {
  late final _portController = TextEditingController(
      text: widget.port == null
          ? fileSenderDefaultPort.toString()
          : widget.port!.toString());
  late int? _port = int.tryParse(
      widget.port == null ? _portController.text : widget.port!.toString());
  ws.WebSocket? _socket;

  late ConnexionStatus _connexionStatus = ConnexionStatus.notConnected;

  @override
  void initState() {
    super.initState();

    if (widget.port != null) {
      _connectToServer(skipSetState: true);
    }
  }

  @override
  void dispose() {
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_connexionStatus) {
      case ConnexionStatus.notConnected:
        return _buildConnectToServer();
      case ConnexionStatus.connecting:
        return _buildConnecting();
      case ConnexionStatus.connected:
        return _buildTransferFile();
      case ConnexionStatus.invalidProtocol:
        return _buildInvalidProtocol();
      case ConnexionStatus.invalidResponse:
        return _buildInvalidResponse();
      case ConnexionStatus.invalidRequest:
        return _buildInvalidRequest();
      case ConnexionStatus.cancelled:
        return _buildCancelled();
      case ConnexionStatus.success:
        return _buildSuccess();
    }
  }

  Widget _buildSuccess() {
    return const Text('File transfered');
  }

  Widget _buildCancelled() {
    return const Text('Operation cancelled');
  }

  Widget _buildInvalidProtocol() {
    return const Text('The protocol used was invalid');
  }

  Widget _buildInvalidRequest() {
    return const Text('The sent request was invalid');
  }

  Widget _buildInvalidResponse() {
    return const Text('The response from the server was invalid');
  }

  Widget _buildTransferFile() {
    return const Text('Wait for file to transfer');
  }

  Widget _buildConnecting() {
    return const Text('Connecting to server...');
  }

  Widget _buildConnectToServer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 200,
          child: TextField(
            controller: _portController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Port',
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            onChanged: (value) {
              final port = int.tryParse(value);
              _port = null;
              if (port != null && port > 0 && port < 65535) {
                _port = port;
              }
              setState(() {});
            },
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _port == null ? null : _connectToServer,
          child: const Text('Connect to server'),
        )
      ],
    );
  }

  void _connectToServer({bool skipSetState = false}) {
    _socket = ws.WebSocket(Uri.parse('ws://localhost:$_port'));
    _socket!.messages.listen((event) => _messageReceived(event));
    log('Connected to server on port $_port');
    _connexionStatus = ConnexionStatus.connecting;

    if (!skipSetState) setState(() {});
  }

  void _messageReceived(event) {
    final message = jsonDecode(event) as Map;

    if (_connexionStatus == ConnexionStatus.connecting) {
      if (!message.containsKey('protocol') || message['protocol'] != '1.0.0') {
        _connexionStatus = ConnexionStatus.invalidRequest;
        if (mounted) setState(() {});
        return;
      }

      // Post the actual request
      _connexionStatus = ConnexionStatus.connected;
      final request = jsonEncode({'request': 'pickFile'});
      _socket!.send(request);
    } else if (message['requested'] == 'invalid') {
      _connexionStatus = ConnexionStatus.invalidRequest;
    } else if (message['requested'] != 'pickFile') {
      _connexionStatus = ConnexionStatus.invalidResponse;
    } else if (message['requested'] == 'cancelled') {
      _connexionStatus = ConnexionStatus.cancelled;
    } else {
      _connexionStatus = ConnexionStatus.success;

      final data = Uint8List.fromList(message['data'].cast<int>().toList());
      _socket!.close();
      if (mounted) Navigator.of(context).pop(data);
    }

    if (mounted) setState(() {});
  }
}
