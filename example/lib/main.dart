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
              onPressed: () async {
                final myData = await showDialog<Map>(
                  context: context,
                  builder: (context) {
                    return const FileSenderPickFileDialog(
                        port: fileSenderDefaultPort);
                  },
                );
                debugPrint(myData.toString());
              },
              child: const Text('Pick file request'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final myData = await showDialog<Map>(
                  context: context,
                  builder: (context) {
                    return FileSenderSaveFileDialog(
                        port: fileSenderDefaultPort,
                        data: const JsonEncoder.withIndent('  ')
                            .convert({'dataToSave': 'Hello world'}));
                  },
                );
                debugPrint(myData.toString());
              },
              child: const Text('Save file request'),
            ),
          ],
        ),
      ),
    );
  }
}
