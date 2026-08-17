// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_entities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseSO _$BaseSOFromJson(Map<String, dynamic> json) => BaseSO(
  page: (json['page'] as num?)?.toInt() ?? 0,
  pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
);

Map<String, dynamic> _$BaseSOToJson(BaseSO instance) => <String, dynamic>{
  'page': instance.page,
  'pageSize': instance.pageSize,
};

BaseClassIRE _$BaseClassIREFromJson(Map<String, dynamic> json) =>
    BaseClassIRE(name: json['name'] as String);

Map<String, dynamic> _$BaseClassIREToJson(BaseClassIRE instance) =>
    <String, dynamic>{'name': instance.name};

BaseClassURE _$BaseClassUREFromJson(Map<String, dynamic> json) => BaseClassURE(
  name: json['name'] as String?,
  isDeleted: json['isDeleted'] as bool?,
);

Map<String, dynamic> _$BaseClassUREToJson(BaseClassURE instance) =>
    <String, dynamic>{'name': instance.name, 'isDeleted': instance.isDeleted};

BaseClassSOU _$BaseClassSOUFromJson(Map<String, dynamic> json) => BaseClassSOU(
  page: (json['page'] as num?)?.toInt() ?? 0,
  pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
);

Map<String, dynamic> _$BaseClassSOUToJson(BaseClassSOU instance) =>
    <String, dynamic>{'page': instance.page, 'pageSize': instance.pageSize};

BaseClassSOE _$BaseClassSOEFromJson(Map<String, dynamic> json) => BaseClassSOE(
  page: (json['page'] as num?)?.toInt() ?? 0,
  pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
  nameFTS: json['nameFTS'] as String?,
  isDeleted: json['isDeleted'] as bool?,
);

Map<String, dynamic> _$BaseClassSOEToJson(BaseClassSOE instance) =>
    <String, dynamic>{
      'page': instance.page,
      'pageSize': instance.pageSize,
      'nameFTS': instance.nameFTS,
      'isDeleted': instance.isDeleted,
    };

BaseClassMU _$BaseClassMUFromJson(Map<String, dynamic> json) =>
    BaseClassMU(id: (json['id'] as num).toInt(), name: json['name'] as String);

Map<String, dynamic> _$BaseClassMUToJson(BaseClassMU instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

BaseClassME _$BaseClassMEFromJson(Map<String, dynamic> json) => BaseClassME(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  isDeleted: json['isDeleted'] as bool,
);

Map<String, dynamic> _$BaseClassMEToJson(BaseClassME instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isDeleted': instance.isDeleted,
    };

BaseClass _$BaseClassFromJson(Map<String, dynamic> json) => BaseClass(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  isDeleted: json['isDeleted'] as bool,
);

Map<String, dynamic> _$BaseClassToJson(BaseClass instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'isDeleted': instance.isDeleted,
};
