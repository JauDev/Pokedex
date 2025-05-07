import 'package:flutter/foundation.dart';
import '../services/pokemon_repository.dart';
import '../models/pokemon.dart';

class PokemonDetailVM extends ChangeNotifier {
  PokemonDetailVM(this._repo);

  final PokemonRepository _repo;

  bool _loading = false;
  String? _error;
  Pokemon? _pokemon;

  bool get loading => _loading;
  String? get error => _error;
  Pokemon? get pokemon => _pokemon;

  Future<void> load(String nameOrId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _pokemon = await _repo.fetchPokemon(nameOrId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
