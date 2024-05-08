class Message {
  final int id;
  final String content;
  final int sender;
  final int receiver;
  final DateTime currentDateTime;

  Message({required this.id,required this.content,
    required this.sender, required this.receiver,required this.currentDateTime});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      sender: json['sender'],
      receiver: json['receiver'],
      currentDateTime: DateTime.parse(json['currentDateTime']),
    );
  }
}