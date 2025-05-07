import 'package:flutter/material.dart';

import '../models/pokemon_summary.dart';
import '../widgets/pokemon_card.dart';

class EvolutionTab extends StatelessWidget {
  const EvolutionTab({super.key, required this.evos});
  final List<PokemonSummary> evos;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (_, i) => SizedBox(
              width: 120,
              child: PokemonCard(pokemon: evos[i]),
            ),
            separatorBuilder: (_, __) =>
                const Icon(Icons.chevron_right, size: 32),
            itemCount: evos.length,
          ),
        ),
      ],
    );
  }
}
