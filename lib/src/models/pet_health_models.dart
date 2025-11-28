import 'package:hive/hive.dart';

part 'pet_health_models.g.dart'; // Asegúrate que este nombre coincida con tu archivo

@HiveType(typeId: 0)
class VaccineRecord extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  String date;
  @HiveField(2)
  String nextDose;
  @HiveField(3)
  String notes;

  VaccineRecord({
    required this.name,
    required this.date,
    required this.nextDose,
    required this.notes,
  });
}

@HiveType(typeId: 1)
class AppointmentRecord extends HiveObject {
  @HiveField(0)
  String reason;
  @HiveField(1)
  String date;
  @HiveField(2)
  String vet;
  @HiveField(3)
  String notes;

  // Aquí solucionamos el error de peso: debe ser nullable (double?)
  @HiveField(4)
  double? weightKg;

  AppointmentRecord({
    required this.reason,
    required this.date,
    required this.vet,
    required this.notes,
    this.weightKg,
  });
}

@HiveType(typeId: 2)
class MedicationRecord extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  String dose;
  @HiveField(2)
  String frequency;
  @HiveField(3)
  String startDate;
  @HiveField(4)
  String notes;

  MedicationRecord({
    required this.name,
    required this.dose,
    required this.frequency,
    required this.startDate,
    required this.notes,
  });
}

@HiveType(typeId: 3)
class NoteRecord extends HiveObject {
  @HiveField(0)
  String title;
  @HiveField(1)
  String detail;

  NoteRecord({required this.title, required this.detail});
}
