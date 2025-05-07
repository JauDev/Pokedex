import 'package:json_annotation/json_annotation.dart';

part 'pokemon.g.dart';

@JsonSerializable()
class Pokemon {
  final int id;
  final String name;

  @JsonKey(name: 'height')
  final int heightDecimetres;

  @JsonKey(name: 'weight')
  final int weightHectograms;

  /// Llista de tipus: [{type: {name: fire}}, …]
  final List<dynamic> types;

  /// Llista d’estadístiques: [{stat: {name: hp}, base_stat: 45}, …]
  final List<dynamic> stats;

  @JsonKey(name: 'sprites')
  final Sprites sprites;

  Pokemon(
    this.id,
    this.name,
    this.heightDecimetres,
    this.weightHectograms,
    this.types,
    this.stats,
    this.sprites,
  );

  /// Artwork oficial HD
  String? get officialArtwork =>
      sprites.other['official-artwork']?['front_default'] as String?;

  factory Pokemon.fromJson(Map<String, dynamic> json) =>
      _$PokemonFromJson(json);
  Map<String, dynamic> toJson() => _$PokemonToJson(this);
}

@JsonSerializable()
class Sprites {
  final Map<String, dynamic> other;
  Sprites(this.other);

  factory Sprites.fromJson(Map<String, dynamic> json) =>
      _$SpritesFromJson(json);
  Map<String, dynamic> toJson() => _$SpritesToJson(this);
}
