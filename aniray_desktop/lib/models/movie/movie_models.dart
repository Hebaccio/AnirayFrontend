import 'package:aniray_desktop/helpers/date_only_converter.dart';
import 'package:aniray_desktop/models/movie/movie_genre.dart';
import 'package:json_annotation/json_annotation.dart';
import '../basic_entities/basic_entities.dart';

part 'movie_models.g.dart';

@JsonSerializable()
class MovieURU {
  const MovieURU();

  factory MovieURU.fromJson(Map<String, dynamic> json) =>
      _$MovieURUFromJson(json);

  Map<String, dynamic> toJson() => _$MovieURUToJson(this);
}

@JsonSerializable()
class MovieURE {
  final String? image;
  final String? title;
  final String? description;

  @DateOnlyConverter()
  final DateTime? releaseDate;

  final String? studio;
  final String? director;
  final bool? isDeleted;
  final List<int>? genreIds;

  const MovieURE({
    this.image,
    this.title,
    this.description,
    this.releaseDate,
    this.studio,
    this.director,
    this.isDeleted,
    this.genreIds,
  });

  factory MovieURE.fromJson(Map<String, dynamic> json) =>
      _$MovieUREFromJson(json);

  Map<String, dynamic> toJson() => _$MovieUREToJson(this);
}

@JsonSerializable()
class MovieMU {
  final int id;
  final String image;
  final String title;
  final String description;

  @DateOnlyConverter()
  final DateTime releaseDate;

  final int favorites;
  final String studio;
  final String? director;
  final List<String> movieGenres;

  const MovieMU({
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.releaseDate,
    required this.favorites,
    required this.studio,
    this.director,
    this.movieGenres = const [],
  });

  factory MovieMU.fromJson(Map<String, dynamic> json) =>
      _$MovieMUFromJson(json);

  Map<String, dynamic> toJson() => _$MovieMUToJson(this);
}

@JsonSerializable()
class MovieME {
  final int id;
  final String image;
  final String title;
  final String description;

  @DateOnlyConverter()
  final DateTime releaseDate;

  final int favorites;
  final String studio;
  final String? director;
  final List<MovieGenreMU> movieGenres;
  final bool isDeleted;

  const MovieME({
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.releaseDate,
    required this.favorites,
    required this.studio,
    this.director,
    this.movieGenres = const [],
    required this.isDeleted,
  });

  factory MovieME.fromJson(Map<String, dynamic> json) =>
      _$MovieMEFromJson(json);

  Map<String, dynamic> toJson() => _$MovieMEToJson(this);
}

@JsonSerializable()
class MovieSOU extends BaseSO {
  final String? titleFTS;

  @DateOnlyConverter()
  final DateTime? releaseDateGTE;

  @DateOnlyConverter()
  final DateTime? releaseDateLTE;

  final int? favoritesGTE;
  final int? favoritesLTE;
  final String? studioFTS;
  final String? directorFTS;
  final bool? isGenresIncluded;
  final List<int>? genreIds;
  final MovieSortField? orderBy;
  final SortType? sortType;

  const MovieSOU({
    super.page,
    super.pageSize,
    this.titleFTS,
    this.releaseDateGTE,
    this.releaseDateLTE,
    this.favoritesGTE,
    this.favoritesLTE,
    this.studioFTS,
    this.directorFTS,
    this.isGenresIncluded,
    this.genreIds,
    this.orderBy,
    this.sortType,
  });

  factory MovieSOU.fromJson(Map<String, dynamic> json) =>
      _$MovieSOUFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MovieSOUToJson(this);
}

@JsonSerializable()
class MovieSOE extends MovieSOU {
  final bool? isDeleted;

  const MovieSOE({
    super.page,
    super.pageSize,
    super.titleFTS,
    super.releaseDateGTE,
    super.releaseDateLTE,
    super.favoritesGTE,
    super.favoritesLTE,
    super.studioFTS,
    super.directorFTS,
    super.isGenresIncluded,
    super.genreIds,
    super.orderBy,
    super.sortType,
    this.isDeleted,
  });

  factory MovieSOE.fromJson(Map<String, dynamic> json) =>
      _$MovieSOEFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MovieSOEToJson(this);
}

@JsonSerializable()
class MovieIRU {
  const MovieIRU();

  factory MovieIRU.fromJson(Map<String, dynamic> json) =>
      _$MovieIRUFromJson(json);

  Map<String, dynamic> toJson() => _$MovieIRUToJson(this);
}

@JsonSerializable()
class MovieIRE {
  final String image;
  final String title;
  final String description;

  @DateOnlyConverter()
  final DateTime releaseDate;

  final String studio;
  final String? director;
  final List<int>? genreIds;

  const MovieIRE({
    required this.image,
    required this.title,
    required this.description,
    required this.releaseDate,
    required this.studio,
    this.director,
    this.genreIds,
  });

  factory MovieIRE.fromJson(Map<String, dynamic> json) =>
      _$MovieIREFromJson(json);

  Map<String, dynamic> toJson() => _$MovieIREToJson(this);
}

enum MovieSortField { title, releaseDate, favorites, studio, director }

enum SortType { ascending, descending }
