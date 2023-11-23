import 'package:flutter/material.dart';

class Message {
  Message({required this.id, required this.title, required this.body});

  String id;
  String title;
  String body;
}

class MessageProvider extends ChangeNotifier {
  MessageProvider() : super();

  final List<Message> _messages = [];
  List<Message> get messages => _messages;

  void add(id, title, body) {
    final message = Message(
      id: id,
      title: title,
      body: body
    );

    messages.add(message);
    notifyListeners();
  }
}
