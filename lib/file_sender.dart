export 'package:file_sender/file_sender_pick_file_dialog.dart';
export 'package:file_sender/file_sender_save_file_dialog.dart';

///
/// Protocol 1.0.0 is a json as such:
/// Server receive a connexion and return a json of the protocol version
/// formatted as such:
///   {"protocol": MAJOR.MINOR.PATCH}
/// The server does not wait for a response.
///
/// The client can then send a reequest as such:
///   Pick a file from the computer:
///     {"request": "pickFile"}
///   or save a file to the computer:
///     {"request": "saveFile", "data": "json encoded file"}
///
/// The response from the server to "pickFile" is:
///   {"resquested": "pickFile", "data": "[json encoded file]"}
///   {"resquested": "pickFile", "data": "cancel"}
///
/// The response from the server to "saveFile" is:
///   {"resquested": "saveFile", "data": "done"}
///   {"resquested": "saveFile", "data": "cancel"}
///
/// The response from any other resquest is:
///   {"resquested": "invalid"}
///
/// The connexion is shutdown after the response.
///
const String fileSenderProtocolVersion = '1.0.0';

const int fileSenderDefaultPort = 3004;
