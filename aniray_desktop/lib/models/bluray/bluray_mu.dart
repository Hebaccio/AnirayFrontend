import 'package:json_annotation/json_annotation.dart';

import '../baseclass/base_class_short_mu.dart';

part 'bluray_mu.g.dart';

@JsonSerializable()
class BluRayMU {
  final int movieId;
  final int id;
  final String image;
  final String title;
  final String description;
  final DateTime releaseDate;
  final BaseClassShortMU videoFormat;
  final BaseClassShortMU audioFormat;
  final int discCount;
  final int runtime;
  final int inStock;
  final String subtitleLanguage;
  final double price;

  const BluRayMU({
    required this.movieId,
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.releaseDate,
    required this.videoFormat,
    required this.audioFormat,
    required this.discCount,
    required this.runtime,
    required this.inStock,
    required this.subtitleLanguage,
    required this.price,
  });

  factory BluRayMU.fromJson(Map<String, dynamic> json) =>
      _$BluRayMUFromJson(json);

  Map<String, dynamic> toJson() => _$BluRayMUToJson(this);
}
