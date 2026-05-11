import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './telas/inventarioPagina.dart';

final _supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://vmvktzbbhkjmenzobnnr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZtdmt0emJiaGtqbWVuem9ibm5yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg0NzYyNTYsImV4cCI6MjA5NDA1MjI1Nn0.XZS9bvYtWgc1KBboPswSXpz8y2GYLtRC0m4NoFMr0Mg',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const InventarioPagina(),
    );
  }
}
