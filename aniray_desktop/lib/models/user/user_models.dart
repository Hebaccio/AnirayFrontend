import 'package:aniray_desktop/helpers/date_only_converter.dart';
import 'package:aniray_desktop/models/movie/movie_models.dart';
import 'package:json_annotation/json_annotation.dart';
import '../basic_entities/basic_entities.dart';
import '../helper_requests/base_class_short_mu.dart';

part 'user_models.g.dart';

@JsonSerializable()
class UserURU {
  final String? pfp;
  final String? username;
  final String? name;
  final String? lastName;
  final String? email;

  @DateOnlyConverter()
  final DateTime? birthday;

  final String? password;
  final String? password2;
  final bool? twoFA;
  final int? genderId;

  const UserURU({
    this.pfp,
    this.username,
    this.name,
    this.lastName,
    this.email,
    this.birthday,
    this.password,
    this.password2,
    this.twoFA,
    this.genderId,
  });

  factory UserURU.fromJson(Map<String, dynamic> json) =>
      _$UserURUFromJson(json);

  Map<String, dynamic> toJson() => _$UserURUToJson(this);
}

@JsonSerializable()
class UserURE {
  final String? pfp;
  final String? username;
  final String? name;
  final String? lastName;
  final String? email;

  @DateOnlyConverter()
  final DateTime? birthday;

  final int? genderId;
  final int? userStatusId;

  const UserURE({
    this.pfp,
    this.username,
    this.name,
    this.lastName,
    this.email,
    this.birthday,
    this.genderId,
    this.userStatusId,
  });

  factory UserURE.fromJson(Map<String, dynamic> json) =>
      _$UserUREFromJson(json);

  Map<String, dynamic> toJson() => _$UserUREToJson(this);
}

@JsonSerializable()
class UserSOU extends BaseSO {
  const UserSOU({super.page, super.pageSize});

  factory UserSOU.fromJson(Map<String, dynamic> json) =>
      _$UserSOUFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserSOUToJson(this);
}

@JsonSerializable()
class UserSOE extends BaseSO {
  final String? usernameFTS;
  final String? fullNameFTS;
  final String? emailFTS;

  @DateOnlyConverter()
  final DateTime? birthdayGTE;

  @DateOnlyConverter()
  final DateTime? birthdayLTE;

  final DateTime? createdAtGTE;
  final DateTime? createdAtLTE;
  final int? userRoleId;
  final int? userStatusId;
  final int? genderId;
  final UserSortField? orderBy;
  final SortType? sortType;

  const UserSOE({
    super.page,
    super.pageSize,
    this.usernameFTS,
    this.fullNameFTS,
    this.emailFTS,
    this.birthdayGTE,
    this.birthdayLTE,
    this.createdAtGTE,
    this.createdAtLTE,
    this.userRoleId,
    this.userStatusId,
    this.genderId,
    this.orderBy,
    this.sortType,
  });

  factory UserSOE.fromJson(Map<String, dynamic> json) =>
      _$UserSOEFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserSOEToJson(this);
}

@JsonEnum()
enum UserSortField {
  username,
  name,
  lastName,
  email,
  birthday,
  createdAt,
  userRoleId,
  userStatusId,
  genderId,
}

@JsonSerializable()
class UserMU {
  final int id;
  final String pfp;
  final String username;
  final String name;
  final String lastName;
  final String email;

  @DateOnlyConverter()
  final DateTime birthday;

  final DateTime createdAt;
  final bool twoFA;
  final BaseClassShortMU userRole;
  final BaseClassShortMU userStatus;
  final BaseClassShortMU gender;

  const UserMU({
    required this.id,
    required this.pfp,
    required this.username,
    required this.name,
    required this.lastName,
    required this.email,
    required this.birthday,
    required this.createdAt,
    required this.twoFA,
    required this.userRole,
    required this.userStatus,
    required this.gender,
  });

  factory UserMU.fromJson(Map<String, dynamic> json) => _$UserMUFromJson(json);

  Map<String, dynamic> toJson() => _$UserMUToJson(this);
}

@JsonSerializable()
class UserME {
  final int id;
  final String pfp;
  final String username;
  final String name;
  final String lastName;
  final String email;

  @DateOnlyConverter()
  final DateTime birthday;

  final DateTime createdAt;
  final bool twoFA;
  final BaseClassShortMU userRole;
  final BaseClassShortMU userStatus;
  final BaseClassShortMU gender;

  const UserME({
    required this.id,
    required this.pfp,
    required this.username,
    required this.name,
    required this.lastName,
    required this.email,
    required this.birthday,
    required this.createdAt,
    required this.twoFA,
    required this.userRole,
    required this.userStatus,
    required this.gender,
  });

  factory UserME.fromJson(Map<String, dynamic> json) => _$UserMEFromJson(json);

  Map<String, dynamic> toJson() => _$UserMEToJson(this);
}

@JsonSerializable()
class UserIRU {
  final String pfp;
  final String username;
  final String name;
  final String lastName;
  final String email;

  @DateOnlyConverter()
  final DateTime birthday;

  final String password;
  final String password2;
  final int genderId;

  const UserIRU({
    required this.pfp,
    required this.username,
    required this.name,
    required this.lastName,
    required this.email,
    required this.birthday,
    required this.password,
    required this.password2,
    required this.genderId,
  });

  factory UserIRU.fromJson(Map<String, dynamic> json) =>
      _$UserIRUFromJson(json);

  Map<String, dynamic> toJson() => _$UserIRUToJson(this);
}

@JsonSerializable()
class UserIRE {
  final String pfp;
  final String username;
  final String name;
  final String lastName;
  final String email;

  @DateOnlyConverter()
  final DateTime birthday;

  final String password;
  final String password2;
  final int genderId;
  final int userRoleId;

  const UserIRE({
    required this.pfp,
    required this.username,
    required this.name,
    required this.lastName,
    required this.email,
    required this.birthday,
    required this.password,
    required this.password2,
    required this.genderId,
    required this.userRoleId,
  });

  factory UserIRE.fromJson(Map<String, dynamic> json) =>
      _$UserIREFromJson(json);

  Map<String, dynamic> toJson() => _$UserIREToJson(this);
}
