import 'package:flutter/foundation.dart';
import '../services/pokemon_repository.dart';
import '../models/pokemon_summary.dart';
import '../utils/generation_utils.dart';

class PokemonListVM extends ChangeNotifier {
  PokemonListVM(this._repo);
  final PokemonRepository _repo;

  // ───── Dades ──────────────────────────────────────────────
  final List<PokemonSummary> _master = [];
  bool _loading = false;

  // ───── Filtres ───────────────────────────────────────────
  int? _gen;
  String? _type;
  String _search = '';

  // ───── Resultat visible ──────────────────────────────────
  List<PokemonSummary> _visible = [];
  List<PokemonSummary> get pokemons => List.unmodifiable(_visible);
  bool get loading => _loading;

  int? get selectedGeneration => _gen;
  String? get selectedType => _type;

  // ========================================================
  Future<void> init() async {
    await _fetchRange(1, 1025);        // carrega tots els Pokémon
    _apply();
  }

  // ───── Filtres públics ──────────────────────────────────
  Future<void> setGeneration(int? g) async {
    _gen = g;
    await _rebuild();
  }

  Future<void> setType(String? t) async {
    _type = t;
    await _rebuild();
  }

  void search(String q) {
    _search = q.toLowerCase();
    _apply();
  }

  // ───── Reconstrueix _master segons filtres ───────────────
  Future<void> _rebuild() async {
    _loading = true; notifyListeners();

    _master.clear();
    if (_gen == null && _type == null) {
      await _fetchRange(1, 1025);
    } else if (_gen != null && _type == null) {
      final r = generationRanges[_gen]!;
      await _fetchRange(r[0], r[1]);
    } else if (_gen == null && _type != null) {
      await _loadByType(_type!);
    } else {
      await _loadByType(_type!);
      final r = generationRanges[_gen]!;
      _master.removeWhere((p) {
        final id = int.parse(p.url.split('/').where((s) => s.isNotEmpty).last);
        return id < r[0] || id > r[1];
      });
    }

    _loading = false;
    _apply();
  }

  // ───── Helpers de càrrega ────────────────────────────────
  Future<void> _fetchRange(int start, int end) async {
    final page = await _repo.fetchPage(limit: end - start + 1, offset: start - 1);
    _master.addAll(page.results);
  }

  Future<void> _loadByType(String type) async {
    final data = await _repo.fetchType(type);
    final List<dynamic> pl = data['pokemon'];
    _master.addAll(pl.map((e) {
      final p = e['pokemon'] as Map<String, dynamic>;
      return PokemonSummary(p['name'] as String, p['url'] as String);
    }));
  }

  // ───── Filtrat final ─────────────────────────────────────
  void _apply() {
    Iterable<PokemonSummary> list = _master;

    if (_search.isNotEmpty) {
      list = list.where((p) => p.name.contains(_search));
    }

    _visible = list.toList();
    notifyListeners();
  }
}
