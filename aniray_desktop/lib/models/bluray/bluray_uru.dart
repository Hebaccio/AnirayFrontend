import 'package:json_annotation/json_annotation.dart';

part 'bluray_uru.g.dart';

@JsonSerializable()
class BluRayURU {
  const BluRayURU();

  factory BluRayURU.fromJson(Map<String, dynamic> json) =>
      _$BluRayURUFromJson(json);

  Map<String, dynamic> toJson() => _$BluRayURUToJson(this);
}
