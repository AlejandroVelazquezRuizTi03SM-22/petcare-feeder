import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class FeederPage extends StatefulWidget {
  const FeederPage({super.key});

  @override
  State<FeederPage> createState() => _FeederPageState();
}

class _FeederPageState extends State<FeederPage> {
  bool _isSending = false;

  // Referencia base al comedero en la base de datos
  final DatabaseReference _feederRef =
      FirebaseDatabase.instance.ref().child('feeders').child('comedero_1');

  DatabaseReference get _manualCommandRef => _feederRef.child('manualCommand');
  DatabaseReference get _schedulesRef => _feederRef.child('schedules');

  // --- DISPENSAR AHORA (ya lo tenías) ---
  Future<void> _dispenseNow() async {
    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      await _manualCommandRef.set({
        'dispenseNow': true,
        'duration': 2, // segundos que queremos que abra el servo
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comando enviado al comedero'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar comando: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  // --- AGREGAR HORARIO DESDE LA APP ---
  Future<void> _addSchedule() async {
    final now = TimeOfDay.now();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: now,
      helpText: 'Selecciona la hora del disparo',
    );

    if (picked == null) return; // usuario canceló

    try {
      await _schedulesRef.push().set({
        'hour': picked.hour,
        'minute': picked.minute,
        'second': 0,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Horario agregado: ${picked.format(context)}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al agregar horario: $e'),
        ),
      );
    }
  }

  // --- ELIMINAR HORARIO ---
  Future<void> _deleteSchedule(String scheduleId) async {
    try {
      await _schedulesRef.child(scheduleId).remove();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Horario eliminado'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar horario: $e'),
        ),
      );
    }
  }

  String _formatTime(int hour, int minute) {
    final time = TimeOfDay(hour: hour, minute: minute);
    return time.format(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comedero'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- TÍTULO Y DESCRIPCIÓN ---
                Text(
                  'Control del comedero',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Desde aquí puedes enviar un disparo manual al comedero sin afectar '
                  'los horarios programados que tengas guardados en la nube.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // --- BOTÓN DISPENSAR AHORA ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSending ? null : _dispenseNow,
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.pets),
                    label: Text(
                      _isSending ? 'Enviando...' : 'Dispensar ahora',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Duración actual del disparo manual: 2 segundos',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 8),

                // --- CABECERA DE HORARIOS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Horarios programados',
                      style: theme.textTheme.titleMedium,
                    ),
                    TextButton.icon(
                      onPressed: _addSchedule,
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar horario'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // --- LISTA DE HORARIOS (STREAMBUILDER) ---
                Expanded(
                  child: StreamBuilder<DatabaseEvent>(
                    stream: _schedulesRef.onValue,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error al cargar horarios:\n${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      final data = snapshot.data?.snapshot.value;

                      if (data == null) {
                        return Center(
                          child: Text(
                            'No hay horarios programados.\n'
                            'Toca "Agregar horario" para crear uno.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        );
                      }

                      // snapshot.value puede ser Map dinámico
                      final Map<dynamic, dynamic> raw =
                          data as Map<dynamic, dynamic>;

                      final entries = raw.entries.toList()
                        ..sort(
                          (a, b) {
                            final ha = (a.value['hour'] ?? 0) as int;
                            final ma = (a.value['minute'] ?? 0) as int;
                            final hb = (b.value['hour'] ?? 0) as int;
                            final mb = (b.value['minute'] ?? 0) as int;
                            if (ha != hb) return ha.compareTo(hb);
                            return ma.compareTo(mb);
                          },
                        );

                      return ListView.separated(
                        itemCount: entries.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final e = entries[index];
                          final String id = e.key.toString();
                          final int hour = (e.value['hour'] ?? 0) as int;
                          final int minute = (e.value['minute'] ?? 0) as int;
                          final int second = (e.value['second'] ?? 0) as int;

                          final timeText = _formatTime(hour, minute);

                          return ListTile(
                            leading: const Icon(Icons.access_time),
                            title: Text(timeText),
                            subtitle: Text(
                              'Hora exacta: '
                              '${hour.toString().padLeft(2, '0')}:'
                              '${minute.toString().padLeft(2, '0')}:'
                              '${second.toString().padLeft(2, '0')}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Eliminar horario'),
                                    content: Text(
                                      '¿Seguro que deseas eliminar el horario de $timeText?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(true),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  _deleteSchedule(id);
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
