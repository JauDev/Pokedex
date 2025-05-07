import 'package:flutter/material.dart';
import '../models/pokemon.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key, required this.pokemon});
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
