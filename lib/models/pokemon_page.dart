import 'package:json_annotation/json_annotation.dart';
import 'pokemon_summary.dart';

part 'pokemon_page.g.dart';

@JsonSerializable()
class PokemonPage {
  final int count;
  final String? next;
  final String? previous;
  final List<PokemonSummary> results;

  PokemonPage(this.count, this.next, this.previous, this.results);

  factory PokemonPage.fromJson(Map<String, dynamic> json) =>
      _$PokemonPageFromJson(json);
  Map<String, dynamic> toJson() => _$PokemonPageToJson(this);
}
