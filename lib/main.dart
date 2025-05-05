import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/pokemon_repository.dart';
import 'controllers/pokemon_list_vm.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => PokemonRepository()),
        ChangeNotifierProvider(
          create: (context) =>
              PokemonListVM(context.read<PokemonRepository>())..loadMore(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// Widget arrel molt senzill ─ encara sense la llista de Pokémon
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex MVVM',
      theme: ThemeData(
        colorSchemeSeed: Colors.red,
        useMaterial3: true,
      ),
      home: const PlaceholderView(),   // ← de moment només això
    );
  }
}

/// Vista provisional per comprovar que tot compila i arrenca
class PlaceholderView extends StatelessWidget {
  const PlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokédex')),
      body: const Center(
        child: Text(
          'UI pendent de crear…',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
