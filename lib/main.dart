import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'core/notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './src/models/pet_health_models.dart';

import 'firebase_options.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Variables de entorno
  await dotenv.load(fileName: ".env");

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Solo en plataformas que no sean web
  if (!kIsWeb) {
    // Timezones para notificaciones programadas
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Mexico_City'));

    // Notificaciones locales
    await NotificationService().init();
  }

  // Hive (sí funciona también en web con hive_flutter)
  await Hive.initFlutter();
  Hive.registerAdapter(VaccineRecordAdapter());
  Hive.registerAdapter(AppointmentRecordAdapter());
  Hive.registerAdapter(MedicationRecordAdapter());
  Hive.registerAdapter(NoteRecordAdapter());

  // Abrir cada box
  await Hive.openBox('vaccinesBox');
  await Hive.openBox('appointmentsBox');
  await Hive.openBox('medicationsBox');
  await Hive.openBox('notesBox');

  runApp(const PetCareApp());
}
