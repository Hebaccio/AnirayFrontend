import 'package:json_annotation/json_annotation.dart';

part 'bluray_ure.g.dart';

@JsonSerializable()
class BluRayURE {
  final String? image;
  final String? title;
  final String? description;
  final DateTime? releaseDate;
  final int? videoFormatId;
  final int? audioFormatId;
  final int? movieId;
  final int? discCount;
  final int? runtime;
  final int? inStock;
  final double? price;
  final bool? isDeleted;

  const BluRayURE({
    this.image,
    this.title,
    this.description,
    this.releaseDate,
    this.videoFormatId,
    this.audioFormatId,
    this.movieId,
    this.discCount,
    this.runtime,
    this.inStock,
    this.price,
    this.isDeleted,
  });

  factory BluRayURE.fromJson(Map<String, dynamic> json) =>
      _$BluRayUREFromJson(json);

  Map<String, dynamic> toJson() => _$BluRayUREToJson(this);
}
