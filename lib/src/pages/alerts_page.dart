import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(.12),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  final String label;
  final String value;
  const _KeyValueRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  const _EmptyCard({
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 28, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(message, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double height;
  const _SkeletonCard({this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFEDEDED), Color(0xFFF6F6F6)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }
}

_StatusVisuals _mapStateToVisuals(String state) {
  switch (state.toUpperCase()) {
    case 'EATING':
    case 'ACTIVE':
      return const _StatusVisuals(Colors.green, Icons.check_circle);
    case 'NEAR':
    case 'DETECTED':
      return const _StatusVisuals(Colors.orange, Icons.sensors);
    case 'IDLE':
    default:
      return const _StatusVisuals(Colors.blueGrey, Icons.hourglass_empty);
  }
}

double _stateProgress(String state) {
  switch (state.toUpperCase()) {
    case 'EATING':
    case 'ACTIVE':
      return 1.0;
    case 'NEAR':
    case 'DETECTED':
      return 0.6;
    case 'IDLE':
    default:
      return 0.2;
  }
}

class _StatusVisuals {
  final Color color;
  final IconData icon;
  const _StatusVisuals(this.color, this.icon);
}

String _relativeTime(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);
  if (diff.inSeconds < 60) return "Hace ${diff.inSeconds}s";
  if (diff.inMinutes < 60) return "Hace ${diff.inMinutes} min";
  if (diff.inHours < 24) return "Hace ${diff.inHours} h";
  return "Hace ${diff.inDays} d";
}

class _AlertsPageState extends State<AlertsPage> {
  late FirebaseDatabase database;
  late DatabaseReference visitsRef;

  int totalVisits = 0;

  @override
  void initState() {
    super.initState();

    database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: "https://petcare-56dc6-default-rtdb.firebaseio.com",
    );

    visitsRef = database.ref("pets/miPrimerPet/feederVisits");

    // 🔹 Escucha TODAS las visitas y cuenta solo las que tengan event = 'visit'
    visitsRef.onValue.listen((event) {
      final snap = event.snapshot;
      if (!snap.exists || snap.value == null) {
        setState(() => totalVisits = 0);
        return;
      }

      final raw = snap.value as Map;
      final data = Map<dynamic, dynamic>.from(raw);

      int count = 0;
      data.forEach((key, value) {
        if (value is Map) {
          final mapVal = Map<dynamic, dynamic>.from(value);
          final ev = (mapVal['event'] ?? '').toString().toLowerCase();
          if (ev == 'visit') {
            count++;
          }
        }
      });

      setState(() => totalVisits = count);
    });
  }

  // Stream para obtener la última visita (la que el bridge escribe hasta el final)
  Stream<Map<String, dynamic>> lastVisitStream() {
    return visitsRef.limitToLast(1).onValue.map((event) {
      if (event.snapshot.value == null) return {};
      final raw = event.snapshot.value as Map;
      final data = Map<String, dynamic>.from(
        raw.map((key, value) => MapEntry(key.toString(), value)),
      );
      final lastKey = data.keys.first;
      final lastVal = data[lastKey];
      if (lastVal is Map) {
        return Map<String, dynamic>.from(
          lastVal.map((k, v) => MapEntry(k.toString(), v)),
        );
      }
      return {};
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Alertas y Visitas")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Resumen del comedero",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              _MetricCard(
                title: "Visitas al comedero",
                value: "$totalVisits",
                icon: Icons.pets,
                subtitle: "Conteo acumulado (event = 'visit')",
                color: Colors.indigo,
              ),
              const SizedBox(height: 16),

              StreamBuilder<Map<String, dynamic>>(
                stream: lastVisitStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _SkeletonCard(height: 140);
                  }

                  final hasData = snapshot.hasData && snapshot.data!.isNotEmpty;
                  if (!hasData) {
                    return const _EmptyCard(
                      title: "Esperando datos del comedero…",
                      icon: Icons.sensors_rounded,
                      message: "Aún no hay eventos registrados.",
                    );
                  }

                  final visit = snapshot.data!;
                  final String event = (visit['event'] ?? '—')
                      .toString()
                      .toUpperCase();
                  final num? distanceNum = visit['distance_cm'] is num
                      ? visit['distance_cm'] as num
                      : num.tryParse("${visit['distance_cm']}");
                  final double distance = (distanceNum ?? 0).toDouble();
                  // en tus eventos del puente no viene 'state', así que dejamos 'IDLE' por defecto
                  final String state = (visit['state'] ?? 'IDLE')
                      .toString()
                      .toUpperCase();
                  final int? ts = visit['timestamp'] is int
                      ? visit['timestamp'] as int
                      : int.tryParse("${visit['timestamp']}");
                  final DateTime? when = ts != null
                      ? DateTime.fromMillisecondsSinceEpoch(ts).toLocal()
                      : null;

                  final status = _mapStateToVisuals(state);

                  return Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: status.color.withOpacity(
                                      .12,
                                    ),
                                    child: Icon(
                                      status.icon,
                                      color: status.color,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Último evento",
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              Chip(
                                label: Text(
                                  state,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                backgroundColor: status.color.withOpacity(.12),
                                side: BorderSide(
                                  color: status.color.withOpacity(.4),
                                ),
                                labelStyle: TextStyle(color: status.color),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          _KeyValueRow(label: "Evento", value: event),
                          _KeyValueRow(
                            label: "Distancia",
                            value: "${distance.toStringAsFixed(2)} cm",
                          ),
                          _KeyValueRow(
                            label: "Momento",
                            value: when != null
                                ? "${_relativeTime(when)}  •  ${when.toString().split('.').first}"
                                : "—",
                          ),

                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _stateProgress(state),
                              minHeight: 8,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                status.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
