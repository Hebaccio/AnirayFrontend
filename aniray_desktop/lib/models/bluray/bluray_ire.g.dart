// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bluray_ire.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BluRayIRE _$BluRayIREFromJson(Map<String, dynamic> json) => BluRayIRE(
  image: json['image'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  releaseDate: const DateOnlyConverter().fromJson(
    json['releaseDate'] as String,
  ),
  videoFormatId: (json['videoFormatId'] as num).toInt(),
  audioFormatId: (json['audioFormatId'] as num).toInt(),
  movieId: (json['movieId'] as num).toInt(),
  discCount: (json['discCount'] as num).toInt(),
  runtime: (json['runtime'] as num).toInt(),
  inStock: (json['inStock'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
);

Map<String, dynamic> _$BluRayIREToJson(BluRayIRE instance) => <String, dynamic>{
  'image': instance.image,
  'title': instance.title,
  'description': instance.description,
  'releaseDate': const DateOnlyConverter().toJson(instance.releaseDate),
  'videoFormatId': instance.videoFormatId,
  'audioFormatId': instance.audioFormatId,
  'movieId': instance.movieId,
  'discCount': instance.discCount,
  'runtime': instance.runtime,
  'inStock': instance.inStock,
  'price': instance.price,
};
