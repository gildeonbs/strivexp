// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/router.dart';

void main() {
  // Garante que o binding do Flutter foi inicializado antes de qualquer coisa
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    // ProviderScope armazena o estado de todos os providers do Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos o routerProvider criado anteriormente
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Flutter Clean Arch',
      theme: ThemeData(
        // Ativa o Material 3
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        // Configurações globais de input (opcional, mas recomendado)
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
      ),
      // Conecta o GoRouter ao MaterialApp
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

