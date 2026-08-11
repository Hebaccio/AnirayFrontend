// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bluray_soe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
