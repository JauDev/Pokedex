import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/pokemon_summary.dart';
import '../views/pokemon_detail_view.dart';

class PokemonCard extends StatelessWidget {
  final PokemonSummary pokemon;
  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final name = pokemon.name;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PokemonDetailView(name: name),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl:
                      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${_extractId(pokemon.url)}.png',
                  placeholder: (_, __) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.error_outline),
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              // Nom i ID
              Text(
                _capitalize(name),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '#${_extractId(pokemon.url)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _extractId(String url) {
    final parts = url.split('/').where((s) => s.isNotEmpty).toList();
    return int.tryParse(parts.last) ?? 0;
  }

  String _capitalize(String s) =>
      s.substring(0, 1).toUpperCase() + s.substring(1);
}
