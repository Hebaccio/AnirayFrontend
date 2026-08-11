import 'package:json_annotation/json_annotation.dart';

part 'bluray_soe.g.dart';

@JsonSerializable()
class BluRaySOE {
  final int page;
  final int pageSize;
  final int movieId;

  const BluRaySOE({this.page = 0, this.pageSize = 10, this.movieId = 0});

  factory BluRaySOE.fromJson(Map<String, dynamic> json) =>
      _$BluRaySOEFromJson(json);

  Map<String, dynamic> toJson() => _$BluRaySOEToJson(this);
}
