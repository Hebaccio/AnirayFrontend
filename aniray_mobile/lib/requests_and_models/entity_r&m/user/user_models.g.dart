// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserURU _$UserURUFromJson(Map<String, dynamic> json) => UserURU(
  pfp: json['pfp'] as String?,
  username: json['username'] as String?,
  name: json['name'] as String?,
  lastName: json['lastName'] as String?,
  email: json['email'] as String?,
  birthday: _$JsonConverterFromJson<String, DateTime>(
    json['birthday'],
    const DateOnlyConverter().fromJson,
  ),
  password: json['password'] as String?,
  password2: json['password2'] as String?,
  twoFA: json['twoFA'] as bool?,
  genderId: (json['genderId'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserURUToJson(UserURU instance) => <String, dynamic>{
  'pfp': instance.pfp,
  'username': instance.username,
  'name': instance.name,
  'lastName': instance.lastName,
  'email': instance.email,
  'birthday': _$JsonConverterToJson<String, DateTime>(
    instance.birthday,
    const DateOnlyConverter().toJson,
  ),
  'password': instance.password,
  'password2': instance.password2,
  'twoFA': instance.twoFA,
  'genderId': instance.genderId,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

UserURE _$UserUREFromJson(Map<String, dynamic> json) => UserURE(
  pfp: json['pfp'] as String?,
  username: json['username'] as String?,
  name: json['name'] as String?,
  lastName: json['lastName'] as String?,
  email: json['email'] as String?,
  birthday: _$JsonConverterFromJson<String, DateTime>(
    json['birthday'],
    const DateOnlyConverter().fromJson,
  ),
  genderId: (json['genderId'] as num?)?.toInt(),
  userStatusId: (json['userStatusId'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserUREToJson(UserURE instance) => <String, dynamic>{
  'pfp': instance.pfp,
  'username': instance.username,
  'name': instance.name,
  'lastName': instance.lastName,
  'email': instance.email,
  'birthday': _$JsonConverterToJson<String, DateTime>(
    instance.birthday,
    const DateOnlyConverter().toJson,
  ),
  'genderId': instance.genderId,
  'userStatusId': instance.userStatusId,
};

UserSOU _$UserSOUFromJson(Map<String, dynamic> json) => UserSOU(
  page: (json['page'] as num?)?.toInt() ?? 0,
  pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
);

Map<String, dynamic> _$UserSOUToJson(UserSOU instance) => <String, dynamic>{
  'page': instance.page,
  'pageSize': instance.pageSize,
};

UserSOE _$UserSOEFromJson(Map<String, dynamic> json) => UserSOE(
  page: (json['page'] as num?)?.toInt() ?? 0,
  pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
  usernameFTS: json['usernameFTS'] as String?,
  fullNameFTS: json['fullNameFTS'] as String?,
  emailFTS: json['emailFTS'] as String?,
  birthdayGTE: _$JsonConverterFromJson<String, DateTime>(
    json['birthdayGTE'],
    const DateOnlyConverter().fromJson,
  ),
  birthdayLTE: _$JsonConverterFromJson<String, DateTime>(
    json['birthdayLTE'],
    const DateOnlyConverter().fromJson,
  ),
  createdAtGTE: json['createdAtGTE'] == null
      ? null
      : DateTime.parse(json['createdAtGTE'] as String),
  createdAtLTE: json['createdAtLTE'] == null
      ? null
      : DateTime.parse(json['createdAtLTE'] as String),
  userRoleId: (json['userRoleId'] as num?)?.toInt(),
  userStatusId: (json['userStatusId'] as num?)?.toInt(),
  genderId: (json['genderId'] as num?)?.toInt(),
  orderBy: $enumDecodeNullable(_$UserSortFieldEnumMap, json['orderBy']),
  sortType: $enumDecodeNullable(_$SortTypeEnumMap, json['sortType']),
);

Map<String, dynamic> _$UserSOEToJson(UserSOE instance) => <String, dynamic>{
  'page': instance.page,
  'pageSize': instance.pageSize,
  'usernameFTS': instance.usernameFTS,
  'fullNameFTS': instance.fullNameFTS,
  'emailFTS': instance.emailFTS,
  'birthdayGTE': _$JsonConverterToJson<String, DateTime>(
    instance.birthdayGTE,
    const DateOnlyConverter().toJson,
  ),
  'birthdayLTE': _$JsonConverterToJson<String, DateTime>(
    instance.birthdayLTE,
    const DateOnlyConverter().toJson,
  ),
  'createdAtGTE': instance.createdAtGTE?.toIso8601String(),
  'createdAtLTE': instance.createdAtLTE?.toIso8601String(),
  'userRoleId': instance.userRoleId,
  'userStatusId': instance.userStatusId,
  'genderId': instance.genderId,
  'orderBy': _$UserSortFieldEnumMap[instance.orderBy],
  'sortType': _$SortTypeEnumMap[instance.sortType],
};

const _$UserSortFieldEnumMap = {
  UserSortField.username: 'username',
  UserSortField.name: 'name',
  UserSortField.lastName: 'lastName',
  UserSortField.email: 'email',
  UserSortField.birthday: 'birthday',
  UserSortField.createdAt: 'createdAt',
  UserSortField.userRoleId: 'userRoleId',
  UserSortField.userStatusId: 'userStatusId',
  UserSortField.genderId: 'genderId',
};

const _$SortTypeEnumMap = {
  SortType.ascending: 'ascending',
  SortType.descending: 'descending',
};

UserMU _$UserMUFromJson(Map<String, dynamic> json) => UserMU(
  id: (json['id'] as num).toInt(),
  pfp: json['pfp'] as String,
  username: json['username'] as String,
  name: json['name'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  birthday: const DateOnlyConverter().fromJson(json['birthday'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  twoFA: json['twoFA'] as bool,
  userRole: BaseClassShortMU.fromJson(json['userRole'] as Map<String, dynamic>),
  userStatus: BaseClassShortMU.fromJson(
    json['userStatus'] as Map<String, dynamic>,
  ),
  gender: BaseClassShortMU.fromJson(json['gender'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserMUToJson(UserMU instance) => <String, dynamic>{
  'id': instance.id,
  'pfp': instance.pfp,
  'username': instance.username,
  'name': instance.name,
  'lastName': instance.lastName,
  'email': instance.email,
  'birthday': const DateOnlyConverter().toJson(instance.birthday),
  'createdAt': instance.createdAt.toIso8601String(),
  'twoFA': instance.twoFA,
  'userRole': instance.userRole,
  'userStatus': instance.userStatus,
  'gender': instance.gender,
};

UserME _$UserMEFromJson(Map<String, dynamic> json) => UserME(
  id: (json['id'] as num).toInt(),
  pfp: json['pfp'] as String,
  username: json['username'] as String,
  name: json['name'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  birthday: const DateOnlyConverter().fromJson(json['birthday'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  twoFA: json['twoFA'] as bool,
  userRole: BaseClassShortMU.fromJson(json['userRole'] as Map<String, dynamic>),
  userStatus: BaseClassShortMU.fromJson(
    json['userStatus'] as Map<String, dynamic>,
  ),
  gender: BaseClassShortMU.fromJson(json['gender'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserMEToJson(UserME instance) => <String, dynamic>{
  'id': instance.id,
  'pfp': instance.pfp,
  'username': instance.username,
  'name': instance.name,
  'lastName': instance.lastName,
  'email': instance.email,
  'birthday': const DateOnlyConverter().toJson(instance.birthday),
  'createdAt': instance.createdAt.toIso8601String(),
  'twoFA': instance.twoFA,
  'userRole': instance.userRole,
  'userStatus': instance.userStatus,
  'gender': instance.gender,
};

UserIRU _$UserIRUFromJson(Map<String, dynamic> json) => UserIRU(
  pfp: json['pfp'] as String,
  username: json['username'] as String,
  name: json['name'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  birthday: const DateOnlyConverter().fromJson(json['birthday'] as String),
  password: json['password'] as String,
  password2: json['password2'] as String,
  genderId: (json['genderId'] as num).toInt(),
);

Map<String, dynamic> _$UserIRUToJson(UserIRU instance) => <String, dynamic>{
  'pfp': instance.pfp,
  'username': instance.username,
  'name': instance.name,
  'lastName': instance.lastName,
  'email': instance.email,
  'birthday': const DateOnlyConverter().toJson(instance.birthday),
  'password': instance.password,
  'password2': instance.password2,
  'genderId': instance.genderId,
};

UserIRE _$UserIREFromJson(Map<String, dynamic> json) => UserIRE(
  pfp: json['pfp'] as String,
  username: json['username'] as String,
  name: json['name'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  birthday: const DateOnlyConverter().fromJson(json['birthday'] as String),
  password: json['password'] as String,
  password2: json['password2'] as String,
  genderId: (json['genderId'] as num).toInt(),
  userRoleId: (json['userRoleId'] as num).toInt(),
);

Map<String, dynamic> _$UserIREToJson(UserIRE instance) => <String, dynamic>{
  'pfp': instance.pfp,
  'username': instance.username,
  'name': instance.name,
  'lastName': instance.lastName,
  'email': instance.email,
  'birthday': const DateOnlyConverter().toJson(instance.birthday),
  'password': instance.password,
  'password2': instance.password2,
  'genderId': instance.genderId,
  'userRoleId': instance.userRoleId,
};
