import 'package:aniray_desktop/models/movie/movie_models.dart';
import 'package:json_annotation/json_annotation.dart';

import '../basic_entities/basic_entities.dart';

part 'request_models.g.dart';

@JsonSerializable()
class RequestURU {
  const RequestURU();
}

@JsonSerializable()
class RequestURE {
  final String? response;

  const RequestURE({this.response});

  factory RequestURE.fromJson(Map<String, dynamic> json) =>
      _$RequestUREFromJson(json);

  Map<String, dynamic> toJson() => _$RequestUREToJson(this);
}

@JsonSerializable()
class RequestSOU extends BaseSO {
  const RequestSOU({super.page, super.pageSize});

  factory RequestSOU.fromJson(Map<String, dynamic> json) =>
      _$RequestSOUFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RequestSOUToJson(this);
}

@JsonSerializable()
class RequestMU {
  final int id;
  final String title;
  final String text;
  final String? response;
  final DateTime dateTime;
  final int userId;
  final bool readByUser;
  final String userFullName;
  final String userMail;

  const RequestMU({
    required this.id,
    required this.title,
    required this.text,
    this.response,
    required this.dateTime,
    required this.userId,
    required this.readByUser,
    required this.userFullName,
    required this.userMail,
  });

  factory RequestMU.fromJson(Map<String, dynamic> json) =>
      _$RequestMUFromJson(json);

  Map<String, dynamic> toJson() => _$RequestMUToJson(this);
}

@JsonSerializable()
class RequestSOE extends BaseSO {
  final String? titleFTS;
  final DateTime? dateTimeGTE;
  final DateTime? dateTimeLTE;
  final String? userFullNameFTS;
  final String? userMailFTS;
  final RequestSortField? orderBy;
  final SortType? sortType;

  const RequestSOE({
    super.page,
    super.pageSize,
    this.titleFTS,
    this.dateTimeGTE,
    this.dateTimeLTE,
    this.userFullNameFTS,
    this.userMailFTS,
    this.orderBy,
    this.sortType,
  });

  factory RequestSOE.fromJson(Map<String, dynamic> json) =>
      _$RequestSOEFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RequestSOEToJson(this);
}

@JsonEnum()
enum RequestSortField { dateTime }

@JsonSerializable()
class RequestME {
  final int id;
  final String title;
  final String text;
  final String? response;
  final DateTime dateTime;
  final int userId;
  final bool readByStaff;
  final String userFullName;
  final String userMail;

  const RequestME({
    required this.id,
    required this.title,
    required this.text,
    this.response,
    required this.dateTime,
    required this.userId,
    required this.readByStaff,
    required this.userFullName,
    required this.userMail,
  });

  factory RequestME.fromJson(Map<String, dynamic> json) =>
      _$RequestMEFromJson(json);

  Map<String, dynamic> toJson() => _$RequestMEToJson(this);
}

@JsonSerializable()
class RequestIRU {
  final String title;
  final String text;

  const RequestIRU({required this.title, required this.text});

  factory RequestIRU.fromJson(Map<String, dynamic> json) =>
      _$RequestIRUFromJson(json);

  Map<String, dynamic> toJson() => _$RequestIRUToJson(this);
}

@JsonSerializable()
class RequestIRE {
  const RequestIRE();
}
