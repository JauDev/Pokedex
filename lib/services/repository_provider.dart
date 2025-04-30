import 'package:provider/provider.dart';
import 'pokemon_repository.dart';

final pokemonRepositoryProvider = Provider<PokemonRepository>(
  create: (_) => PokemonRepository(),
);