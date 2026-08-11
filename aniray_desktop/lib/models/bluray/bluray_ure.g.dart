// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bluray_ure.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BluRayURE _$BluRayUREFromJson(Map<String, dynamic> json) => BluRayURE(
  image: json['image'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  releaseDate: json['releaseDate'] == null
      ? null
      : DateTime.parse(json['releaseDate'] as String),
  videoFormatId: (json['videoFormatId'] as num?)?.toInt(),
  audioFormatId: (json['audioFormatId'] as num?)?.toInt(),
  movieId: (json['movieId'] as num?)?.toInt(),
  discCount: (json['discCount'] as num?)?.toInt(),
  runtime: (json['runtime'] as num?)?.toInt(),
  inStock: (json['inStock'] as num?)?.toInt(),
  price: (json['price'] as num?)?.toDouble(),
  isDeleted: json['isDeleted'] as bool?,
);

Map<String, dynamic> _$BluRayUREToJson(BluRayURE instance) => <String, dynamic>{
  'image': instance.image,
  'title': instance.title,
  'description': instance.description,
  'releaseDate': instance.releaseDate?.toIso8601String(),
  'videoFormatId': instance.videoFormatId,
  'audioFormatId': instance.audioFormatId,
  'movieId': instance.movieId,
  'discCount': instance.discCount,
  'runtime': instance.runtime,
  'inStock': instance.inStock,
  'price': instance.price,
  'isDeleted': instance.isDeleted,
};
