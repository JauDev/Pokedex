import 'package:flutter/foundation.dart';
import '../services/pokemon_repository.dart';
import '../models/pokemon_summary.dart';
import '../models/pokemon_page.dart';
import '../models/pokemon.dart';
import '../utils/generation_utils.dart';

class PokemonListVM extends ChangeNotifier {
  PokemonListVM(this._repo);

  final PokemonRepository _repo;

  // ── Caches ─────────────────────────────────────────────────
  final List<PokemonSummary> _all = [];
  final Map<String, Pokemon> _detailCache = {};            // nom → detall
  final Map<String, Map<String, dynamic>> _speciesCache = {}; // nom → species

  // ── Estat dels filtres ────────────────────────────────────
  String _search = '';
  int? _selectedGeneration;
  String? _selectedType;
  EvoStage _selectedStage = EvoStage.any;

  // ── Estat de càrrega/paginació ────────────────────────────
  bool _loading = false;
  int _nextOffset = 0;
  bool _exhausted = false;

  // ── Resultat filtrat ──────────────────────────────────────
  List<PokemonSummary> _filtered = [];
  List<PokemonSummary> get pokemons => List.unmodifiable(_filtered);
  bool get loading => _loading;

  int? get selectedGeneration => _selectedGeneration;
  String? get selectedType => _selectedType;
  EvoStage get selectedStage => _selectedStage;

  // ──────────────────────────────────────────────────────────
  // Accions públiques
  // ──────────────────────────────────────────────────────────
  Future<void> loadMore() async {
    if (_loading || _exhausted || _selectedGeneration != null) return;
    _loading = true; notifyListeners();

    final page = await _repo.fetchPage(limit: 50, offset: _nextOffset);
    _all.addAll(page.results);
    _nextOffset += page.results.length;
    _exhausted = page.next == null;

    _loading = false;
    _applyFilters();
  }

  Future<void> setGeneration(int? gen) async {
    _selectedGeneration = gen;
    if (gen != null) {
      await _loadGeneration(gen);
    }
    _applyFilters();
  }

  Future<void> setType(String? type) async {
    _selectedType = type;
    if (type != null) {
      await _loadTypeList(type);
    }
    _applyFilters();
  }

  Future<void> setStage(EvoStage stage) async {
    _selectedStage = stage;
    if (stage != EvoStage.any) {
      await _ensureSpeciesLoaded();
    }
    _applyFilters();
  }

  void search(String q) {
    _search = q.toLowerCase();
    _applyFilters();
  }

  // ──────────────────────────────────────────────────────────
  // Càrrega dirigida per filtres
  // ──────────────────────────────────────────────────────────
  Future<void> _loadGeneration(int gen) async {
    final (start, end) = generationRanges[gen]!;
    final limit = end - start + 1;
    _loading = true; notifyListeners();

    final page =
        await _repo.fetchPage(limit: limit, offset: start - 1);
    _all
      ..clear()
      ..addAll(page.results);
    _detailCache.clear();
    _speciesCache.clear();
    _loading = false;
  }

  Future<void> _loadTypeList(String type) async {
    // endpoint /type/{name}
    final data = await _repo.fetchType(type);
    final List<dynamic> pl = data['pokemon'];
    _all
      ..clear()
      ..addAll(pl.map((e) {
        final p = e['pokemon'] as Map<String, dynamic>;
        return PokemonSummary(p['name'] as String, p['url'] as String);
      }));
    _detailCache.clear();
    _speciesCache.clear();
  }

  Future<void> _ensureSpeciesLoaded() async {
    final names = _all.map((p) => p.name).where(
          (n) => !_speciesCache.containsKey(n),
        );

    for (final name in names) {
      // Detall
      if (!_detailCache.containsKey(name)) {
        _detailCache[name] = await _repo.fetchPokemon(name);
      }
      // Species
      final id = _detailCache[name]!.id;
      _speciesCache[name] = await _repo.fetchSpecies(id);
    }
  }

  // ──────────────────────────────────────────────────────────
  // Filtrat intern
  // ──────────────────────────────────────────────────────────
  void _applyFilters() {
    Iterable<PokemonSummary> list = _all;

    // cerca text
    if (_search.isNotEmpty) {
      list = list.where((p) => p.name.contains(_search));
    }

    // tipus
    if (_selectedType != null) {
      list = list.where((p) => _detailCache[p.name]?.types
              .any((t) => t['type']['name'] == _selectedType) ??
          false);
    }

    // etapa evolutiva
    if (_selectedStage != EvoStage.any) {
      list = list.where((p) {
        final spec = _speciesCache[p.name];
        if (spec == null) return false;
        final hasPrev = spec['evolves_from_species'] != null;
        final evolves = (spec['evolution_chain'] as Map)['url'] != null;
        switch (_selectedStage) {
          case EvoStage.base:
            return !hasPrev && evolves;
          case EvoStage.middle:
            return hasPrev && evolves;
          case EvoStage.finalStage:
            return hasPrev && !evolves;
          case EvoStage.any:
            return true;
        }
      });
    }

    _filtered = list.toList();
    notifyListeners();
  }
}
