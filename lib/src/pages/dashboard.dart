import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/pet_health_models.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Referencias a los boxes
    final Box vaccinesBox = Hive.box('vaccinesBox');
    final Box appointmentsBox = Hive.box('appointmentsBox');
    final Box medicationsBox = Hive.box('medicationsBox');
    final Box notesBox = Hive.box('notesBox');

    return ListenableBuilder(
      listenable: Listenable.merge([
        vaccinesBox.listenable(),
        appointmentsBox.listenable(),
        medicationsBox.listenable(),
        notesBox.listenable(),
      ]),
      builder: (context, child) {
        // --- CÁLCULOS DE DATOS ---
        final int totalVaccines = vaccinesBox.length;
        final int totalAppointments = appointmentsBox.length;
        final int totalMedications = medicationsBox.length;

        // Última cita
        AppointmentRecord? lastAppointment;
        if (totalAppointments > 0) {
          lastAppointment =
              appointmentsBox.getAt(totalAppointments - 1) as AppointmentRecord;
        }

        // Última nota
        NoteRecord? lastNote;
        if (notesBox.isNotEmpty) {
          lastNote = notesBox.getAt(notesBox.length - 1) as NoteRecord;
        }

        // Último peso
        double? lastWeightKg;
        for (int i = appointmentsBox.length - 1; i >= 0; i--) {
          final a = appointmentsBox.getAt(i) as AppointmentRecord;
          if (a.weightKg != null) {
            lastWeightKg = a.weightKg;
            break;
          }
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA), // Fondo gris muy claro
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.notifications_none, color: Colors.grey[800]),
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                radius: 18,
                child: Icon(Icons.pets, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. SALUDO
                const Text(
                  "Resumen de Salud",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(
                  "Aquí está el estado actual de tu mascota.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),

                // 2. GRID DE ESTADÍSTICAS
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.4,
                  children: [
                    _StatCard(
                      title: "Peso Actual",
                      value: lastWeightKg != null
                          ? "${lastWeightKg.toStringAsFixed(1)} kg"
                          : "--",
                      icon: Icons.monitor_weight_outlined,
                      color: const Color(0xFF6C63FF),
                    ),
                    _StatCard(
                      title: "Vacunas",
                      value: "$totalVaccines",
                      icon: Icons.vaccines_outlined,
                      color: const Color(0xFFFF6584),
                    ),
                    _StatCard(
                      title: "Citas Totales",
                      value: "$totalAppointments",
                      icon: Icons.calendar_month_outlined,
                      color: const Color(0xFF32D74B),
                    ),
                    _StatCard(
                      title: "Medicinas",
                      value: "$totalMedications",
                      icon: Icons.medication_liquid_outlined,
                      color: const Color(0xFFFF9F0A),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 3. PRÓXIMA / ÚLTIMA CITA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Última visita al Vet",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (lastAppointment != null)
                      TextButton(
                        onPressed: () {
                          // Navegación
                        },
                        child: const Text("Ver todas"),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                _LastAppointmentCard(appointment: lastAppointment),

                const SizedBox(height: 25),

                // 4. NOTA RECIENTE
                const Text(
                  "Nota reciente",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _NotePreviewCard(note: lastNote),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------
// WIDGETS PERSONALIZADOS CON PADDING CORREGIDO
// ---------------------------------------------

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(icon, size: 80, color: color.withOpacity(0.1)),
          ),
          // CORRECCIÓN: Padding reducido de 16 a 10 para evitar overflow
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6), // Reducido un poco
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22, // Ligeramente más pequeño
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LastAppointmentCard extends StatelessWidget {
  final AppointmentRecord? appointment;

  const _LastAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    if (appointment == null) {
      return Container(
        width: double.infinity,
        // CORRECCIÓN: Padding reducido de 20 a 16
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(Icons.event_busy, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text(
              "Sin citas registradas",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B41C5), Color(0xFF5D69F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B41C5).withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      // CORRECCIÓN: Padding reducido de 20 a 14 para ganar espacio
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [Icon(Icons.event, color: Colors.white)],
              ),
            ),
            const SizedBox(width: 12), // Espacio reducido ligeramente
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment!.reason,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appointment!.date,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  if (appointment!.vet.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      "Dr. ${appointment!.vet}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotePreviewCard extends StatelessWidget {
  final NoteRecord? note;

  const _NotePreviewCard({required this.note});

  @override
  Widget build(BuildContext context) {
    if (note == null) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: Text(
            "No hay notas recientes",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      // CORRECCIÓN: Padding reducido de 16 a 12
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.sticky_note_2, color: Colors.amber, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note!.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  note!.detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
