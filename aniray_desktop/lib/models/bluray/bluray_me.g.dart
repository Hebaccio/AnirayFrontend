// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bluray_me.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BluRayME _$BluRayMEFromJson(Map<String, dynamic> json) => BluRayME(
  movieId: (json['movieId'] as num).toInt(),
  id: (json['id'] as num).toInt(),
  image: json['image'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  releaseDate: DateTime.parse(json['releaseDate'] as String),
  videoFormat: BaseClassShortME.fromJson(
    json['videoFormat'] as Map<String, dynamic>,
  ),
  audioFormat: BaseClassShortME.fromJson(
    json['audioFormat'] as Map<String, dynamic>,
  ),
  discCount: (json['discCount'] as num).toInt(),
  runtime: (json['runtime'] as num).toInt(),
  inStock: (json['inStock'] as num).toInt(),
  subtitleLanguage: json['subtitleLanguage'] as String,
  price: (json['price'] as num).toDouble(),
  isDeleted: json['isDeleted'] as bool,
);

Map<String, dynamic> _$BluRayMEToJson(BluRayME instance) => <String, dynamic>{
  'movieId': instance.movieId,
  'id': instance.id,
  'image': instance.image,
  'title': instance.title,
  'description': instance.description,
  'releaseDate': instance.releaseDate.toIso8601String(),
  'videoFormat': instance.videoFormat,
  'audioFormat': instance.audioFormat,
  'discCount': instance.discCount,
  'runtime': instance.runtime,
  'inStock': instance.inStock,
  'subtitleLanguage': instance.subtitleLanguage,
  'price': instance.price,
  'isDeleted': instance.isDeleted,
};
