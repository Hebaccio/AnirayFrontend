import 'package:json_annotation/json_annotation.dart';
import '../basic_entities/basic_entities.dart';

part 'movie_genre.g.dart';

@JsonSerializable()
class MovieGenreMU {
  final BaseClassME genre;

  const MovieGenreMU({
    required this.genre,
  });

  factory MovieGenreMU.fromJson(Map<String, dynamic> json) =>
      _$MovieGenreMUFromJson(json);

  Map<String, dynamic> toJson() => _$MovieGenreMUToJson(this);
}