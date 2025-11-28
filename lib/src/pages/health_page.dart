import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Asegúrate de usar hive_flutter para la reactividad
import '../models/pet_health_models.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Cajas de Hive
  late Box vaccinesBox;
  late Box appointmentsBox;
  late Box medicationsBox;
  late Box notesBox;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Inicializar cajas
    vaccinesBox = Hive.box('vaccinesBox');
    appointmentsBox = Hive.box('appointmentsBox');
    medicationsBox = Hive.box('medicationsBox');
    notesBox = Hive.box('notesBox');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Abre el diálogo correspondiente según el Tab actual (para crear nuevos)
  void _openAddDialog() {
    switch (_tabController.index) {
      case 0:
        _showVaccineDialog();
        break;
      case 1:
        _showAppointmentDialog();
        break;
      case 2:
        _showMedicationDialog();
        break;
      case 3:
        _showNoteDialog();
        break;
    }
  }

  // ================== DIÁLOGOS (CREAR Y EDITAR) ======================

  // 1. VACUNAS
  void _showVaccineDialog({VaccineRecord? existing}) {
    final name = TextEditingController(text: existing?.name ?? '');
    final date = TextEditingController(text: existing?.date ?? '');
    final next = TextEditingController(text: existing?.nextDose ?? '');
    final notes = TextEditingController(text: existing?.notes ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? "Nueva Vacuna" : "Editar Vacuna"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CustomTextField(
                controller: name,
                label: "Nombre de la vacuna",
                icon: Icons.vaccines,
              ),
              const SizedBox(height: 10),
              _CustomTextField(
                controller: date,
                label: "Fecha aplicada",
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 10),
              _CustomTextField(
                controller: next,
                label: "Próxima dosis",
                icon: Icons.update,
              ),
              const SizedBox(height: 10),
              _CustomTextField(
                controller: notes,
                label: "Notas",
                icon: Icons.note,
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.text.isEmpty) return;

              if (existing == null) {
                // Crear
                vaccinesBox.add(
                  VaccineRecord(
                    name: name.text,
                    date: date.text,
                    nextDose: next.text,
                    notes: notes.text,
                  ),
                );
              } else {
                // Editar
                existing
                  ..name = name.text
                  ..date = date.text
                  ..nextDose = next.text
                  ..notes = notes.text;
                existing.save();
              }
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // 2. CITAS
  void _showAppointmentDialog({AppointmentRecord? existing}) {
    final reason = TextEditingController(text: existing?.reason ?? '');
    final date = TextEditingController(text: existing?.date ?? '');
    final vet = TextEditingController(text: existing?.vet ?? '');
    final notes = TextEditingController(text: existing?.notes ?? '');
    final weight = TextEditingController(
      text: existing?.weightKg != null ? existing!.weightKg!.toString() : '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? "Nueva Cita" : "Editar Cita"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CustomTextField(
                controller: reason,
                label: "Motivo",
                icon: Icons.help_outline,
              ),
              const SizedBox(height: 10),
              _CustomTextField(
                controller: date,
                label: "Fecha",
                icon: Icons.calendar_month,
              ),
              const SizedBox(height: 10),
              _CustomTextField(
                controller: vet,
                label: "Veterinario",
                icon: Icons.person,
              ),
              const SizedBox(height: 10),
              _CustomTextField(
                controller: weight,
                label: "Peso (kg)",
                icon: Icons.monitor_weight,
                isNumber: true,
              ),
              const SizedBox(height: 10),
              _CustomTextField(
                controller: notes,
                label: "Notas",
                icon: Icons.note,
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (reason.text.isEmpty) return;
              double? parsedWeight = double.tryParse(
                weight.text.replaceAll(',', '.'),
              );

              if (existing == null) {
                appointmentsBox.add(
                  AppointmentRecord(
                    reason: reason.text,
                    date: date.text,
                    vet: vet.text,
                    notes: notes.text,
                    weightKg: parsedWeight,
                  ),
                );
              } else {
                existing
                  ..reason = reason.text
                  ..date = date.text
                  ..vet = vet.text
                  ..notes = notes.text
                  ..weightKg = parsedWeight;
                existing.save();
              }
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // 3. MEDICAMENTOS
  void _showMedicationDialog({MedicationRecord? existing}) {
    final name = TextEditingController(text: existing?.name ?? '');
    final dose = TextEditingController(text: existing?.dose ?? '');
    final freq = TextEditingController(text: existing?.frequency ?? '');
    final start = TextEditingController(text: existing?.startDate ?? '');
    final notes = TextEditingController(text: existing?.notes ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? "Nueva Medicina" : "Editar Medicina"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CustomTextField(
                controller: name,
                label: "Medicamento",
                icon: Icons.medication,
              ),
              const SizedBox(height: 10),
              _CustomTextField(
                controller: dose,
                label: "Dosis",
                icon: Icons.science,
              ),
              const SizedBox(height: 10),
              _CustomTextField(
                controller: freq,
                label: "Frecuencia",
                icon: Icons.access_time,
              ),
              const SizedBox(height: 10),
              _CustomTextField(
                controller: start,
                label: "Inicio",
                icon: Icons.start,
              ),
              const SizedBox(height: 10),
              _CustomTextField(
                controller: notes,
                label: "Notas",
                icon: Icons.note,
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.text.isEmpty) return;

              if (existing == null) {
                medicationsBox.add(
                  MedicationRecord(
                    name: name.text,
                    dose: dose.text,
                    frequency: freq.text,
                    startDate: start.text,
                    notes: notes.text,
                  ),
                );
              } else {
                existing
                  ..name = name.text
                  ..dose = dose.text
                  ..frequency = freq.text
                  ..startDate = start.text
                  ..notes = notes.text;
                existing.save();
              }
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // 4. NOTAS
  void _showNoteDialog({NoteRecord? existing}) {
    final title = TextEditingController(text: existing?.title ?? '');
    final detail = TextEditingController(text: existing?.detail ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? "Nueva Nota" : "Editar Nota"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CustomTextField(
              controller: title,
              label: "Título",
              icon: Icons.title,
            ),
            const SizedBox(height: 10),
            _CustomTextField(
              controller: detail,
              label: "Detalle",
              icon: Icons.text_snippet,
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (title.text.isEmpty) return;

              if (existing == null) {
                notesBox.add(
                  NoteRecord(title: title.text, detail: detail.text),
                );
              } else {
                existing
                  ..title = title.text
                  ..detail = detail.text;
                existing.save();
              }
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // ================== PANTALLA PRINCIPAL ======================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Fondo gris claro moderno
      appBar: AppBar(
        title: const Text(
          "Expediente Médico",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blueAccent,
          tabs: const [
            Tab(icon: Icon(Icons.vaccines), text: "Vacunas"),
            Tab(icon: Icon(Icons.event_note), text: "Citas"),
            Tab(icon: Icon(Icons.medication), text: "Meds"),
            Tab(icon: Icon(Icons.note_alt), text: "Notas"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // USAMOS ValueListenableBuilder PARA ACTUALIZACIÓN AUTOMÁTICA
          _buildLiveList(
            vaccinesBox,
            (item) => _buildVaccineCard(item as VaccineRecord),
          ),
          _buildLiveList(
            appointmentsBox,
            (item) => _buildAppointmentCard(item as AppointmentRecord),
          ),
          _buildLiveList(
            medicationsBox,
            (item) => _buildMedicationCard(item as MedicationRecord),
          ),
          _buildLiveList(
            notesBox,
            (item) => _buildNoteCard(item as NoteRecord),
          ),
        ],
      ),
    );
  }

  // Widget genérico para escuchar cambios en la caja
  Widget _buildLiveList(Box box, Widget Function(dynamic) builder) {
    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box box, _) {
        final items = box.values.toList();

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  "No hay registros aún",
                  style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                ),
                Text(
                  "Usa el botón + para agregar uno",
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            bottom: 80,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return builder(item);
          },
        );
      },
    );
  }

  // ================== TARJETAS DE DISEÑO ======================

  Widget _buildVaccineCard(VaccineRecord v) {
    return _BaseCard(
      icon: Icons.vaccines,
      iconColor: Colors.purpleAccent,
      title: v.name,
      subtitle: "Aplicada: ${v.date}",
      details: [
        if (v.nextDose.isNotEmpty) "Próxima: ${v.nextDose}",
        if (v.notes.isNotEmpty) v.notes,
      ],
      onEdit: () => _showVaccineDialog(existing: v),
      onDelete: () => v.delete(),
    );
  }

  Widget _buildAppointmentCard(AppointmentRecord a) {
    return _BaseCard(
      icon: Icons.calendar_month,
      iconColor: Colors.blueAccent,
      title: a.reason,
      subtitle: a.date,
      details: [
        if (a.vet.isNotEmpty) "Vet: ${a.vet}",
        if (a.weightKg != null) "Peso: ${a.weightKg} kg",
        if (a.notes.isNotEmpty) a.notes,
      ],
      onEdit: () => _showAppointmentDialog(existing: a),
      onDelete: () => a.delete(),
    );
  }

  Widget _buildMedicationCard(MedicationRecord m) {
    return _BaseCard(
      icon: Icons.medication_liquid,
      iconColor: Colors.orangeAccent,
      title: m.name,
      subtitle: "${m.dose} - ${m.frequency}",
      details: [
        if (m.startDate.isNotEmpty) "Desde: ${m.startDate}",
        if (m.notes.isNotEmpty) m.notes,
      ],
      onEdit: () => _showMedicationDialog(existing: m),
      onDelete: () => m.delete(),
    );
  }

  Widget _buildNoteCard(NoteRecord n) {
    return _BaseCard(
      icon: Icons.sticky_note_2,
      iconColor: Colors.amber,
      title: n.title,
      subtitle: n.detail,
      details: const [], // Sin detalles extra
      onEdit: () => _showNoteDialog(existing: n),
      onDelete: () => n.delete(),
    );
  }
}

// ================== WIDGETS REUTILIZABLES ======================

class _BaseCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<String> details;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BaseCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.details,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onEdit, // Al tocar la tarjeta, se edita
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          _PopupMenu(onEdit: onEdit, onDelete: onDelete),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (details.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...details.map(
                          (d) => Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              d,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
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

class _PopupMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PopupMenu({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      width: 24,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: Icon(Icons.more_vert, size: 20, color: Colors.grey[400]),
        onSelected: (value) {
          if (value == 'edit') onEdit();
          if (value == 'delete') onDelete();
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18),
                SizedBox(width: 8),
                Text("Editar"),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text("Eliminar", style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final bool isNumber;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.isNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
