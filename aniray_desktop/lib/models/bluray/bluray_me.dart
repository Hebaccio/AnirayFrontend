import 'package:json_annotation/json_annotation.dart';

import '../baseclass/base_class_short_me.dart';

part 'bluray_me.g.dart';

@JsonSerializable()
class BluRayME {
  final int movieId;
  final int id;
  final String image;
  final String title;
  final String description;
  final DateTime releaseDate;
  final BaseClassShortME videoFormat;
  final BaseClassShortME audioFormat;
  final int discCount;
  final int runtime;
  final int inStock;
  final String subtitleLanguage;
  final double price;
  final bool isDeleted;

  const BluRayME({
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
    required this.isDeleted,
  });

  factory BluRayME.fromJson(Map<String, dynamic> json) =>
      _$BluRayMEFromJson(json);

  Map<String, dynamic> toJson() => _$BluRayMEToJson(this);
}
