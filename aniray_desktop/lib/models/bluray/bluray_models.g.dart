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
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  isDeleted: json['isDeleted'] as bool,
);

Map<String, dynamic> _$BluRayMEToJson(BluRayME instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
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
