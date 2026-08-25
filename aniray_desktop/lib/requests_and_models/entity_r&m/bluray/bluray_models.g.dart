// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bluray_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BluRayMU _$BluRayMUFromJson(Map<String, dynamic> json) =>
    BluRayMU(id: (json['id'] as num).toInt(), title: json['title'] as String);

Map<String, dynamic> _$BluRayMUToJson(BluRayMU instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
};

BluRayME _$BluRayMEFromJson(Map<String, dynamic> json) => BluRayME(
  movieId: (json['movieId'] as num).toInt(),
  id: (json['id'] as num).toInt(),
  image: json['image'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  releaseDate: const DateOnlyConverter().fromJson(
    json['releaseDate'] as String,
  ),
  videoFormat: BaseClassMU.fromJson(
    json['videoFormat'] as Map<String, dynamic>,
  ),
  audioFormat: BaseClassMU.fromJson(
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
  'releaseDate': const DateOnlyConverter().toJson(instance.releaseDate),
  'videoFormat': instance.videoFormat,
  'audioFormat': instance.audioFormat,
  'discCount': instance.discCount,
  'runtime': instance.runtime,
  'inStock': instance.inStock,
  'subtitleLanguage': instance.subtitleLanguage,
  'price': instance.price,
  'isDeleted': instance.isDeleted,
};

BluRaySOU _$BluRaySOUFromJson(Map<String, dynamic> json) => BluRaySOU(
  page: (json['page'] as num?)?.toInt() ?? 0,
  pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
  movieId: (json['movieId'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$BluRaySOUToJson(BluRaySOU instance) => <String, dynamic>{
  'page': instance.page,
  'pageSize': instance.pageSize,
  'movieId': instance.movieId,
};

BluRaySOE _$BluRaySOEFromJson(Map<String, dynamic> json) => BluRaySOE(
  page: (json['page'] as num?)?.toInt() ?? 0,
  pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
  movieId: (json['movieId'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$BluRaySOEToJson(BluRaySOE instance) => <String, dynamic>{
  'page': instance.page,
  'pageSize': instance.pageSize,
  'movieId': instance.movieId,
};

BluRayIRU _$BluRayIRUFromJson(Map<String, dynamic> json) => BluRayIRU();

Map<String, dynamic> _$BluRayIRUToJson(BluRayIRU instance) =>
    <String, dynamic>{};

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

BluRayURU _$BluRayURUFromJson(Map<String, dynamic> json) => BluRayURU();

Map<String, dynamic> _$BluRayURUToJson(BluRayURU instance) =>
    <String, dynamic>{};

BluRayURE _$BluRayUREFromJson(Map<String, dynamic> json) => BluRayURE(
  image: json['image'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  releaseDate: _$JsonConverterFromJson<String, DateTime>(
    json['releaseDate'],
    const DateOnlyConverter().fromJson,
  ),
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
  'releaseDate': _$JsonConverterToJson<String, DateTime>(
    instance.releaseDate,
    const DateOnlyConverter().toJson,
  ),
  'videoFormatId': instance.videoFormatId,
  'audioFormatId': instance.audioFormatId,
  'movieId': instance.movieId,
  'discCount': instance.discCount,
  'runtime': instance.runtime,
  'inStock': instance.inStock,
  'price': instance.price,
  'isDeleted': instance.isDeleted,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
