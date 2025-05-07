import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon_summary.dart';

class PokemonCard extends StatelessWidget {
  const PokemonCard({super.key, required this.pokemon});

  final PokemonSummary pokemon;

  String get _id =>
      pokemon.url.split('/').where((s) => s.isNotEmpty).last;

  String get _artwork =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$_id.png';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        '/detail',
        arguments: pokemon.name,
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Expanded(
              child: Hero(
                tag: int.parse(_id),
                child: CachedNetworkImage(
                  imageUrl: _artwork,
                  placeholder: (_, __) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.catching_pokemon, size: 48),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
