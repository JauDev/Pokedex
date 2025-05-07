import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../models/pokemon_page.dart';
import '../models/pokemon.dart';

class PokemonApiException implements Exception {
  final String message;
  final int? statusCode;
  PokemonApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'PokemonApiException($statusCode): $message';
}

class PokemonRepository {
  static const _base = 'https://pokeapi.co/api/v2';
  final http.Client _client;
  PokemonRepository({http.Client? client}) : _client = client ?? http.Client();

  // ───── llista paginada ───────────────────────────────────────
  Future<PokemonPage> fetchPage({int limit = 50, int offset = 0}) async {
    final uri = Uri.parse('$_base/pokemon?limit=$limit&offset=$offset');
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != HttpStatus.ok) {
      throw PokemonApiException('Error ${res.statusCode} page', res.statusCode);
    }
    return PokemonPage.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ───── detall d’un Pokémon ───────────────────────────────────
  Future<Pokemon> fetchPokemon(String nameOrId) async {
    final uri = Uri.parse('$_base/pokemon/$nameOrId');
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != HttpStatus.ok) {
      throw PokemonApiException('Error ${res.statusCode} pokemon', res.statusCode);
    }
    return Pokemon.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ───── species (per trobar evolution chain) ──────────────────
  Future<Map<String, dynamic>> fetchSpecies(int id) async {
    final uri = Uri.parse('$_base/pokemon-species/$id');
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != HttpStatus.ok) {
      throw PokemonApiException('Error ${res.statusCode} species', res.statusCode);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ───── evolution chain (rep url sencera) ─────────────────────
  Future<Map<String, dynamic>> fetchEvolutionChain(String url) async {
    final res = await _client.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    if (res.statusCode != HttpStatus.ok) {
      throw PokemonApiException('Error ${res.statusCode} evolution', res.statusCode);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
