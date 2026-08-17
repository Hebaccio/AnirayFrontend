// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userfavorites_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserFavoritesURU _$UserFavoritesURUFromJson(Map<String, dynamic> json) =>
    UserFavoritesURU(
      movieId: (json['movieId'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$UserFavoritesURUToJson(UserFavoritesURU instance) =>
    <String, dynamic>{'movieId': instance.movieId};

UserFavoritesURE _$UserFavoritesUREFromJson(Map<String, dynamic> json) =>
    UserFavoritesURE();

Map<String, dynamic> _$UserFavoritesUREToJson(UserFavoritesURE instance) =>
    <String, dynamic>{};

UserFavoritesSOU _$UserFavoritesSOUFromJson(Map<String, dynamic> json) =>
    UserFavoritesSOU(
      page: (json['page'] as num?)?.toInt() ?? 0,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
    );

Map<String, dynamic> _$UserFavoritesSOUToJson(UserFavoritesSOU instance) =>
    <String, dynamic>{'page': instance.page, 'pageSize': instance.pageSize};

UserFavoritesSOE _$UserFavoritesSOEFromJson(Map<String, dynamic> json) =>
    UserFavoritesSOE(
      page: (json['page'] as num?)?.toInt() ?? 0,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
      userId: (json['userId'] as num).toInt(),
    );

Map<String, dynamic> _$UserFavoritesSOEToJson(UserFavoritesSOE instance) =>
    <String, dynamic>{
      'page': instance.page,
      'pageSize': instance.pageSize,
      'userId': instance.userId,
    };

UserFavoritesMU _$UserFavoritesMUFromJson(Map<String, dynamic> json) =>
    UserFavoritesMU(
      userId: (json['userId'] as num).toInt(),
      movie: MovieMU.fromJson(json['movie'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserFavoritesMUToJson(UserFavoritesMU instance) =>
    <String, dynamic>{'userId': instance.userId, 'movie': instance.movie};

UserFavoritesME _$UserFavoritesMEFromJson(Map<String, dynamic> json) =>
    UserFavoritesME(
      userId: (json['userId'] as num).toInt(),
      movie: MovieME.fromJson(json['movie'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserFavoritesMEToJson(UserFavoritesME instance) =>
    <String, dynamic>{'userId': instance.userId, 'movie': instance.movie};

UserFavoritesIRU _$UserFavoritesIRUFromJson(Map<String, dynamic> json) =>
    UserFavoritesIRU(movieId: (json['movieId'] as num).toInt());

Map<String, dynamic> _$UserFavoritesIRUToJson(UserFavoritesIRU instance) =>
    <String, dynamic>{'movieId': instance.movieId};

UserFavoritesIRE _$UserFavoritesIREFromJson(Map<String, dynamic> json) =>
    UserFavoritesIRE();

Map<String, dynamic> _$UserFavoritesIREToJson(UserFavoritesIRE instance) =>
    <String, dynamic>{};
