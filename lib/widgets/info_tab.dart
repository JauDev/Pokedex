import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/type_utils.dart';
import '../models/pokemon.dart';

class InfoTab extends StatelessWidget {
  const InfoTab({super.key, required this.pokemon});
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
          children: pokemon.types.map((t) {
            final tName = t['type']['name'] as String;
            return Chip(
              label: Text(tName.toUpperCase()),
              backgroundColor: typeColors[tName] ?? Colors.grey,
              avatar: SvgPicture.asset(
                typeAsset(tName),
                width: 20,
                height: 20,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
