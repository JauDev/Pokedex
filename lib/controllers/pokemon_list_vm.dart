import 'package:flutter/foundation.dart';
import '../services/pokemon_repository.dart';
import '../models/pokemon_summary.dart';
import '../models/pokemon_page.dart';

class PokemonListVM extends ChangeNotifier {
    PokemonListVM(this._repo);

    final PokemonRepository _repo;
    final List<PokemonSummary> _all = [];

    // Estat intern
    bool _loading = false;
    bool _hasNext = true;
    int _offset = 0;

    List<PokemonSummary>? _filtered;

    // Getters per a la UI
    List<PokemonSummary> get pokemons =>
        List.unmodifiable(_filtered ?? _all);
    bool get loading => _loading;

    /// Carrega la següent pàgina (50 ítems per defecte)
    Future<void> loadMore() async {
        if (_loading || !_hasNext) return;
        _loading = true;
        notifyListeners();

        try {
            final PokemonPage page =
                await _repo.fetchPage(limit: 50, offset: _offset);
            _all.addAll(page.results);
            _offset += page.results.length;
            _hasNext = page.next != null;
        } catch (_) {
            rethrow;
        } finally {
            _loading = false;
            notifyListeners();
        }
    }
}