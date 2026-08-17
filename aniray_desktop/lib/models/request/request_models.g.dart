// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestURU _$RequestURUFromJson(Map<String, dynamic> json) => RequestURU();

Map<String, dynamic> _$RequestURUToJson(RequestURU instance) =>
    <String, dynamic>{};

RequestURE _$RequestUREFromJson(Map<String, dynamic> json) =>
    RequestURE(response: json['response'] as String?);

Map<String, dynamic> _$RequestUREToJson(RequestURE instance) =>
    <String, dynamic>{'response': instance.response};

RequestSOU _$RequestSOUFromJson(Map<String, dynamic> json) => RequestSOU(
  page: (json['page'] as num?)?.toInt() ?? 0,
  pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
);

Map<String, dynamic> _$RequestSOUToJson(RequestSOU instance) =>
    <String, dynamic>{'page': instance.page, 'pageSize': instance.pageSize};

RequestMU _$RequestMUFromJson(Map<String, dynamic> json) => RequestMU(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  text: json['text'] as String,
  response: json['response'] as String?,
  dateTime: DateTime.parse(json['dateTime'] as String),
  userId: (json['userId'] as num).toInt(),
  readByUser: json['readByUser'] as bool,
  userFullName: json['userFullName'] as String,
  userMail: json['userMail'] as String,
);

Map<String, dynamic> _$RequestMUToJson(RequestMU instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'text': instance.text,
  'response': instance.response,
  'dateTime': instance.dateTime.toIso8601String(),
  'userId': instance.userId,
  'readByUser': instance.readByUser,
  'userFullName': instance.userFullName,
  'userMail': instance.userMail,
};

RequestSOE _$RequestSOEFromJson(Map<String, dynamic> json) => RequestSOE(
  page: (json['page'] as num?)?.toInt() ?? 0,
  pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
  titleFTS: json['titleFTS'] as String?,
  dateTimeGTE: json['dateTimeGTE'] == null
      ? null
      : DateTime.parse(json['dateTimeGTE'] as String),
  dateTimeLTE: json['dateTimeLTE'] == null
      ? null
      : DateTime.parse(json['dateTimeLTE'] as String),
  userFullNameFTS: json['userFullNameFTS'] as String?,
  userMailFTS: json['userMailFTS'] as String?,
  orderBy: $enumDecodeNullable(_$RequestSortFieldEnumMap, json['orderBy']),
  sortType: $enumDecodeNullable(_$SortTypeEnumMap, json['sortType']),
);

Map<String, dynamic> _$RequestSOEToJson(RequestSOE instance) =>
    <String, dynamic>{
      'page': instance.page,
      'pageSize': instance.pageSize,
      'titleFTS': instance.titleFTS,
      'dateTimeGTE': instance.dateTimeGTE?.toIso8601String(),
      'dateTimeLTE': instance.dateTimeLTE?.toIso8601String(),
      'userFullNameFTS': instance.userFullNameFTS,
      'userMailFTS': instance.userMailFTS,
      'orderBy': _$RequestSortFieldEnumMap[instance.orderBy],
      'sortType': _$SortTypeEnumMap[instance.sortType],
    };

const _$RequestSortFieldEnumMap = {RequestSortField.dateTime: 'dateTime'};

const _$SortTypeEnumMap = {
  SortType.ascending: 'ascending',
  SortType.descending: 'descending',
};

RequestME _$RequestMEFromJson(Map<String, dynamic> json) => RequestME(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  text: json['text'] as String,
  response: json['response'] as String?,
  dateTime: DateTime.parse(json['dateTime'] as String),
  userId: (json['userId'] as num).toInt(),
  readByStaff: json['readByStaff'] as bool,
  userFullName: json['userFullName'] as String,
  userMail: json['userMail'] as String,
);

Map<String, dynamic> _$RequestMEToJson(RequestME instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'text': instance.text,
  'response': instance.response,
  'dateTime': instance.dateTime.toIso8601String(),
  'userId': instance.userId,
  'readByStaff': instance.readByStaff,
  'userFullName': instance.userFullName,
  'userMail': instance.userMail,
};

RequestIRU _$RequestIRUFromJson(Map<String, dynamic> json) =>
    RequestIRU(title: json['title'] as String, text: json['text'] as String);

Map<String, dynamic> _$RequestIRUToJson(RequestIRU instance) =>
    <String, dynamic>{'title': instance.title, 'text': instance.text};

RequestIRE _$RequestIREFromJson(Map<String, dynamic> json) => RequestIRE();

Map<String, dynamic> _$RequestIREToJson(RequestIRE instance) =>
    <String, dynamic>{};
