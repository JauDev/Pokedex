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

  @JsonKey(name: 'sprites')
  final _Sprites sprites;

  Pokemon(
    this.id,
    this.name,
    this.heightDecimetres,
    this.weightHectograms,
    this.sprites,
  );

  String? get officialArtwork =>
      sprites.other['official-artwork']?['front_default'] as String?;

  factory Pokemon.fromJson(Map<String, dynamic> json) =>
      _$PokemonFromJson(json);
  Map<String, dynamic> toJson() => _$PokemonToJson(this);
}

@JsonSerializable()
class _Sprites {
  final Map<String, dynamic> other;
  _Sprites(this.other);

  factory _Sprites.fromJson(Map<String, dynamic> json) =>
      _$SpritesFromJson(json);
  Map<String, dynamic> toJson() => _$SpritesToJson(this);
}
