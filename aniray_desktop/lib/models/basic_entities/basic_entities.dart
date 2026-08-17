import 'package:json_annotation/json_annotation.dart';

part 'basic_entities.g.dart';

@JsonSerializable()
class BaseSO {
  final int page;
  final int pageSize;

  const BaseSO({this.page = 0, this.pageSize = 10});

  factory BaseSO.fromJson(Map<String, dynamic> json) => _$BaseSOFromJson(json);

  Map<String, dynamic> toJson() => _$BaseSOToJson(this);
}

class BaseClassIRU {
  const BaseClassIRU();
}

@JsonSerializable()
class BaseClassIRE {
  final String name;

  const BaseClassIRE({required this.name});

  factory BaseClassIRE.fromJson(Map<String, dynamic> json) =>
      _$BaseClassIREFromJson(json);

  Map<String, dynamic> toJson() => _$BaseClassIREToJson(this);
}

class BaseClassURU {
  const BaseClassURU();
}

@JsonSerializable()
class BaseClassURE {
  final String? name;
  final bool? isDeleted;

  const BaseClassURE({this.name, this.isDeleted});

  factory BaseClassURE.fromJson(Map<String, dynamic> json) =>
      _$BaseClassUREFromJson(json);

  Map<String, dynamic> toJson() => _$BaseClassUREToJson(this);
}

@JsonSerializable()
class BaseClassSOU extends BaseSO {
  const BaseClassSOU({super.page, super.pageSize});

  factory BaseClassSOU.fromJson(Map<String, dynamic> json) =>
      _$BaseClassSOUFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BaseClassSOUToJson(this);
}

@JsonSerializable()
class BaseClassSOE extends BaseSO {
  final String? nameFTS;
  final bool? isDeleted;

  const BaseClassSOE({
    super.page,
    super.pageSize,
    this.nameFTS,
    this.isDeleted,
  });

  factory BaseClassSOE.fromJson(Map<String, dynamic> json) =>
      _$BaseClassSOEFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BaseClassSOEToJson(this);
}

@JsonSerializable()
class BaseClassMU {
  final int id;
  final String name;

  const BaseClassMU({required this.id, required this.name});

  factory BaseClassMU.fromJson(Map<String, dynamic> json) =>
      _$BaseClassMUFromJson(json);

  Map<String, dynamic> toJson() => _$BaseClassMUToJson(this);
}

@JsonSerializable()
class BaseClassME {
  final int id;
  final String name;
  final bool isDeleted;

  const BaseClassME({
    required this.id,
    required this.name,
    required this.isDeleted,
  });

  factory BaseClassME.fromJson(Map<String, dynamic> json) =>
      _$BaseClassMEFromJson(json);

  Map<String, dynamic> toJson() => _$BaseClassMEToJson(this);
}

@JsonSerializable()
class BaseClass {
  final int id;
  final String name;
  final bool isDeleted;

  const BaseClass({
    required this.id,
    required this.name,
    required this.isDeleted,
  });

  factory BaseClass.fromJson(Map<String, dynamic> json) =>
      _$BaseClassFromJson(json);

  Map<String, dynamic> toJson() => _$BaseClassToJson(this);
}
