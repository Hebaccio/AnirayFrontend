import 'package:json_annotation/json_annotation.dart';

part 'bluray_sou.g.dart';

@JsonSerializable()
class BluRaySOU {
  final int page;
  final int pageSize;
  final int movieId;

  const BluRaySOU({this.page = 0, this.pageSize = 10, this.movieId = 0});

  factory BluRaySOU.fromJson(Map<String, dynamic> json) =>
      _$BluRaySOUFromJson(json);

  Map<String, dynamic> toJson() => _$BluRaySOUToJson(this);
}
