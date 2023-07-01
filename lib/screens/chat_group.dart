import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chatty/models/group.dart';
import 'package:chatty/utils/convert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/user.dart';

class ChatGroupScreen extends StatefulWidget {
  const ChatGroupScreen({required this.groupId, super.key});

  final String groupId;

  @override
  State<ChatGroupScreen> createState() => _ChatGroupScreenState();
}

class _ChatGroupScreenState extends State<ChatGroupScreen> {
  List<types.Message> _messages = [];
  WebSocketChannel? _channel;
  Group? _group;
  UserInfo _currentUser = UserInfo();
  String _token = '';
  final _storage = const FlutterSecureStorage();

  Future<void> _fetchGroupInfo() async {
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': _token,
    };
    var request = http.Request(
        'POST', Uri.parse('http://103.142.26.18:8081/api/group/get'));
    request.body = json.encode({"group_id": widget.groupId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseStr = await response.stream.bytesToString();
      Map<String, dynamic> jsonResponse = jsonDecode(responseStr);
      if (jsonResponse['info'] != null) {
        setState(() {
          _group = Group.fromJson(jsonResponse['info']);
        });
      }
    }
  }

  Future<void> _fetchMessageHistory() async {
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': _token,
    };
    var request = http.Request('POST',
        Uri.parse('http://103.142.26.18:8081/api/message/get-chat-history'));
    // DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
    // DateTime currentTime = DateTime.now();
    // String currentTimeString = dateFormat.format(currentTime);
    request.body = json.encode({
      "recipient_id": widget.groupId,
      "start_time": "12/12/2022 01:00:00",
      "end_time": "31/12/2023 23:59:59",
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final value = await response.stream.bytesToString();
      Map<String, dynamic> responseJson = jsonDecode(value);
      List<types.Message> messages = [];
      if (responseJson['chat_history'] != null) {
        for (final jsonMessage in responseJson['chat_history']) {
          types.Message message = await _convertToMessageType(jsonMessage);
          messages.insert(0, message);
        }
      }
      setState(() {
        _messages = messages;
      });
    }
  }

  Future<UserInfo?> _fetchUserInfo(String userId) async {
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': _token,
    };
    var request = http.Request(
        'POST', Uri.parse('http://103.142.26.18:8081/api/user/get'));
    request.body = json.encode({'user_id': userId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final value = await response.stream.bytesToString();
      Map<String, dynamic> userInfoJson = jsonDecode(value);
      if (userInfoJson['info'] != null) {
        UserInfo userInfo = UserInfo.fromJson(userInfoJson['info']);
        return userInfo;
      }
    }
    return null;
  }

  Future<void> _createMessage(String text) async {
    var headers = {
      'Cookie': _token,
    };
    var request = http.MultipartRequest('POST',
        Uri.parse('http://103.142.26.18:8081/api/message/create-message'));
    request.fields.addAll({
      'recipient_id': widget.groupId,
      'text': text,
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print(await response.stream.bytesToString());
      }
    }
  }

  Future<types.Message> _convertToMessageType(
      Map<String, dynamic> jsonMessage) async {
    String senderId = jsonMessage['sender_id'].toString();
    String type = jsonMessage['resource_type'].toString();
    var randomId = const Uuid().v4().toString();
    Map<String, dynamic> json = <String, dynamic>{};
    UserInfo? userInfo = await _fetchUserInfo(senderId);
    DateFormat format = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime dateTime = format.parse(jsonMessage['time'].toString());
    int timestamp =
        dateTime.add(const Duration(hours: 7)).millisecondsSinceEpoch;

    json['id'] = randomId;
    json['createdAt'] = timestamp;
    json['author'] = {
      'id': senderId,
      'firstName': userInfo?.username,
      'imageUrl': userInfo?.url,
    };
    if (type == 'text') {
      json['text'] = jsonMessage['message'].toString();
      json['type'] = 'text';
    }
    if (type == 'image') {
      json['size'] = jsonMessage['file_size'];
      json['height'] = jsonMessage['height'];
      json['width'] = jsonMessage['width'];
      json['uri'] = jsonMessage['url'];
      json['name'] = jsonMessage['file_name'];
      json['type'] = 'image';
    }
    if (type == 'file') {
      json['size'] = jsonMessage['file_size'];
      json['name'] = jsonMessage['file_name'];
      json['uri'] = jsonMessage['url'];
      json['type'] = 'file';
      json['mimeType'] = lookupMimeType(jsonMessage['url']);
    }
    return types.Message.fromJson(json);
  }

