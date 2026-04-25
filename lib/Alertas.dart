import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appanimales/theme/app_theme.dart';

class AlertasPage extends StatefulWidget {
  const AlertasPage({super.key});

  @override
  _AlertasPageState createState() => _AlertasPageState();
}

class _AlertasPageState extends State<AlertasPage> {
  String _filtroActivo = 'Todas';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFiltros(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 12, top: 8),
                    child: Text('NUEVAS', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                  _buildAlertaCard(
                    color: const Color(0xFF4A68FF),
                    icon: Icons.search_rounded,
                    badgeIcon: Icons.check,
                    titulo: 'Posible coincidencia encontrada',
                    tiempo: 'ahora',
                    isNueva: true,
                    content: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
                        children: [
                          const TextSpan(text: 'Encontramos un perro '),
                          TextSpan(text: 'similar a Max', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                          const TextSpan(text: ' reportado en '),
                          TextSpan(text: 'Ñuñoa', style: GoogleFonts.inter(color: const Color(0xFF4A68FF), fontWeight: FontWeight.bold)),
                          const TextSpan(text: ' — '),
                          TextSpan(text: '87% de similitud', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                          const TextSpan(text: ' según foto.'),
                        ],
                      ),
                    ),
                    botones: [
                      _BotonAlerta(texto: 'Ver coincidencia', color: const Color(0xFF4A68FF)),
                      _BotonAlerta(texto: 'No es él', color: AppTheme.textMuted),
                    ],
                  ),
                  _buildAlertaCard(
                    color: const Color(0xFFFFB020),
                    icon: Icons.visibility_rounded,
                    badgeIcon: Icons.access_time_filled,
                    titulo: 'Avistamiento de Rocky',
                    tiempo: '5 min',
                    isNueva: true,
                    content: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
                        children: [
                          TextSpan(text: '@juan_p', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                          const TextSpan(text: ' reportó verlo en '),
                          TextSpan(text: 'Av. Italia con Carmen', style: GoogleFonts.inter(color: const Color(0xFFFFB020))),
                          const TextSpan(text: '. Lleva el collar puesto.'),
                        ],
                      ),
                    ),
                    botones: [
                      _BotonAlerta(texto: 'Ver en mapa', color: const Color(0xFFFFB020)),
                      _BotonAlerta(texto: 'Contactar', color: AppTheme.accent),
                    ],
                  ),
                  _buildAlertaCard(
                    color: AppTheme.danger,
                    icon: Icons.pets_rounded,
                    badgeIcon: Icons.priority_high_rounded,
                    titulo: 'Mascota perdida a 800m',
                    tiempo: '12 min',
                    isNueva: true,
                    content: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
                        children: [
                          TextSpan(text: 'Thor', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                          const TextSpan(text: ' — Pastor alemán, macho. Perdido en '),
                          TextSpan(text: 'Parque Bustamante', style: GoogleFonts.inter(color: AppTheme.danger)),
                          const TextSpan(text: '. Puede que pase cerca de ti.'),
                        ],
                      ),
                    ),
                    botones: [
                      _BotonAlerta(texto: 'Ver alerta', color: AppTheme.danger),
                      _BotonAlerta(texto: 'Lo vi', color: AppTheme.accent),
                    ],
                  ),
                  _buildAlertaCard(
                    color: AppTheme.accent,
                    icon: Icons.campaign_rounded,
                    badgeIcon: Icons.check,
                    titulo: 'Tu alerta fue compartida',
                    tiempo: '28 min',
                    isNueva: true,
                    content: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
                        children: [
                          TextSpan(text: '34 personas', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                          const TextSpan(text: ' compartieron la alerta de '),
                          TextSpan(text: 'Rocky', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                          const TextSpan(text: ' en la última hora. Alcance: '),
                          TextSpan(text: '+1.200 usuarios.', style: GoogleFonts.inter(color: AppTheme.accent)),
                        ],
                      ),
                    ),
                    botones: [],
                  ),
                  _buildAlertaCard(
                    color: AppTheme.accent,
                    icon: Icons.celebration_rounded,
                    badgeIcon: Icons.check,
                    titulo: '¡Coco fue encontrado!',
                    tiempo: '1h',
                    isNueva: true,
                    content: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
                        children: [
                          const TextSpan(text: 'La alerta que compartiste de '),
                          TextSpan(text: 'Coco', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                          const TextSpan(text: ' fue marcada como '),
                          TextSpan(text: 'resuelta', style: GoogleFonts.inter(color: AppTheme.accent)),
                          const TextSpan(text: '. Gracias por ayudar.'),
                        ],
                      ),
                    ),
                    botones: [],
                  ),
                  
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppTheme.border.withOpacity(0.5))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Anteriores', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11)),
                      ),
                      Expanded(child: Divider(color: AppTheme.border.withOpacity(0.5))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildAlertaCard(
                    color: const Color(0xFFFFB020),
                    icon: Icons.visibility_rounded,
                    titulo: 'Avistamiento de Rocky',
                    tiempo: 'ayer',
                    isNueva: false,
                    content: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
                        children: [
                          TextSpan(text: '@maria_k', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                          const TextSpan(text: ' reportó verlo cerca del Metro Baquedano.'),
                        ],
                      ),
                    ),
                    botones: [],
                  ),
                  _buildAlertaCard(
                    color: AppTheme.danger,
                    icon: Icons.room_rounded,
                    titulo: 'Zona de búsqueda actualizada',
                    tiempo: 'ayer',
                    isNueva: false,
                    content: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
                        children: [
                          const TextSpan(text: 'Basado en avistamientos, el radio probable de '),
                          TextSpan(text: 'Rocky', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                          const TextSpan(text: ' se actualizó a Providencia Sur.'),
                        ],
                      ),
                    ),
                    botones: [],
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chevron_left_rounded, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alertas', style: GoogleFonts.outfit(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('5 sin leer', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text('Marcar todo leído', style: GoogleFonts.inter(color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FiltroPill(titulo: 'Todas', badge: '5', isSelected: _filtroActivo == 'Todas', color: AppTheme.accent, onTap: () => setState(() => _filtroActivo = 'Todas')),
          const SizedBox(width: 8),
          _FiltroPill(titulo: 'Perdidos', badge: '3', isSelected: _filtroActivo == 'Perdidos', color: AppTheme.danger, onTap: () => setState(() => _filtroActivo = 'Perdidos')),
          const SizedBox(width: 8),
          _FiltroPill(titulo: 'Avistados', badge: '', isSelected: _filtroActivo == 'Avistados', color: Colors.transparent, onTap: () => setState(() => _filtroActivo = 'Avistados')),
          const SizedBox(width: 8),
          _FiltroPill(titulo: 'Encontrados', badge: '', isSelected: _filtroActivo == 'Encontrados', color: Colors.transparent, onTap: () => setState(() => _filtroActivo = 'Encontrados')),
        ],
      ),
    );
  }

  Widget _buildAlertaCard({
    required Color color,
    required IconData icon,
    IconData? badgeIcon,
    required String titulo,
    required String tiempo,
    required bool isNueva,
    required Widget content,
    required List<Widget> botones,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: AppTheme.bgDeep.withOpacity(0.5),
        border: Border(
          left: BorderSide(color: isNueva ? color : Colors.transparent, width: 3),
          bottom: const BorderSide(color: Colors.black12, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.3), width: 1.5),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              if (badgeIcon != null)
                Positioned(
                  bottom: -2, right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: color, 
                      shape: BoxShape.circle, 
                      border: Border.all(color: AppTheme.bgDark, width: 2)
                    ),
                    child: Icon(badgeIcon, color: Colors.white, size: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(titulo, style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text(tiempo, style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11)),
                    if (isNueva) ...[
                      const SizedBox(width: 8),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 8, height: 8, 
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                    ] else ...[
                      const SizedBox(width: 16), // Para alinear con los que tienen punto
                    ]
                  ],
                ),
                const SizedBox(height: 6),
                content,
                if (botones.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: botones,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltroPill extends StatelessWidget {
  final String titulo;
  final String badge;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FiltroPill({required this.titulo, required this.badge, required this.isSelected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool hasBg = color != Colors.transparent && isSelected;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: hasBg ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: hasBg ? color.withOpacity(0.5) : AppTheme.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titulo, 
              style: GoogleFonts.inter(
                color: hasBg ? color : AppTheme.textMuted, 
                fontSize: 13, 
                fontWeight: hasBg ? FontWeight.w600 : FontWeight.w500
              )
            ),
            if (badge.isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(color: hasBg ? color.withOpacity(0.3) : AppTheme.border, borderRadius: BorderRadius.circular(10)),
                child: Text(badge, style: GoogleFonts.inter(color: hasBg ? color : AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _BotonAlerta extends StatelessWidget {
  final String texto;
  final Color color;

  const _BotonAlerta({required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(texto, style: GoogleFonts.inter(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}
