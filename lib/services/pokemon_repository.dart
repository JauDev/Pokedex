import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
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

  Future<PokemonPage> fetchPage({
    int limit = 50,
    int offset = 0,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final uri = Uri.parse('$_base/pokemon?limit=$limit&offset=$offset');

    try {
      final res = await _client.get(uri).timeout(timeout);
      if (res.statusCode != HttpStatus.ok) {
        throw PokemonApiException(
          'Error ${res.statusCode} descarregant pàgina ($uri)',
          res.statusCode,
        );
      }
      return compute(_parsePage, res.body);
    } on SocketException {
      throw PokemonApiException('Sense connexió a Internet');
    } on TimeoutException {
      throw PokemonApiException('La petició ha superat el temps límit');
    }
  }

  Future<Pokemon> fetchPokemon(
    String nameOrId, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final uri = Uri.parse('$_base/pokemon/$nameOrId');

    try {
      final res = await _client.get(uri).timeout(timeout);
      if (res.statusCode != HttpStatus.ok) {
        throw PokemonApiException(
          'Error ${res.statusCode} descarregant $nameOrId',
          res.statusCode,
        );
      }
      return compute(_parsePokemon, res.body);
    } on SocketException {
      throw PokemonApiException('Sense connexió a Internet');
    } on TimeoutException {
      throw PokemonApiException('La petició ha superat el temps límit');
    }
  }

  static PokemonPage _parsePage(String body) =>
      PokemonPage.fromJson(jsonDecode(body) as Map<String, dynamic>);

  static Pokemon _parsePokemon(String body) =>
      Pokemon.fromJson(jsonDecode(body) as Map<String, dynamic>);
}
