// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PokemonPage _$PokemonPageFromJson(Map<String, dynamic> json) => PokemonPage(
  (json['count'] as num).toInt(),
  json['next'] as String?,
  json['previous'] as String?,
  (json['results'] as List<dynamic>)
      .map((e) => PokemonSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PokemonPageToJson(PokemonPage instance) =>
    <String, dynamic>{
      'count': instance.count,
      'next': instance.next,
      'previous': instance.previous,
      'results': instance.results,
    };
