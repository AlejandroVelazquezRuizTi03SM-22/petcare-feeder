import 'package:flutter/material.dart';
import 'package:proyecto_bt7274/core/notification_service.dart';

class PetRemindersPage extends StatefulWidget {
  const PetRemindersPage({super.key});

  @override
  State<PetRemindersPage> createState() => _PetRemindersPageState();
}

class _PetRemindersPageState extends State<PetRemindersPage> {
  final _petNameCtrl = TextEditingController();
  String _selectedType = 'Comida';
  int _selectedMinutes = 60; // default: 60 min

  final List<String> _types = [
    'Comida',
    'Agua',
    'Baño',
    'Paseo',
    'Medicina',
    'Otro',
  ];

  final List<int> _minutesOptions = [1, 5, 10, 15, 30, 60, 120, 180];

  String _buildMessage(String petName, String type) {
    if (petName.isEmpty) petName = 'Tu mascota';

    switch (type) {
      case 'Comida':
        return '¿$petName ya comió? Es hora de su comida 🦴';
      case 'Agua':
        return 'Revisa si $petName tiene suficiente agua fresca 💧';
      case 'Baño':
        return 'Hoy le toca baño a $petName 🛁';
      case 'Paseo':
        return 'Es buen momento para sacar a pasear a $petName 🐾';
      case 'Medicina':
        return 'No olvides darle su medicina a $petName 💊';
      default:
        return 'Revisa los cuidados de $petName 💚';
    }
  }

  Future<void> _scheduleReminder() async {
    final petName = _petNameCtrl.text.trim();
    final body = _buildMessage(petName, _selectedType);
    final title = 'Recordatorio de $_selectedType';

    await NotificationService().scheduleReminder(
      title: title,
      body: body,
      after: Duration(minutes: _selectedMinutes),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Recordatorio programado en $_selectedMinutes min para $petName',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _petNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Recordatorios de cuidado')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configura un recordatorio rápido',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Nombre de la mascota
            TextField(
              controller: _petNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre de la mascota',
                hintText: 'Firulais, Luna, Max...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Tipo de recordatorio
            Row(
              children: [
                const Text('Tipo:'),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedType,
                  items: _types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Duración
            Row(
              children: [
                const Text('Recordar en:'),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _selectedMinutes,
                  items: _minutesOptions
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(
                            m < 60
                                ? '$m min'
                                : '${m ~/ 60} h${m % 60 == 0 ? '' : ' ${m % 60} min'}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMinutes = value;
                      });
                    }
                  },
                ),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _scheduleReminder,
                icon: const Icon(Icons.notifications_active),
                label: const Text('Programar recordatorio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
