import 'package:json_annotation/json_annotation.dart';

part 'base_class_short_me.g.dart';

@JsonSerializable()
class BaseClassShortME {
  final int id;
  final String name;

  const BaseClassShortME({required this.id, required this.name});

  factory BaseClassShortME.fromJson(Map<String, dynamic> json) =>
      _$BaseClassShortMEFromJson(json);

  Map<String, dynamic> toJson() => _$BaseClassShortMEToJson(this);
}
