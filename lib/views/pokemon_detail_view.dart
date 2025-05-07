import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/pokemon_detail_vm.dart';
import '../services/pokemon_repository.dart';
import '../models/pokemon.dart';

class PokemonDetailView extends StatelessWidget {
  const PokemonDetailView({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          PokemonDetailVM(context.read<PokemonRepository>())..load(name),
      child: Scaffold(
        appBar: AppBar(
          title: Text(name[0].toUpperCase() + name.substring(1)),
        ),
        body: Consumer<PokemonDetailVM>(
          builder: (context, vm, _) {
            if (vm.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.error != null) {
              return Center(child: Text(vm.error!));
            }
            final p = vm.pokemon!;
            return _DetailContent(pokemon: p);
          },
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.pokemon});
  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Hero(
            tag: pokemon.id,
            child: CachedNetworkImage(
              imageUrl: pokemon.officialArtwork ?? '',
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
          TabBar(tabs: [
            Tab(text: 'Info'),
            Tab(text: 'Stats'),
          ]),
          Expanded(
            child: TabBarView(children: [
              _InfoTab(pokemon: pokemon),
              _StatsTab(pokemon: pokemon),
            ]),
          ),
        ],
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.pokemon});
  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('ID: ${pokemon.id}'),
        Text('Alçada: ${pokemon.heightDecimetres / 10} m'),
        Text('Pes: ${pokemon.weightHectograms / 10} kg'),
        const SizedBox(height: 12),
        Text('Tipus:', style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: 8,
          children: pokemon.types
              .map((t) =>
                  Chip(label: Text((t['type']['name'] as String).toUpperCase())))
              .toList(),
        ),
      ],
    );
  }
}

class _StatsTab extends StatelessWidget {
  const _StatsTab({required this.pokemon});
  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: pokemon.stats
          .map(
            (s) => ListTile(
              title: Text((s['stat']['name'] as String).toUpperCase()),
              trailing: Text(s['base_stat'].toString()),
            ),
          )
          .toList(),
    );
  }
}
