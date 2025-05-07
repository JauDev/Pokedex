import 'package:flutter/foundation.dart';

import '../services/pokemon_repository.dart';
import '../models/pokemon_summary.dart';
import '../models/pokemon_page.dart';
import '../utils/generation_utils.dart';

class PokemonListVM extends ChangeNotifier {
  PokemonListVM(this._repo);
  final PokemonRepository _repo;

  // ── Estat intern ────────────────────────────────────────────
  final List<PokemonSummary> _master = [];
  List<PokemonSummary> _visible = [];
  bool _loading = false;
  String? _error;

  // ── Filtres ────────────────────────────────────────────────
  int? _gen;
  String? _type;
  String  _search = '';

  // ── Getters públics ─────────────────────────────────────────
  List<PokemonSummary> get pokemons => List.unmodifiable(_visible);
  bool get loading => _loading;
  String? get error => _error;
  int? get selectedGeneration => _gen;
  String? get selectedType => _type;

  // ===========================================================
  // Inicialització (crida des de main.dart amb ..init())
  // ===========================================================
  Future<void> init() async {
    await _rebuild();
  }

  // ===========================================================
  // Accions públiques
  // ===========================================================
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

  // ===========================================================
  // Recarrega tota la llista segons filtres, amb try/catch
  // ===========================================================
  Future<void> _rebuild() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _master.clear();

      if (_gen == null && _type == null) {
        // Tots els Pokémon
        await _fetchRange(1, 1025);
      } else if (_gen != null && _type == null) {
        // Només generació
        final range = generationRanges[_gen]!;
        await _fetchRange(range[0], range[1]);
      } else if (_gen == null && _type != null) {
        // Només tipus
        await _loadByType(_type!);
      } else {
        // Generació + tipus → intersecció
        await _loadByType(_type!);
        final range = generationRanges[_gen]!;
        _master.removeWhere((p) {
          final id = int.parse(
            p.url.split('/').where((s) => s.isNotEmpty).last,
          );
          return id < range[0] || id > range[1];
        });
      }

      _apply();
    } catch (e) {
      _error = 'Error carregant dades. Revisa la connexió.';
      _visible = [];
      notifyListeners();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ===========================================================
  // Helpers HTTP
  // ===========================================================
  Future<void> _fetchRange(int start, int end) async {
    final page = await _repo.fetchPage(
      limit: end - start + 1,
      offset: start - 1,
    );
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

  // ===========================================================
  // Filtrat final (aplica cerca + devolucions)
  // ===========================================================
  void _apply() {
    Iterable<PokemonSummary> list = _master;
    if (_search.isNotEmpty) {
      list = list.where((p) => p.name.contains(_search));
    }
    _visible = list.toList();
    notifyListeners();
  }
}
