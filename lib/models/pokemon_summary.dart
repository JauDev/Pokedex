import 'package:json_annotation/json_annotation.dart';

part 'pokemon_summary.g.dart';

@JsonSerializable()
class PokemonSummary {
  final String name;
  final String url;

  PokemonSummary(this.name, this.url);

  factory PokemonSummary.fromJson(Map<String, dynamic> json) =>
      _$PokemonSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$PokemonSummaryToJson(this);
}
