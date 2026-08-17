// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovieURU _$MovieURUFromJson(Map<String, dynamic> json) => MovieURU();

Map<String, dynamic> _$MovieURUToJson(MovieURU instance) => <String, dynamic>{};

MovieURE _$MovieUREFromJson(Map<String, dynamic> json) => MovieURE(
  image: json['image'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  releaseDate: _$JsonConverterFromJson<String, DateTime>(
    json['releaseDate'],
    const DateOnlyConverter().fromJson,
  ),
  studio: json['studio'] as String?,
  director: json['director'] as String?,
  isDeleted: json['isDeleted'] as bool?,
  genreIds: (json['genreIds'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$MovieUREToJson(MovieURE instance) => <String, dynamic>{
  'image': instance.image,
  'title': instance.title,
  'description': instance.description,
  'releaseDate': _$JsonConverterToJson<String, DateTime>(
    instance.releaseDate,
    const DateOnlyConverter().toJson,
  ),
  'studio': instance.studio,
  'director': instance.director,
  'isDeleted': instance.isDeleted,
  'genreIds': instance.genreIds,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

MovieMU _$MovieMUFromJson(Map<String, dynamic> json) => MovieMU(
  id: (json['id'] as num).toInt(),
  image: json['image'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  releaseDate: const DateOnlyConverter().fromJson(
    json['releaseDate'] as String,
  ),
  favorites: (json['favorites'] as num).toInt(),
  studio: json['studio'] as String,
  director: json['director'] as String?,
  movieGenres:
      (json['movieGenres'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$MovieMUToJson(MovieMU instance) => <String, dynamic>{
  'id': instance.id,
  'image': instance.image,
  'title': instance.title,
  'description': instance.description,
  'releaseDate': const DateOnlyConverter().toJson(instance.releaseDate),
  'favorites': instance.favorites,
  'studio': instance.studio,
  'director': instance.director,
  'movieGenres': instance.movieGenres,
};

MovieME _$MovieMEFromJson(Map<String, dynamic> json) => MovieME(
  id: (json['id'] as num).toInt(),
  image: json['image'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  releaseDate: const DateOnlyConverter().fromJson(
    json['releaseDate'] as String,
  ),
  favorites: (json['favorites'] as num).toInt(),
  studio: json['studio'] as String,
  director: json['director'] as String?,
  movieGenres:
      (json['movieGenres'] as List<dynamic>?)
          ?.map((e) => MovieGenreMU.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isDeleted: json['isDeleted'] as bool,
);

Map<String, dynamic> _$MovieMEToJson(MovieME instance) => <String, dynamic>{
  'id': instance.id,
  'image': instance.image,
  'title': instance.title,
  'description': instance.description,
  'releaseDate': const DateOnlyConverter().toJson(instance.releaseDate),
  'favorites': instance.favorites,
  'studio': instance.studio,
  'director': instance.director,
  'movieGenres': instance.movieGenres,
  'isDeleted': instance.isDeleted,
};

MovieSOU _$MovieSOUFromJson(Map<String, dynamic> json) => MovieSOU(
  page: (json['page'] as num?)?.toInt() ?? 0,
  pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
  titleFTS: json['titleFTS'] as String?,
  releaseDateGTE: _$JsonConverterFromJson<String, DateTime>(
    json['releaseDateGTE'],
    const DateOnlyConverter().fromJson,
  ),
  releaseDateLTE: _$JsonConverterFromJson<String, DateTime>(
    json['releaseDateLTE'],
    const DateOnlyConverter().fromJson,
  ),
  favoritesGTE: (json['favoritesGTE'] as num?)?.toInt(),
  favoritesLTE: (json['favoritesLTE'] as num?)?.toInt(),
  studioFTS: json['studioFTS'] as String?,
  directorFTS: json['directorFTS'] as String?,
  isGenresIncluded: json['isGenresIncluded'] as bool?,
  genreIds: (json['genreIds'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  orderBy: $enumDecodeNullable(_$MovieSortFieldEnumMap, json['orderBy']),
  sortType: $enumDecodeNullable(_$SortTypeEnumMap, json['sortType']),
);

Map<String, dynamic> _$MovieSOUToJson(MovieSOU instance) => <String, dynamic>{
  'page': instance.page,
  'pageSize': instance.pageSize,
  'titleFTS': instance.titleFTS,
  'releaseDateGTE': _$JsonConverterToJson<String, DateTime>(
    instance.releaseDateGTE,
    const DateOnlyConverter().toJson,
  ),
  'releaseDateLTE': _$JsonConverterToJson<String, DateTime>(
    instance.releaseDateLTE,
    const DateOnlyConverter().toJson,
  ),
  'favoritesGTE': instance.favoritesGTE,
  'favoritesLTE': instance.favoritesLTE,
  'studioFTS': instance.studioFTS,
  'directorFTS': instance.directorFTS,
  'isGenresIncluded': instance.isGenresIncluded,
  'genreIds': instance.genreIds,
  'orderBy': _$MovieSortFieldEnumMap[instance.orderBy],
  'sortType': _$SortTypeEnumMap[instance.sortType],
};

const _$MovieSortFieldEnumMap = {
  MovieSortField.title: 'title',
  MovieSortField.releaseDate: 'releaseDate',
  MovieSortField.favorites: 'favorites',
  MovieSortField.studio: 'studio',
  MovieSortField.director: 'director',
};

const _$SortTypeEnumMap = {
  SortType.ascending: 'ascending',
  SortType.descending: 'descending',
};

MovieSOE _$MovieSOEFromJson(Map<String, dynamic> json) => MovieSOE(
  page: (json['page'] as num?)?.toInt() ?? 0,
  pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
  titleFTS: json['titleFTS'] as String?,
  releaseDateGTE: _$JsonConverterFromJson<String, DateTime>(
    json['releaseDateGTE'],
    const DateOnlyConverter().fromJson,
  ),
  releaseDateLTE: _$JsonConverterFromJson<String, DateTime>(
    json['releaseDateLTE'],
    const DateOnlyConverter().fromJson,
  ),
  favoritesGTE: (json['favoritesGTE'] as num?)?.toInt(),
  favoritesLTE: (json['favoritesLTE'] as num?)?.toInt(),
  studioFTS: json['studioFTS'] as String?,
  directorFTS: json['directorFTS'] as String?,
  isGenresIncluded: json['isGenresIncluded'] as bool?,
  genreIds: (json['genreIds'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  orderBy: $enumDecodeNullable(_$MovieSortFieldEnumMap, json['orderBy']),
  sortType: $enumDecodeNullable(_$SortTypeEnumMap, json['sortType']),
  isDeleted: json['isDeleted'] as bool?,
);

Map<String, dynamic> _$MovieSOEToJson(MovieSOE instance) => <String, dynamic>{
  'page': instance.page,
  'pageSize': instance.pageSize,
  'titleFTS': instance.titleFTS,
  'releaseDateGTE': _$JsonConverterToJson<String, DateTime>(
    instance.releaseDateGTE,
    const DateOnlyConverter().toJson,
  ),
  'releaseDateLTE': _$JsonConverterToJson<String, DateTime>(
    instance.releaseDateLTE,
    const DateOnlyConverter().toJson,
  ),
  'favoritesGTE': instance.favoritesGTE,
  'favoritesLTE': instance.favoritesLTE,
  'studioFTS': instance.studioFTS,
  'directorFTS': instance.directorFTS,
  'isGenresIncluded': instance.isGenresIncluded,
  'genreIds': instance.genreIds,
  'orderBy': _$MovieSortFieldEnumMap[instance.orderBy],
  'sortType': _$SortTypeEnumMap[instance.sortType],
  'isDeleted': instance.isDeleted,
};

MovieIRU _$MovieIRUFromJson(Map<String, dynamic> json) => MovieIRU();

Map<String, dynamic> _$MovieIRUToJson(MovieIRU instance) => <String, dynamic>{};

MovieIRE _$MovieIREFromJson(Map<String, dynamic> json) => MovieIRE(
  image: json['image'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  releaseDate: const DateOnlyConverter().fromJson(
    json['releaseDate'] as String,
  ),
  studio: json['studio'] as String,
  director: json['director'] as String?,
  genreIds: (json['genreIds'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$MovieIREToJson(MovieIRE instance) => <String, dynamic>{
  'image': instance.image,
  'title': instance.title,
  'description': instance.description,
  'releaseDate': const DateOnlyConverter().toJson(instance.releaseDate),
  'studio': instance.studio,
  'director': instance.director,
  'genreIds': instance.genreIds,
};
