import 'package:flutter/foundation.dart';
import '../services/pokemon_repository.dart';
import '../models/pokemon_summary.dart';
import '../models/pokemon_page.dart';
import '../models/pokemon.dart';
import '../utils/generation_utils.dart';   // ← fa servir EvoStage i ranges

class PokemonListVM extends ChangeNotifier {
  PokemonListVM(this._repo);
  final PokemonRepository _repo;

  // ── Dades ───────────────────────────────────────────────────
  final List<PokemonSummary> _master = [];
  final Map<String, Pokemon> _detail = {};
  final Map<String, _SpecInfo> _specInfo = {};

  // ── Filtres ─────────────────────────────────────────────────
  int? _gen;
  String? _type;
  EvoStage _stage = EvoStage.any;
  String _search = '';

  bool _loading = false;

  // ── Getters ─────────────────────────────────────────────────
  List<PokemonSummary> _visible = [];
  List<PokemonSummary> get pokemons => List.unmodifiable(_visible);
  bool get loading => _loading;

  int? get selectedGeneration => _gen;
  String? get selectedType => _type;
  EvoStage get selectedStage => _stage;

  // ===========================================================
  Future<void> init() async {
    await _loadPage(offset: 0, limit: 200);
    _applyFilters();
  }

  // ── Accions públicues ───────────────────────────────────────
  Future<void> setGeneration(int? g) async {
    _gen = g;
    await _rebuild();
  }

  Future<void> setType(String? t) async {
    _type = t;
    await _rebuild();
  }

  Future<void> setStage(EvoStage s) async {
    _stage = s;
    if (s != EvoStage.any) await _ensureSpecies();
    _applyFilters();
  }

  void search(String q) {
    _search = q.toLowerCase();
    _applyFilters();
  }

  // ── Reconstrueix la llista mestra segons filtres ────────────
  Future<void> _rebuild() async {
    _loading = true; notifyListeners();

    _master.clear();
    _detail.clear();
    _specInfo.clear();

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

    if (_stage != EvoStage.any) await _ensureSpecies();
    _loading = false;
    _applyFilters();
  }

  // ── Helpers de càrrega ─────────────────────────────────────
  Future<void> _loadPage({required int offset, required int limit}) async {
    final page = await _repo.fetchPage(limit: limit, offset: offset);
    _master.addAll(page.results);
  }

  Future<void> _fetchRange(int start, int end) async =>
      _loadPage(offset: start - 1, limit: end - start + 1);

  Future<void> _loadByType(String type) async {
    final data = await _repo.fetchType(type);
    final List<dynamic> pl = data['pokemon'];
    _master.addAll(pl.map((e) {
      final p = e['pokemon'] as Map<String, dynamic>;
      return PokemonSummary(p['name'] as String, p['url'] as String);
    }));
  }

  // ── Species + evolució ─────────────────────────────────────
  Future<void> _ensureSpecies() async {
    for (final p in _master) {
      if (_specInfo.containsKey(p.name)) continue;
      final det = await _repo.fetchPokemon(p.name);
      final sp = await _repo.fetchSpecies(det.id);
      final evoUrl = (sp['evolution_chain'] as Map)['url'] as String;
      final chain = await _repo.fetchEvolutionChain(evoUrl);
      _specInfo[p.name] = _analyse(chain['chain'], p.name);
    }
  }

  _SpecInfo _analyse(Map<String, dynamic> node, String target) {
    bool prev = false, next = false;
    void dfs(Map<String, dynamic> n, {bool hasPrev = false}) {
      final name = (n['species'] as Map)['name'] as String;
      if (name == target) {
        prev = hasPrev;
        next = (n['evolves_to'] as List).isNotEmpty;
      }
      for (final nxt in n['evolves_to'] as List) {
        dfs(nxt as Map<String, dynamic>, hasPrev: true);
      }
    }

    dfs(node);
    return _SpecInfo(prev, next);
  }

  // ── Filtrat final ───────────────────────────────────────────
  void _applyFilters() {
    Iterable<PokemonSummary> list = _master;

    if (_search.isNotEmpty) {
      list = list.where((p) => p.name.contains(_search));
    }

    if (_type != null) {
      list = list.where((p) =>
          _detail[p.name]?.types.any(
              (t) => t['type']['name'] == _type) ??
          true);
    }

    if (_stage != EvoStage.any) {
      list = list.where((p) {
        final i = _specInfo[p.name];
        if (i == null) return false;
        switch (_stage) {
          case EvoStage.base:
            return !i.prev && i.next;
          case EvoStage.middle:
            return i.prev && i.next;
          case EvoStage.finalStage:
            return i.prev && !i.next;
          case EvoStage.any:
            return true;
        }
      });
    }

    _visible = list.toList();
    notifyListeners();
  }
}

// Info evolutiva simplificada
class _SpecInfo {
  final bool prev;
  final bool next;
  const _SpecInfo(this.prev, this.next);
}
