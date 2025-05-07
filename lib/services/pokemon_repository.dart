import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../models/pokemon_page.dart';
import '../models/pokemon.dart';

class PokemonApiException implements Exception {
  final String message;
  final int? status;
  PokemonApiException(this.message, [this.status]);
  @override
  String toString() => 'PokemonApiException($status): $message';
}

class PokemonRepository {
  static const _base = 'https://pokeapi.co/api/v2';
  final http.Client _client;
  PokemonRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<PokemonPage> fetchPage({int limit = 50, int offset = 0}) async {
    final res = await _client
        .get(Uri.parse('$_base/pokemon?limit=$limit&offset=$offset'))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != HttpStatus.ok) {
      throw PokemonApiException('Error page', res.statusCode);
    }
    return PokemonPage.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Pokemon> fetchPokemon(String nameOrId) async {
    final res = await _client
        .get(Uri.parse('$_base/pokemon/$nameOrId'))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != HttpStatus.ok) {
      throw PokemonApiException('Error pokemon', res.statusCode);
    }
    return Pokemon.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> fetchSpecies(int id) async {
    final res = await _client
        .get(Uri.parse('$_base/pokemon-species/$id'))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != HttpStatus.ok) {
      throw PokemonApiException('Error species', res.statusCode);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchType(String type) async {
    final res = await _client
        .get(Uri.parse('$_base/type/$type'))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != HttpStatus.ok) {
      throw PokemonApiException('Error type $type', res.statusCode);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchEvolutionChain(String url) async {
    final res =
        await _client.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    if (res.statusCode != HttpStatus.ok) {
      throw PokemonApiException('Error evolution chain', res.statusCode);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
