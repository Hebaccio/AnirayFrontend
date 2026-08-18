import 'package:aniray_desktop/models/bluray/bluray_models.dart';
import 'package:json_annotation/json_annotation.dart';

part 'usercart_models.g.dart';

@JsonSerializable()
class UserCartURU {
  final String cartNotes;
  final List<BluRayCartUR> bluRay;

  const UserCartURU({this.cartNotes = '', this.bluRay = const []});

  factory UserCartURU.fromJson(Map<String, dynamic> json) =>
      _$UserCartURUFromJson(json);

  Map<String, dynamic> toJson() => _$UserCartURUToJson(this);
}

@JsonSerializable()
class UserCartURE {
  const UserCartURE();

  factory UserCartURE.fromJson(Map<String, dynamic> json) =>
      _$UserCartUREFromJson(json);

  Map<String, dynamic> toJson() => _$UserCartUREToJson(this);
}

@JsonSerializable()
class UserCartMU {
  final int id;
  final int userId;
  final double fullCartPrice;
  final String cartNotes;
  final List<BluRayCartMU> bluRay;

  const UserCartMU({
    required this.id,
    required this.userId,
    required this.fullCartPrice,
    this.cartNotes = '',
    this.bluRay = const [],
  });

  factory UserCartMU.fromJson(Map<String, dynamic> json) =>
      _$UserCartMUFromJson(json);

  Map<String, dynamic> toJson() => _$UserCartMUToJson(this);
}

@JsonSerializable()
class UserCartME {
  const UserCartME();

  factory UserCartME.fromJson(Map<String, dynamic> json) =>
      _$UserCartMEFromJson(json);

  Map<String, dynamic> toJson() => _$UserCartMEToJson(this);
}

@JsonSerializable()
class UserCartIRU {
  final int userId;

  const UserCartIRU({required this.userId});

  factory UserCartIRU.fromJson(Map<String, dynamic> json) =>
      _$UserCartIRUFromJson(json);

  Map<String, dynamic> toJson() => _$UserCartIRUToJson(this);
}

@JsonSerializable()
class UserCartIRE {
  const UserCartIRE();

  factory UserCartIRE.fromJson(Map<String, dynamic> json) =>
      _$UserCartIREFromJson(json);

  Map<String, dynamic> toJson() => _$UserCartIREToJson(this);
}

@JsonSerializable()
class UserCartIndividualURU {
  final BluRayCartUR bluRay;

  const UserCartIndividualURU({required this.bluRay});

  factory UserCartIndividualURU.fromJson(Map<String, dynamic> json) =>
      _$UserCartIndividualURUFromJson(json);

  Map<String, dynamic> toJson() => _$UserCartIndividualURUToJson(this);
}

@JsonSerializable()
class BluRayCartUR {
  final int bluRayId;
  final int amount;

  const BluRayCartUR({required this.bluRayId, required this.amount});

  factory BluRayCartUR.fromJson(Map<String, dynamic> json) =>
      _$BluRayCartURFromJson(json);

  Map<String, dynamic> toJson() => _$BluRayCartURToJson(this);
}

@JsonSerializable()
class BluRayCartMU {
  final BluRayMU bluRay;
  final int amount;

  const BluRayCartMU({required this.bluRay, required this.amount});

  factory BluRayCartMU.fromJson(Map<String, dynamic> json) =>
      _$BluRayCartMUFromJson(json);

  Map<String, dynamic> toJson() => _$BluRayCartMUToJson(this);
}
