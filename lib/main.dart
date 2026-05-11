import 'package:flutter/material.dart';
import 'package:eyexaminer_refactor/screens/landing_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eyexaminer_refactor/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://yglijphndhguocwnptzn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlnbGlqcGhuZGhndW9jd25wdHpuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg0NTA0NTAsImV4cCI6MjA5NDAyNjQ1MH0.JasXbOYsuCdWMVAxTVklRIlhDl2LuZk2o5Z0QxzSHJs',
  );
  await NotificationService.initializeNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return (MaterialApp(
      title: 'Eyexaminer',
      theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
      home: LandingPage(),
      debugShowCheckedModeBanner: false,
    ));
  }
}
