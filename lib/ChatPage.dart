import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String idMascota;
  final String nombreUsuario;

  const ChatPage({super.key, required this.idMascota, required this.nombreUsuario});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat con ${widget.nombreUsuario}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: widget.idMascota.isNotEmpty
                  ? _firestore
                      .collection('chats')
                      .doc(widget.idMascota)
                      .collection('messages')
                      .orderBy('timestamp')
                      .snapshots()
                  : null,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var messages = snapshot.data!.docs;
                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  var messageText = message['text'];
                  var messageSender = message['sender'];

                  var messageWidget =
                      _buildMessageWidget(messageSender, messageText);
                  messageWidgets.add(messageWidget);
                }

                return ListView(
                  children: messageWidgets,
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageWidget(String senderId, String text) {
    return FutureBuilder(
      future: _getUsernameById(senderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const ListTile(
            title: Text('Error al cargar mensaje'),
          );
        } else {
          var senderUsername = snapshot.data;
          var isCurrentUser = senderId == _user.uid;

          return ListTile(
            title: Text('$senderUsername: $text'),
            tileColor: isCurrentUser ? Colors.blue[100] : Colors.grey[300],
            contentPadding: EdgeInsets.symmetric(
              horizontal: isCurrentUser ? 64.0 : 8.0,
              vertical: 4.0,
            ),
            visualDensity: VisualDensity.compact,
            leading: isCurrentUser ? null : const Icon(Icons.person),
            trailing: isCurrentUser ? const Icon(Icons.person) : null,
          );
        }
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Escribe un mensaje...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              _sendMessage();
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    String message = _messageController.text;
    if (message.isNotEmpty) {
      _firestore
          .collection('chats')
          .doc(widget.idMascota)
          .collection('messages')
          .add({
        'text': message,
        'sender': _user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  Future<String> _getUsernameById(String userId) async {
    try {
      if (_auth.currentUser?.uid == userId) {
        return _auth.currentUser?.displayName ?? 'Usuario Desconocido';
      } else {
        var userDoc = await _firestore.collection('usuarios').doc(userId).get();
        return userDoc.get('nombreUsuario') as String? ?? 'Usuario Desconocido';
      }
    } catch (e) {
      print('Error al obtener el nombre de usuario: $e');
      return 'Usuario Desconocido';
    }
  }
}
