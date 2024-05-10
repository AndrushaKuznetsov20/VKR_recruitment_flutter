import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../Models/Message.dart';

class ChatPage extends StatefulWidget {
  final String token;
  final int senderId;
  final int receiverId;
  ChatPage({required this.token, required this.senderId, required this.receiverId});

  @override
  ChatPageState createState() => ChatPageState();

}
class ChatPageState extends State<ChatPage> {

  final TextEditingController messageController = TextEditingController();
  late Timer timer;
  DateFormat dateFormat = DateFormat('dd.MM.yyyy');
  List<Message> messages = [];
  final String currentUsername = "Вы";

  Future<void> sendMessage(BuildContext context) async {

    String content = messageController.text;

    final url = Uri.parse('http://172.20.10.3:8092/message/sendMessage/${widget.senderId}/${widget.receiverId}');
    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.token}'};
    final body = jsonEncode({
      'content': content,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
      setState(() {
        messageController.clear();
      });
      outputMessages(context);
    }
  }

  Future<void> outputMessages(BuildContext context) async {
    final response = await http.get(
      Uri.parse(
          'http://172.20.10.3:8092/message/outputMessages/${widget.senderId}/${widget.receiverId}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if(response.statusCode == 200)
    {
      final jsonData = json.decode(response.body) as List<dynamic>;
      List<Message> responseMessages = [];

      for (var outputMessagesJson in jsonData) {
        responseMessages.add(Message.fromJson(outputMessagesJson));
      }

      setState(() {
        messages = responseMessages;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        outputMessages(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Чат', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isOwnMessage = message.sender == widget.senderId;
                return Column(
                  crossAxisAlignment: isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(message.currentDateTime),
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Align(
                      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
                      child: Card(
                        color: isOwnMessage ? Colors.green[100] : Colors.blue[100],
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(utf8.decode(message.content.codeUnits)),
                        ),
                      ),
                    ),
                    Text(
                      isOwnMessage ? "Вы" : "",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Введите сообщение',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  sendMessage(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}