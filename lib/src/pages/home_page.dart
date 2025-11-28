import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:proyecto_bt7274/src/widgets/login_form.dart';

import '../widgets/home_card.dart';

import 'health_page.dart';
import 'feeder_page.dart';
import 'alerts_page.dart';
import 'settings_page.dart';
import 'dog_breeds_page.dart';
import 'pet_reminders_page.dart';

import 'dashboard.dart';

// --- Paleta de Colores ---
// Definimos las constantes aquí para facilitar cambios futuros
const Color kPrimaryColor = Color(0xFF7E57C2); // Morado suave (DeepPurple 400)
const Color kBackgroundColor = Color(
  0xFFF5F3FA,
); // Blanco con tinte lavanda muy sutil
const Color kSurfaceColor = Colors.white;
const Color kTextPrimary = Color(0xFF332F3D); // Gris oscuro con base violeta
const Color kTextSecondary = Color(0xFF7E7B89); // Gris medio
const Color kAccentLight = Color(
  0xFFEDE7F6,
); // Lila muy claro (para fondos de iconos)

String _preferredName(User? user) {
  final dn = user?.displayName?.trim();
  if (dn != null && dn.isNotEmpty) return dn;
  final emailLocal = user?.email?.split('@').first ?? 'Usuario';
  return emailLocal;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos un Theme local para asegurar que los estilos de iconos y textos
    // se propaguen a los widgets hijos (como HomeCard si usan Theme.of)
    return Theme(
      data: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kBackgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          primary: kPrimaryColor,
          surface: kSurfaceColor,
        ),
        useMaterial3: true,
        // Estilo global para iconos
        iconTheme: const IconThemeData(color: kPrimaryColor),
      ),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          backgroundColor: kBackgroundColor, // Se funde con el fondo
          elevation: 0, // Diseño plano
          centerTitle: true,
          title: const Text(
            'PetCare',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
              letterSpacing: 0.5,
            ),
          ),
          iconTheme: const IconThemeData(color: kTextPrimary),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                tooltip: 'Cerrar sesión',
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: kPrimaryColor,
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // 🐾 Header de bienvenida
                  StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.userChanges(),
                    builder: (context, snap) {
                      final user =
                          snap.data ?? FirebaseAuth.instance.currentUser;
                      final nombreHeader = _preferredName(user);

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: kSurfaceColor,
                          borderRadius: BorderRadius.circular(24),
                          // Sombra morada suave en lugar de negra
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryColor.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: kAccentLight, // Fondo lila claro
                              child: const Icon(
                                Icons.pets,
                                size: 30,
                                color: kPrimaryColor, // Icono morado
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hola, $nombreHeader 👋',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: kTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Bienvenido a PetCare Feeder & Health',
                                    style: TextStyle(
                                      color: kTextSecondary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Editar perfil',
                              style: IconButton.styleFrom(
                                backgroundColor: kBackgroundColor,
                                highlightColor: kAccentLight,
                              ),
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: kPrimaryColor,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // 🔹 Título de sección (Opcional, para dar estructura)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8, bottom: 12),
                      child: Text(
                        "Servicios",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kTextPrimary,
                        ),
                      ),
                    ),
                  ),

                  // 🔹 Grid de accesos rápidos
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final isWide = c.maxWidth > 900;
                        final isMedium = c.maxWidth > 600;
                        final crossAxisCount = isWide ? 4 : (isMedium ? 2 : 1);

                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          // Ajusté un poco el aspect ratio para que las tarjetas respiren mejor
                          childAspectRatio: 1.3,
                          children: [
                            // Nota: Asegúrate de que tu widget HomeCard use el Theme.of(context).primaryColor
                            // o colores dinámicos para heredar este estilo morado.
                            HomeCard(
                              icon: Icons
                                  .monitor_heart_outlined, // Iconos outline son más elegantes
                              title: 'Salud',
                              subtitle: 'Mantente atento a tu mascota',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HealthPage(),
                                ),
                              ),
                            ),

                            HomeCard(
                              icon: Icons
                                  .smart_toy_outlined, // Icono alternativo para comedero
                              title: 'Comedero',
                              subtitle: 'Control y programación',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FeederPage(),
                                ),
                              ),
                            ),

                            HomeCard(
                              icon: Icons.sensors,
                              title: 'Visitas',
                              subtitle: 'Monitoreo de actividad',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AlertsPage(),
                                ),
                              ),
                            ),

                            HomeCard(
                              icon: Icons.pie_chart_outline_rounded,
                              title: 'Dashboard',
                              subtitle: 'Estadísticas y resumen',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DashboardPage(),
                                ),
                              ),
                            ),

                            HomeCard(
                              icon: Icons.settings_outlined,
                              title: 'Ajustes',
                              subtitle: 'Cuenta y seguridad',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SettingsPage(),
                                ),
                              ),
                            ),

                            HomeCard(
                              icon: Icons.search_rounded,
                              title: 'Razas',
                              subtitle: 'Enciclopedia canina',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DogBreedsPage(),
                                ),
                              ),
                            ),

                            HomeCard(
                              icon: Icons.notifications_active_outlined,
                              title: 'Recordatorios',
                              subtitle: 'Vacunas y cuidados',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PetRemindersPage(),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
