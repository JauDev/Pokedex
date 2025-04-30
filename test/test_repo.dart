import 'package:pokedex/services/pokemon_repository.dart';

void main() async {
  final repo = PokemonRepository();
  final page = await repo.fetchPage(limit: 1, offset: 0);
  print('Primer Pokémon: ${page.results.first.name}');
  final detail = await repo.fetchPokemon(page.results.first.name);
  print('ID de ${detail.name}: ${detail.id}');
}
