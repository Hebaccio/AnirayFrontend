import 'package:aniray_desktop/helpers/date_only_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bluray_models.g.dart';

@JsonSerializable()
class BluRayMU {
  final int id;
  final String title;

  const BluRayMU({required this.id, required this.title});

  factory BluRayMU.fromJson(Map<String, dynamic> json) =>
      _$BluRayMUFromJson(json);

  Map<String, dynamic> toJson() => _$BluRayMUToJson(this);
}

@JsonSerializable()
class BluRayME {
  final int id;
  final String title;
  final bool isDeleted;

  const BluRayME({
    required this.id,
    required this.title,
    required this.isDeleted,
  });

  factory BluRayME.fromJson(Map<String, dynamic> json) =>
      _$BluRayMEFromJson(json);

  Map<String, dynamic> toJson() => _$BluRayMEToJson(this);
}

@JsonSerializable()
class BluRaySOU {
  final int page;
  final int pageSize;
  final int movieId;

  const BluRaySOU({this.page = 0, this.pageSize = 10, this.movieId = 0});

  factory BluRaySOU.fromJson(Map<String, dynamic> json) =>
      _$BluRaySOUFromJson(json);

  Map<String, dynamic> toJson() => _$BluRaySOUToJson(this);
}

@JsonSerializable()
class BluRaySOE {
  final int page;
  final int pageSize;
  final int movieId;

  const BluRaySOE({this.page = 0, this.pageSize = 10, this.movieId = 0});

  factory BluRaySOE.fromJson(Map<String, dynamic> json) =>
      _$BluRaySOEFromJson(json);

  Map<String, dynamic> toJson() => _$BluRaySOEToJson(this);
}

@JsonSerializable()
class BluRayIRU {
  const BluRayIRU();

  factory BluRayIRU.fromJson(Map<String, dynamic> json) =>
      _$BluRayIRUFromJson(json);

  Map<String, dynamic> toJson() => _$BluRayIRUToJson(this);
}

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

@JsonSerializable()
class BluRayURU {
  const BluRayURU();

  factory BluRayURU.fromJson(Map<String, dynamic> json) =>
      _$BluRayURUFromJson(json);

  Map<String, dynamic> toJson() => _$BluRayURUToJson(this);
}

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
