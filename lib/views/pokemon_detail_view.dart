import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/pokemon_detail_vm.dart';
import '../services/pokemon_repository.dart';
import '../models/pokemon.dart';

import '../widgets/info_tab.dart';
import '../widgets/stats_tab.dart';
import '../widgets/evolution_tab.dart';

class PokemonDetailView extends StatelessWidget {
  const PokemonDetailView({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          PokemonDetailVM(context.read<PokemonRepository>())..load(name),
      child: Scaffold(
        appBar: AppBar(title: Text(_capitalize(name))),
        body: Consumer<PokemonDetailVM>(
          builder: (context, vm, _) {
            if (vm.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.error != null) {
              return Center(child: Text(vm.error!));
            }

            final Pokemon p = vm.pokemon!;
            return DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  Hero(
                    tag: p.id,
                    child: CachedNetworkImage(
                      imageUrl: p.officialArtwork ?? '',
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const TabBar(
                    tabs: [
                      Tab(text: 'Info'),
                      Tab(text: 'Stats'),
                      Tab(text: 'Evolució'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        InfoTab(pokemon: p),
                        StatsTab(pokemon: p),
                        EvolutionTab(evos: vm.evolutions),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
