import 'package:crudflutter/telas/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './telas/inventarioPagina.dart';
import './telas/login.dart';
import './telas/telaperfil.dart';

final _supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://uuxhvtvszzcgxosqfbxl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV1eGh2dHZzenpjZ3hvc3FmYnhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4NDE2OTgsImV4cCI6MjA5NDQxNzY5OH0.TpSfhxtbV5_4DPULose2fqGMjd86ELcaHTXZX1Nrl3M',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const SplashScreen(),
    );
  }
}
