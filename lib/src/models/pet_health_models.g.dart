// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_health_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VaccineRecordAdapter extends TypeAdapter<VaccineRecord> {
  @override
  final int typeId = 1;

  @override
  VaccineRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VaccineRecord(
      name: fields[0] as String,
      date: fields[1] as String,
      nextDose: fields[2] as String,
      notes: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VaccineRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.nextDose)
      ..writeByte(3)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaccineRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppointmentRecordAdapter extends TypeAdapter<AppointmentRecord> {
  @override
  final int typeId = 2;

  @override
  AppointmentRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppointmentRecord(
      reason: fields[0] as String,
      date: fields[1] as String,
      vet: fields[2] as String,
      notes: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppointmentRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.reason)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.vet)
      ..writeByte(3)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MedicationRecordAdapter extends TypeAdapter<MedicationRecord> {
  @override
  final int typeId = 3;

  @override
  MedicationRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicationRecord(
      name: fields[0] as String,
      dose: fields[1] as String,
      frequency: fields[2] as String,
      startDate: fields[3] as String,
      notes: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MedicationRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.dose)
      ..writeByte(2)
      ..write(obj.frequency)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NoteRecordAdapter extends TypeAdapter<NoteRecord> {
  @override
  final int typeId = 4;

  @override
  NoteRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteRecord(
      title: fields[0] as String,
      detail: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NoteRecord obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.detail);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
