import 'package:pokedex/services/pokemon_repository.dart';
import 'package:pokedex/utils/logger.dart';

void main() async {
  final repo = PokemonRepository();
  final page = await repo.fetchPage(limit: 1, offset: 0);
  log.i('Primer Pokémon: ${page.results.first.name}');
  final detail = await repo.fetchPokemon(page.results.first.name);
  log.i('ID de ${detail.name}: ${detail.id}');
}
