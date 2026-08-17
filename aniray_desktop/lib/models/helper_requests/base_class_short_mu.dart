import 'package:json_annotation/json_annotation.dart';
part 'base_class_short_mu.g.dart';

@JsonSerializable()
class BaseClassShortMU {
  final String name;

  const BaseClassShortMU({required this.name});

  factory BaseClassShortMU.fromJson(Map<String, dynamic> json) =>
      _$BaseClassShortMUFromJson(json);

  Map<String, dynamic> toJson() => _$BaseClassShortMUToJson(this);
}
