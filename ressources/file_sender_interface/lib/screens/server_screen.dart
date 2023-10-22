import 'dart:io';

import 'package:file_sender/file_sender.dart';
import 'package:file_sender_interface/models/server_backend.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ServerScreen extends StatefulWidget {
  const ServerScreen({super.key});

  @override
  State<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends State<ServerScreen> {
  final _portController =
      TextEditingController(text: fileSenderDefaultPort.toString());
  late int? _port = int.tryParse(_portController.text);
  ServerBackend? _server;

  @override
  void dispose() {
    _server?.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: _server == null
              ? _buildInitializeScreen()
              : _server!.isConnected
                  ? _buildWaitingForRequest()
                  : _buildWaitingForConnexion()),
    );
  }

  Future<String?> _pickFilePath() async {
    return await FilesystemPicker.open(
      title: 'Open file',
      rootDirectory: Directory('/home'),
      context: context,
      fsType: FilesystemType.file,
      allowedExtensions: ['.json'],
      fileTileSelectMode: FileTileSelectMode.wholeTile,
    );
  }

  Future<String?> _saveFilePath() async {
    final folder = await FilesystemPicker.open(
      title: 'Save folder',
      rootDirectory: Directory('/home'),
      context: context,
      fsType: FilesystemType.folder,
      fileTileSelectMode: FileTileSelectMode.wholeTile,
      contextActions: [
        FilesystemPickerNewFolderContextAction(),
      ],
    );

    return folder == null ? null : '$folder/savedFile.json';
  }

  Widget _buildWaitingForRequest() {
    return const Text('Waiting for request from client');
  }

  Widget _buildWaitingForConnexion() {
    return const Text('Waiting for connexion');
  }

  Widget _buildInitializeScreen() {
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
          onPressed: _port == null ? null : _initializeServer,
          child: const Text('Initialize server'),
        )
      ],
    );
  }

  void _initializeServer() async {
    _server = await ServerBackend.factory(
        port: _port!,
        onGetPickFilePath: _pickFilePath,
        onGetSaveFilePath: _saveFilePath,
        onTerminatedConnexion: () {
          if (!mounted) return;
          setState(() {});
        });
    _server!.listen(() => setState(() {}));
    setState(() {});
  }
}
