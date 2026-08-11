import 'package:json_annotation/json_annotation.dart';

part 'bluray_iru.g.dart';

@JsonSerializable()
class BluRayIRU {
  const BluRayIRU();

  factory BluRayIRU.fromJson(Map<String, dynamic> json) =>
      _$BluRayIRUFromJson(json);

  Map<String, dynamic> toJson() => _$BluRayIRUToJson(this);
}
