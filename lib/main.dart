import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/pokemon_repository.dart';
import 'controllers/pokemon_list_vm.dart';
import 'views/pokemon_list_view.dart';

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
      home: const PokemonListView(),
      // routes: {
      //   '/': (_) => const PokemonListView(),
      //   '/detail': (context) {
      //     final name = ModalRoute.of(context)!.settings.arguments as String;
      //     return PokemonDetailView(name: name);
      //   },
      // },
    );
  }
}
