import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Message {
  final String text;
  final String sender;

  Message({required this.text, required this.sender});
}

class FirestoreService {
  final CollectionReference messagesCollection =
  FirebaseFirestore.instance.collection('messages');
  final String instanceId;

  FirestoreService(this.instanceId);

  CollectionReference get messagesCollectionWithInstanceId =>
      messagesCollection.doc(instanceId).collection('submessages');

  Future<void> sendMessage(String text) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final sender = user.displayName ?? 'Anonymous';

      await messagesCollectionWithInstanceId.add({
        'text': text,
        'sender': sender,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<List<Message>> getMessages() {
    return messagesCollectionWithInstanceId
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Message(
      text: doc['text'],
      sender: doc['sender'],
    ))
        .toList());
  }
}

class MyVideoPlayerr extends StatefulWidget {
  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayerr> {
  final TextEditingController _messageController = TextEditingController();
  final String instanceId = DateTime.now().toString();
  bool fullScreen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          Expanded(
            child: Container(
              height: fullScreen
                  ? MediaQuery.of(context).size.height * 1 // 25% of the screen height in full screen
                  : MediaQuery.of(context).size.height * 1, // 50% of the screen height when not in full screen
              child: Column(
                children: [
                  Expanded(
                    child: _buildMessagesList(),
                  ),
                  LiveMessagingWidget(instanceId: instanceId),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<List<Message>>(
      stream: FirestoreService(instanceId).getMessages(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text("No messages yet."),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final message = snapshot.data![index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage:
                FirebaseAuth.instance.currentUser?.photoURL != null
                    ? NetworkImage(
                    FirebaseAuth.instance.currentUser!.photoURL!)
                    : null,
                child: FirebaseAuth.instance.currentUser?.photoURL == null
                    ? Icon(Icons.account_circle, size: 36.0)
                    : null,
              ),
              title: Text(message.sender),
              subtitle: Text(message.text),
            );
          },
        );
      },
    );
  }
}

class LiveMessagingWidget extends StatefulWidget {
  final String instanceId;

  LiveMessagingWidget({required this.instanceId});

  @override
  _LiveMessagingWidgetState createState() => _LiveMessagingWidgetState();
}

class _LiveMessagingWidgetState extends State<LiveMessagingWidget> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(11, 227, 188, 0.12),
            Color.fromRGBO(12, 163, 119, 0.59),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric( horizontal: 5.0,
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  filled: true,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              final message = _messageController.text;
              if (message.isNotEmpty) {
                FirestoreService(widget.instanceId).sendMessage(message);
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyVideoPlayerr(),
  ));
}