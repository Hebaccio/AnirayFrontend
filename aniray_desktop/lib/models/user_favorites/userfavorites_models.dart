import 'package:aniray_desktop/models/movie/movie_models.dart';
import 'package:json_annotation/json_annotation.dart';
import '../basic_entities/basic_entities.dart';

part 'userfavorites_models.g.dart';

@JsonSerializable()
class UserFavoritesURU {
  final List<int>? movieId;

  const UserFavoritesURU({this.movieId});

  factory UserFavoritesURU.fromJson(Map<String, dynamic> json) =>
      _$UserFavoritesURUFromJson(json);

  Map<String, dynamic> toJson() => _$UserFavoritesURUToJson(this);
}

@JsonSerializable()
class UserFavoritesURE {
  const UserFavoritesURE();

  factory UserFavoritesURE.fromJson(Map<String, dynamic> json) =>
      _$UserFavoritesUREFromJson(json);

  Map<String, dynamic> toJson() => _$UserFavoritesUREToJson(this);
}

@JsonSerializable()
class UserFavoritesSOU extends BaseSO {
  const UserFavoritesSOU({super.page, super.pageSize});

  factory UserFavoritesSOU.fromJson(Map<String, dynamic> json) =>
      _$UserFavoritesSOUFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserFavoritesSOUToJson(this);
}

@JsonSerializable()
class UserFavoritesSOE extends BaseSO {
  final int userId;

  const UserFavoritesSOE({super.page, super.pageSize, required this.userId});

  factory UserFavoritesSOE.fromJson(Map<String, dynamic> json) =>
      _$UserFavoritesSOEFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserFavoritesSOEToJson(this);
}

@JsonSerializable()
class UserFavoritesMU {
  final int userId;
  final MovieMU movie;

  const UserFavoritesMU({required this.userId, required this.movie});

  factory UserFavoritesMU.fromJson(Map<String, dynamic> json) =>
      _$UserFavoritesMUFromJson(json);

  Map<String, dynamic> toJson() => _$UserFavoritesMUToJson(this);
}

@JsonSerializable()
class UserFavoritesME {
  final int userId;
  final MovieME movie;

  const UserFavoritesME({required this.userId, required this.movie});

  factory UserFavoritesME.fromJson(Map<String, dynamic> json) =>
      _$UserFavoritesMEFromJson(json);

  Map<String, dynamic> toJson() => _$UserFavoritesMEToJson(this);
}

@JsonSerializable()
class UserFavoritesIRU {
  final int movieId;

  const UserFavoritesIRU({required this.movieId});

  factory UserFavoritesIRU.fromJson(Map<String, dynamic> json) =>
      _$UserFavoritesIRUFromJson(json);

  Map<String, dynamic> toJson() => _$UserFavoritesIRUToJson(this);
}

@JsonSerializable()
class UserFavoritesIRE {
  const UserFavoritesIRE();

  factory UserFavoritesIRE.fromJson(Map<String, dynamic> json) =>
      _$UserFavoritesIREFromJson(json);

  Map<String, dynamic> toJson() => _$UserFavoritesIREToJson(this);
}
