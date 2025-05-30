// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pokemon _$PokemonFromJson(Map<String, dynamic> json) => Pokemon(
  (json['id'] as num).toInt(),
  json['name'] as String,
  (json['height'] as num).toInt(),
  (json['weight'] as num).toInt(),
  json['types'] as List<dynamic>,
  json['stats'] as List<dynamic>,
  Sprites.fromJson(json['sprites'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PokemonToJson(Pokemon instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'height': instance.heightDecimetres,
  'weight': instance.weightHectograms,
  'types': instance.types,
  'stats': instance.stats,
  'sprites': instance.sprites,
};

Sprites _$SpritesFromJson(Map<String, dynamic> json) =>
    Sprites(json['other'] as Map<String, dynamic>);

Map<String, dynamic> _$SpritesToJson(Sprites instance) => <String, dynamic>{
  'other': instance.other,
};
