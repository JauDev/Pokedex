import 'package:flutter/foundation.dart';
import '../services/pokemon_repository.dart';
import '../models/pokemon.dart';
import '../models/pokemon_summary.dart';

class PokemonDetailVM extends ChangeNotifier {
  PokemonDetailVM(this._repo);
  final PokemonRepository _repo;

  bool _loading = false;
  String? _error;
  Pokemon? _pokemon;
  List<PokemonSummary> _evolutions = [];

  bool get loading => _loading;
  String? get error => _error;
  Pokemon? get pokemon => _pokemon;
  List<PokemonSummary> get evolutions => _evolutions;

  Future<void> load(String nameOrId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _pokemon = await _repo.fetchPokemon(nameOrId);

      final species =
          await _repo.fetchSpecies(_pokemon!.id); // evolution_chain.url
      final evoUrl =
          (species['evolution_chain'] as Map<String, dynamic>)['url'] as String;

      final chain = await _repo.fetchEvolutionChain(evoUrl);
      _evolutions =
          _flattenChain(chain['chain'] as Map<String, dynamic>);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<PokemonSummary> _flattenChain(Map<String, dynamic> node) {
    final List<PokemonSummary> list = [];
    void traverse(Map<String, dynamic> n) {
      final sp = n['species'] as Map<String, dynamic>;
      list.add(PokemonSummary(sp['name'] as String, sp['url'] as String));
      final evolves = n['evolves_to'] as List<dynamic>;
      if (evolves.isNotEmpty) traverse(evolves.first as Map<String, dynamic>);
    }

    traverse(node);
    return list;
  }
}
