import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appanimales/theme/app_theme.dart';
import 'package:appanimales/ChatPage.dart';

class ChatsListPage extends StatelessWidget {
  const ChatsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppTheme.bgDark,
        body: Center(
          child: Text('Debes iniciar sesión',
              style: GoogleFonts.inter(color: AppTheme.textMuted)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.chat_bubble_rounded,
                        color: AppTheme.accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text('Mis Chats',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // Lista de chats
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .where('participantes', arrayContains: currentUser.uid)
                    .orderBy('ultimoMensajeTs', descending: true)
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
                          Icon(Icons.chat_bubble_outline_rounded,
                              color: AppTheme.textFaint, size: 64),
                          const SizedBox(height: 16),
                          Text('Sin conversaciones aún',
                              style: GoogleFonts.outfit(
                                  color: AppTheme.textMuted,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text(
                            'Cuando contactes al dueño de una\nmascota, el chat aparecerá aquí.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                                color: AppTheme.textFaint, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }

                  final chats = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final data = chats[index].data() as Map<String, dynamic>;
                      final chatId = chats[index].id;
                      final participantes =
                          List<String>.from(data['participantes'] ?? []);
                      final otroUid = participantes.firstWhere(
                        (uid) => uid != currentUser.uid,
                        orElse: () => '',
                      );
                      final nombreMascota =
                          data['nombreMascota'] as String? ?? 'Mascota';
                      final ultimoMensaje =
                          data['ultimoMensaje'] as String? ?? '';
                      final ts = data['ultimoMensajeTs'] as Timestamp?;

                      return _ChatTile(
                        chatId: chatId,
                        otroUid: otroUid,
                        nombreMascota: nombreMascota,
                        ultimoMensaje: ultimoMensaje,
                        timestamp: ts,
                        idMascota: data['idMascota'] as String? ?? '',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final String chatId;
  final String otroUid;
  final String nombreMascota;
  final String ultimoMensaje;
  final Timestamp? timestamp;
  final String idMascota;

  const _ChatTile({
    required this.chatId,
    required this.otroUid,
    required this.nombreMascota,
    required this.ultimoMensaje,
    required this.timestamp,
    required this.idMascota,
  });

  Future<String> _getNombreOtro() async {
    if (otroUid.isEmpty) return 'Usuario';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(otroUid)
          .get();
      if (doc.exists) {
        return doc.data()?['nombreUsuario'] as String? ??
            doc.data()?['nombreCompleto'] as String? ??
            'Usuario';
      }
    } catch (_) {}
    return 'Usuario';
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Ayer';
    } else if (diff.inDays < 7) {
      const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return days[dt.weekday - 1];
    } else {
      return '${dt.day}/${dt.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getNombreOtro(),
      builder: (context, snapshot) {
        final nombre = snapshot.data ?? '...';
        final initials =
            nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
        final timeStr = _formatTime(timestamp);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  idMascota: idMascota,
                  nombreUsuario: nombre,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.bgDeep,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.accent.withOpacity(0.15),
                  child: Text(
                    initials,
                    style: GoogleFonts.outfit(
                        color: AppTheme.accent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            nombre,
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            timeStr,
                            style: GoogleFonts.inter(
                                color: AppTheme.textFaint, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.pets,
                                    color: AppTheme.accent, size: 10),
                                const SizedBox(width: 3),
                                Text(
                                  nombreMascota,
                                  style: GoogleFonts.inter(
                                      color: AppTheme.accent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ultimoMensaje.isNotEmpty
                            ? ultimoMensaje
                            : 'Sin mensajes aún',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                            color: AppTheme.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textFaint, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
