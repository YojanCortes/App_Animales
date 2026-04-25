import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appanimales/theme/app_theme.dart';

class ChatPage extends StatefulWidget {
  final String idMascota;
  final String nombreUsuario; // nombre a mostrar del otro usuario

  const ChatPage({
    super.key,
    required this.idMascota,
    required this.nombreUsuario,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User get _currentUser => _auth.currentUser!;

  // chatId único para este par (currentUser ↔ dueño de la mascota)
  String? _chatId;
  String? _ownerUid;
  bool _loading = true;
  String _miNombre = '';

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    try {
      // 1. Obtener el UID del dueño de la mascota
      final mascotaDoc = await _firestore.collection('mascotas').doc(widget.idMascota).get();
      if (!mascotaDoc.exists) {
        setState(() => _loading = false);
        return;
      }
      final data = mascotaDoc.data()!;
      final ownerUid = data['idUsuario'] as String? ?? data['userId'] as String? ?? data['uid'] as String? ?? '';

      if (ownerUid.isEmpty) {
        setState(() => _loading = false);
        return;
      }
      _ownerUid = ownerUid;

      // 2. Obtener nombre propio del usuario actual
      final myDoc = await _firestore.collection('usuarios').doc(_currentUser.uid).get();
      if (myDoc.exists) {
        _miNombre = (myDoc.data()?['nombreUsuario'] as String?) ?? _currentUser.email ?? 'Yo';
      } else {
        _miNombre = _currentUser.email ?? 'Yo';
      }

      // 3. Crear chatId determinista: sort UIDs para que sea simétrico
      final ids = [_currentUser.uid, ownerUid]..sort();
      _chatId = '${ids[0]}_${ids[1]}_${widget.idMascota}';

      // 4. Registrar la sala de chat en Firestore si no existe
      final chatRef = _firestore.collection('chats').doc(_chatId);
      final chatSnap = await chatRef.get();
      if (!chatSnap.exists) {
        await chatRef.set({
          'participantes': [_currentUser.uid, ownerUid],
          'idMascota': widget.idMascota,
          'nombreMascota': data['nombre'] ?? '',
          'creadoEn': FieldValue.serverTimestamp(),
          'ultimoMensaje': '',
          'ultimoMensajeTs': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error iniciando chat: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _chatId == null) return;

    _messageController.clear();

    final messagesRef = _firestore
        .collection('chats')
        .doc(_chatId)
        .collection('messages');

    await messagesRef.add({
      'text': text,
      'senderUid': _currentUser.uid,
      'senderName': _miNombre,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Actualizar último mensaje en la sala
    await _firestore.collection('chats').doc(_chatId).update({
      'ultimoMensaje': text,
      'ultimoMensajeTs': FieldValue.serverTimestamp(),
    });

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDeep,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textMuted),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.accent.withOpacity(0.2),
              child: Text(
                widget.nombreUsuario.isNotEmpty
                    ? widget.nombreUsuario[0].toUpperCase()
                    : '?',
                style: GoogleFonts.outfit(
                    color: AppTheme.accent, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.nombreUsuario,
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  'Chat privado',
                  style: GoogleFonts.inter(
                      color: AppTheme.textMuted, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent))
          : _chatId == null
              ? Center(
                  child: Text(
                    'No se pudo iniciar el chat.\nEl dueño de la mascota no tiene UID registrado.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: AppTheme.textMuted),
                  ),
                )
              : Column(
                  children: [
                    Expanded(child: _buildMessageList()),
                    _buildInputArea(),
                  ],
                ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.accent));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline,
                    color: AppTheme.textFaint, size: 48),
                const SizedBox(height: 12),
                Text('Sin mensajes aún',
                    style:
                        GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Sé el primero en escribir',
                    style: GoogleFonts.inter(
                        color: AppTheme.textFaint, fontSize: 12)),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;
        _scrollToBottom();

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final msg = docs[index].data() as Map<String, dynamic>;
            final isMe = msg['senderUid'] == _currentUser.uid;
            final text = msg['text'] as String? ?? '';
            final senderName = msg['senderName'] as String? ?? 'Usuario';
            final ts = msg['timestamp'] as Timestamp?;
            final timeStr = ts != null
                ? TimeOfDay.fromDateTime(ts.toDate()).format(context)
                : '';

            return _buildBubble(
              text: text,
              senderName: senderName,
              time: timeStr,
              isMe: isMe,
              showName: index == 0 ||
                  (docs[index - 1].data()
                              as Map<String, dynamic>)['senderUid'] !=
                          msg['senderUid'],
            );
          },
        );
      },
    );
  }

  Widget _buildBubble({
    required String text,
    required String senderName,
    required String time,
    required bool isMe,
    required bool showName,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: showName ? 12 : 2,
        bottom: 2,
        left: isMe ? 60 : 0,
        right: isMe ? 0 : 60,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showName && !isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                senderName,
                style: GoogleFonts.inter(
                    color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? AppTheme.accent.withOpacity(0.2) : AppTheme.bgDeep,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              border: Border.all(
                color: isMe
                    ? AppTheme.accent.withOpacity(0.3)
                    : AppTheme.border,
              ),
            ),
            child: Text(
              text,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
            child: Text(
              time,
              style: GoogleFonts.inter(color: AppTheme.textFaint, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgDeep,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.bgMid,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.border),
              ),
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle:
                      GoogleFonts.inter(color: AppTheme.textFaint, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppTheme.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: AppTheme.bgDeep, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
