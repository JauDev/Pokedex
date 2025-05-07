import 'package:flutter/foundation.dart';
import '../services/pokemon_repository.dart';
import '../models/pokemon_summary.dart';
import '../models/pokemon_page.dart';
import '../models/pokemon.dart';
import '../utils/generation_utils.dart';

class PokemonListVM extends ChangeNotifier {
  PokemonListVM(this._repo);

  final PokemonRepository _repo;

  // ── Dades descarregades ─────────────────────────────────────
  final List<PokemonSummary> _all = [];
  final Map<String, Pokemon> _detailCache = {};            // nom → detall
  final Map<String, Map<String, dynamic>> _speciesCache = {}; // nom → species

  bool _loading = false;
  bool _hasNext = true;
  int _offset = 0;

  // ── Cerca i filtres ─────────────────────────────────────────
  String _search = '';
  int? _selectedGeneration;
  String? _selectedType;
  bool _onlyWithEvolution = false;

  // ── Resultat filtrat exposat a la UI ────────────────────────
  List<PokemonSummary> _filtered = [];

  List<PokemonSummary> get pokemons => List.unmodifiable(_filtered);
  bool get loading => _loading;

  // Getters públics per la vista (evitem camps privats)
  int? get selectedGeneration => _selectedGeneration;
  String? get selectedType => _selectedType;
  bool get onlyWithEvolution => _onlyWithEvolution;

  // ── Accions públiques ───────────────────────────────────────
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
      _applyFilters();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void search(String q) {
    _search = q.toLowerCase();
    _applyFilters();
  }

  void setGeneration(int? gen) {
    _selectedGeneration = gen;
    _applyFilters();
  }

  Future<void> setType(String? type) async {
    _selectedType = type;
    if (type != null) await _ensureDetailsLoaded();
    _applyFilters();
  }

  Future<void> toggleEvolution(bool value) async {
    _onlyWithEvolution = value;
    if (value) await _ensureDetailsLoaded();
    _applyFilters();
  }

  // ───────────────────────────────────────────────────────────
  // Filtrat intern
  // ───────────────────────────────────────────────────────────
  void _applyFilters() {
    Iterable<PokemonSummary> list = _all;

    if (_search.isNotEmpty) {
      list = list.where((p) => p.name.contains(_search));
    }

    if (_selectedGeneration != null) {
      list = list.where((p) {
        final id = int.parse(
            p.url.split('/').where((s) => s.isNotEmpty).last);
        return generationOfId(id) == _selectedGeneration;
      });
    }

    if (_selectedType != null) {
      list = list.where((p) =>
          _detailCache[p.name]?.types.any(
              (t) => t['type']['name'] == _selectedType) ??
          false);
    }

    if (_onlyWithEvolution) {
      list = list.where((p) =>
          (_speciesCache[p.name]?['evolves_from_species']) != null);
    }

    _filtered = list.toList();
    notifyListeners();
  }

  // ───────────────────────────────────────────────────────────
  // Carrega detalls i species per a filtres avançats
  // ───────────────────────────────────────────────────────────
  Future<void> _ensureDetailsLoaded() async {
    final namesToLoad = _all
        .map((p) => p.name)
        .where((n) => !_detailCache.containsKey(n))
        .take(100);

    for (final name in namesToLoad) {
      final detail = await _repo.fetchPokemon(name);
      _detailCache[name] = detail;

      final species = await _repo.fetchSpecies(detail.id);
      _speciesCache[name] = species;
    }
  }
}
