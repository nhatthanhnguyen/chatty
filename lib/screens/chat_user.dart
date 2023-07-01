import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chatty/models/chat_history.dart';
import 'package:chatty/models/user.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatPrivateScreen extends StatefulWidget {
  const ChatPrivateScreen({required this.userId, super.key});

  final String userId;

  @override
  State<ChatPrivateScreen> createState() => _ChatPrivateScreenState();
}

class _ChatPrivateScreenState extends State<ChatPrivateScreen> {
  List<types.Message> _messages = [];
  UserInfo _userReceiveInfo = UserInfo();
  WebSocketChannel? _channel;

  Future<void> fetchMessageHistory(String userId) async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: "token");
    String? userText = await storage.read(key: "user");
    final Map<String, dynamic> jsonUser = jsonDecode(userText.toString());
    UserInfo currentUser = UserInfo.fromJson(jsonUser);
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': token as String,
    };
    var request = http.Request('POST',
        Uri.parse('http://103.142.26.18:8081/api/message/get-chat-history'));
    // DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
    // DateTime currentTime = DateTime.now();
    // String currentTimeString = dateFormat.format(currentTime);
    request.body = json.encode({
      "recipient_id": userId,
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
        for (final chatHistoryJson in responseJson['chat_history']) {
          ChatHistory chatHistory = ChatHistory.fromJson(chatHistoryJson);
          types.Message message =
              convertToMessageType(chatHistory, currentUser);
          messages.insert(0, message);
        }
      }
      setState(() {
        _messages = messages;
      });
    }
  }

  Future<void> fetchUserInfo(String userId) async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: "token");
    var headers = {
      'Content-Type': 'application/json',
      'Cookie': token as String,
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
        setState(() {
          _userReceiveInfo = userInfo;
        });
      }
    }
  }

  types.Message convertToMessageType(
      ChatHistory chatHistory, UserInfo currentUser) {
    var randomId = const Uuid().v4().toString();
    Map<String, dynamic> json = <String, dynamic>{};
    DateFormat format = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    DateTime dateTime = format.parse(chatHistory.time as String);
    int timestamp =
        dateTime.add(const Duration(hours: 7)).millisecondsSinceEpoch;
    json["id"] = randomId;
    json["createdAt"] = timestamp;
    json["author"] = {
      "id": chatHistory.senderId,
      "imageUrl": chatHistory.senderId != currentUser.userId
          ? _userReceiveInfo.url
          : currentUser.url,
      "firstname": chatHistory.senderId != currentUser.userId
          ? _userReceiveInfo.username
          : currentUser.username,
    };
    json["type"] = "text";
    json["text"] = chatHistory.message;
    return types.Message.fromJson(json);
  }

  Future<void> createMessage(String recipientId, String text) async {
    var headers = {
      'Cookie': token,
    };
    var request = http.MultipartRequest('POST',
        Uri.parse('http://103.142.26.18:8081/api/message/create-message'));
    request.fields.addAll({
      'recipient_id': recipientId,
      'text': text,
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("Send message success");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserInfo(widget.userId).then((_) {
      fetchMessageHistory(widget.userId).then((_) {
        _channel?.sink.close();
        _channel = IOWebSocketChannel.connect(
            Uri.parse("ws://103.142.26.18:8081/ws/${currentUser.id}"));
        Map<String, String> joinRoomJson = {
          'event': 'JoinRoom',
          'room': currentUser.id,
        };
        _channel!.sink.add(jsonEncode(joinRoomJson));
        _channel!.stream.listen((data) {
          final message = _handleMessageSocket(data);
          setState(() {
            _messages.insert(0, message);
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

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
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
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: currentUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
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

      final message = types.ImageMessage(
        author: currentUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
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
    createMessage(widget.userId, message.text).then((_) {
      final textMessage = types.TextMessage(
        author: currentUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: message.text,
      );
      _addMessage(textMessage);
    });
  }

  types.Message _handleMessageSocket(String data) {
    Map<String, dynamic> json = jsonDecode(data);
    Map<String, dynamic> payloadJson = json['payload'];
    User author = User(
      id: _userReceiveInfo.userId.toString(),
      firstName: _userReceiveInfo.username,
      imageUrl: _userReceiveInfo.url,
    );
    String timeString = payloadJson['time'];
    DateTime dateTime = DateTime.parse(timeString);
    int timestamp = dateTime.millisecondsSinceEpoch;
    final textMessage = types.TextMessage(
      author: author,
      id: const Uuid().v4(),
      text: payloadJson['message'],
      createdAt: timestamp,
    );
    return textMessage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: Text(
          _userReceiveInfo.username != null ? currentUser.firstName! : "User",
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
            user: currentUser,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _channel!.sink.close();
    super.dispose();
  }
}