  Future<types.Message> _handleMessageSocket(String data) async {
    Map<String, dynamic> json = jsonDecode(data);
    Map<String, dynamic> jsonPayload = json['payload'];
    String senderId = jsonPayload['sender_id'].toString();
    String type = jsonPayload['type'].toString();
    var randomId = const Uuid().v4().toString();
    Map<String, dynamic> jsonMessage = <String, dynamic>{};
    DateTime dateTime = DateTime.parse(jsonPayload['time'].toString());
    int timestamp = dateTime.millisecondsSinceEpoch;
    UserInfo? userInfo = await _fetchUserInfo(senderId);

    jsonMessage['id'] = randomId;
    jsonMessage['createdAt'] = timestamp;
    jsonMessage['author'] = {
      "id": senderId,
      "imageUrl": userInfo?.url,
      "firstname": userInfo?.username,
    };
    if (type == 'text') {
      jsonMessage['text'] = jsonPayload['message'].toString();
      jsonMessage['type'] = 'text';
    }
    if (type == 'image') {
      jsonMessage['size'] = jsonPayload['file_size'];
      jsonMessage['height'] = jsonPayload['height'];
      jsonMessage['width'] = jsonPayload['width'];
      jsonMessage['uri'] = jsonPayload['url'];
      jsonMessage['name'] = jsonPayload['file_name'];
      jsonMessage['type'] = 'image';
    }
    if (type == 'file') {
      jsonMessage['size'] = jsonPayload['file_size'];
      jsonMessage['name'] = jsonPayload['file_name'];
      jsonMessage['uri'] = jsonPayload['url'];
      jsonMessage['type'] = 'file';
      jsonMessage['mimeType'] = lookupMimeType(jsonPayload['url']);
    }
    return types.Message.fromJson(jsonMessage);
  }

  Future<void> _fetchCurrentUser() async {
    String? token = await _storage.read(key: "token");
    String? userText = await _storage.read(key: "user");
    final Map<String, dynamic> jsonUser = jsonDecode(userText.toString());
    setState(() {
      _token = 'pchat=${token.toString()}';
      _currentUser = UserInfo.fromJson(jsonUser);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser().then((_) {
      _fetchGroupInfo().then((_) {
        _fetchMessageHistory().then((_) {
          _channel = WebSocketChannel.connect(
              Uri.parse('ws://103.142.26.18:8081/ws/${_currentUser.userId}'));
          Map<String, dynamic> joinRoomJson = {
            'event': 'JoinRoom',
            'room': widget.groupId,
          };
          _channel!.sink.add(jsonEncode(joinRoomJson));
          _channel!.stream.listen((data) {
            _handleMessageSocket(data).then((message) {
              setState(() {
                _messages.insert(0, message);
              });
            });
          });
        });
      });
    });
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  Future<Map<String, dynamic>> _uploadFileSelect(
      Uint8List bytes, String fileName) async {
    var headers = {
      'Cookie': _token,
    };
    var request = http.MultipartRequest('POST',
        Uri.parse('http://103.142.26.18:8081/api/message/create-message'));
    request.fields.addAll({'recipient_id': widget.groupId});
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: fileName,
    ));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> responseJson = jsonDecode(responseBody);
      return responseJson['message'];
    }
    return {};
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: 144,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleImageSelection();
                  },
                  child: const Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text('Photo'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleFileSelection();
                  },
                  child: const Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text('File'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final response = await _uploadFileSelect(
          result.files.single.bytes!, result.files.single.name);
      final timeString = response['time'].toString();
      DateFormat inputFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      DateTime dateTime = inputFormatter.parse(timeString);
      final fileName = response['file_name'].toString();
      final url = response['url'];
      final message = types.FileMessage(
        author: convertToUserType(_currentUser),
        createdAt: dateTime.millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: fileName,
        size: result.files.single.size,
        uri: url,
      );

      _addMessage(message);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final response = await _uploadFileSelect(bytes, result.name);
      final timeString = response['time'].toString();
      DateFormat inputFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      DateTime dateTime = inputFormatter.parse(timeString);
      final fileName = response['file_name'].toString();
      final url = response['url'];
      final message = types.ImageMessage(
        author: convertToUserType(_currentUser),
        createdAt: dateTime.millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: fileName,
        size: bytes.length,
        uri: url,
        width: image.width.toDouble(),
      );

      _addMessage(message);
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) {
    _createMessage(message.text).then((_) {
      final textMessage = types.TextMessage(
        author: convertToUserType(_currentUser),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: message.text,
      );

      _addMessage(textMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          _group?.groupName != null
              ? _group?.groupName as String
              : 'Group name',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.video_call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info),
          ),
        ],
      ),
      body: StreamBuilder(
        builder: (context, snapshot) {
          if (_channel == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Chat(
            theme: DefaultChatTheme(
              primaryColor: Colors.blue,
              inputBorderRadius: BorderRadius.zero,
              inputTextColor: Colors.black,
              inputTextCursorColor: Colors.blue,
              inputBackgroundColor: Colors.white,
              inputTextDecoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                fillColor: Colors.grey.shade200,
                filled: true,
              ),
              sendButtonIcon: const Icon(
                Icons.send,
                color: Colors.blue,
              ),
              attachmentButtonIcon: const Icon(
                Icons.add,
              ),
            ),
            messages: _messages,
            onAttachmentPressed: _handleAttachmentPressed,
            onMessageTap: _handleMessageTap,
            onPreviewDataFetched: _handlePreviewDataFetched,
            onSendPressed: _handleSendPressed,
            showUserAvatars: true,
            showUserNames: true,
            user: convertToUserType(_currentUser),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}
