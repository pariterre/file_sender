import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_sender/file_sender.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Example of transfering file',
      home: TransferFilePage(),
    );
  }
}

class TransferFilePage extends StatelessWidget {
  const TransferFilePage({super.key});

  void _getFile(context) async {
    final myData =
        await showFileSenderPickDialog(context, port: fileSenderDefaultPort);
    final myJson = String.fromCharCodes(myData!.toList());
    debugPrint(myJson);
  }

  void _saveFile(context) async {
    final data = const JsonEncoder.withIndent('  ')
        .convert({'dataToSave': 'Hello world'});
    await showFileSenderSaveDialog(
      context,
      port: fileSenderDefaultPort,
      data: data,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example of transfering file'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _getFile(context),
              child: const Text('Pick file request'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveFile(context),
              child: const Text('Save file request'),
            ),
          ],
        ),
      ),
    );
  }
}
