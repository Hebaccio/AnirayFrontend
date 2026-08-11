// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bluray_sou.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
