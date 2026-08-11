import 'package:aniray_desktop/helpers/date_only_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bluray_ire.g.dart';

@JsonSerializable()
class BluRayIRE {
  final String image;
  final String title;
  final String description;
  @DateOnlyConverter()
  final DateTime releaseDate;
  final int videoFormatId;
  final int audioFormatId;
  final int movieId;
  final int discCount;
  final int runtime;
  final int inStock;
  final double price;

  const BluRayIRE({
    required this.image,
    required this.title,
    required this.description,
    required this.releaseDate,
    required this.videoFormatId,
    required this.audioFormatId,
    required this.movieId,
    required this.discCount,
    required this.runtime,
    required this.inStock,
    required this.price,
  });

  factory BluRayIRE.fromJson(Map<String, dynamic> json) =>
      _$BluRayIREFromJson(json);

  Map<String, dynamic> toJson() => _$BluRayIREToJson(this);
}
