import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../Models/User.dart';
import 'ChatPage.dart';

class ListUserChats extends StatefulWidget {
  final String token;
  ListUserChats({required this.token});

  @override
  ListUserChatsState createState() => ListUserChatsState();

}
class ListUserChatsState extends State<ListUserChats> {

  List<User> listUsers = [];

  Future<void> getUserChats(BuildContext context) async {
    final response = await http.get(
      Uri.parse('http://172.20.10.3:8092/message/listChats'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as List<dynamic>;
      List<User> userChats = [];

      for (var userChatsJson in jsonData) {
        userChats.add(User.fromJson(userChatsJson));
      }

      setState(() {
        listUsers = userChats;
      });

      if (listUsers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("История ваших чатов пустая!"),
          ),
        );
      }
    }
  }

  int extractIdFromToken(String token)
  {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    int id = decodedToken['id'];
    return id;
  }

  @override
  void initState() {
    super.initState();
    getUserChats(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Ваши чаты',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.grey.shade900,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: listUsers.length,
              itemBuilder: (context, index) {
                final data = listUsers[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  elevation: 4,
                  child: Material(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              token: widget.token,
                              senderId: extractIdFromToken(widget.token),
                              receiverId: data.id,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.person, color: Colors.grey.shade900),
                            SizedBox(width: 8),
                            Text(
                              '${utf8.decode(data.username.codeUnits)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}