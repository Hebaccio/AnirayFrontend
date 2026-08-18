import 'package:aniray_desktop/models/basic_entities/basic_entities.dart';
import 'package:aniray_desktop/models/bluray/bluray_models.dart';
import 'package:aniray_desktop/models/movie/movie_models.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_models.g.dart';

@JsonSerializable()
class OrderURU {
  const OrderURU();

  factory OrderURU.fromJson(Map<String, dynamic> json) =>
      _$OrderURUFromJson(json);

  Map<String, dynamic> toJson() => _$OrderURUToJson(this);
}

@JsonSerializable()
class OrderURE {
  final int orderStatusId;

  const OrderURE({required this.orderStatusId});

  factory OrderURE.fromJson(Map<String, dynamic> json) =>
      _$OrderUREFromJson(json);

  Map<String, dynamic> toJson() => _$OrderUREToJson(this);
}

@JsonSerializable()
class OrderSOU extends BaseSO {
  const OrderSOU({super.page, super.pageSize});

  factory OrderSOU.fromJson(Map<String, dynamic> json) =>
      _$OrderSOUFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OrderSOUToJson(this);
}

@JsonSerializable()
class OrderSOE extends BaseSO {
  final DateTime? dateTimeGTE;
  final DateTime? dateTimeLTE;
  final double? fullPriceGTE;
  final double? fullPriceLTE;
  final int? orderStatusId;
  final int? userId;
  final String? userNameFTS;
  final String? userMailFTS;
  final String? userCountryFTS;
  final String? userCityFTS;
  final String? userZIPFTS;
  final OrderSortField? orderBy;
  final SortType? sortType;

  const OrderSOE({
    super.page,
    super.pageSize,
    this.dateTimeGTE,
    this.dateTimeLTE,
    this.fullPriceGTE,
    this.fullPriceLTE,
    this.orderStatusId,
    this.userId,
    this.userNameFTS,
    this.userMailFTS,
    this.userCountryFTS,
    this.userCityFTS,
    this.userZIPFTS,
    this.orderBy,
    this.sortType,
  });

  factory OrderSOE.fromJson(Map<String, dynamic> json) =>
      _$OrderSOEFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OrderSOEToJson(this);
}

enum OrderSortField { dateTime, fullPrice }

@JsonSerializable()
class OrderMU {
  final int id;
  final DateTime dateTime;
  final double fullPrice;
  final BaseClassMU orderStatus;
  final String userName;
  final String userMail;
  final String userPhone;
  final String userCountry;
  final String userCity;
  final String userZIP;
  final String userAdress;
  final String userNotes;
  final List<OrderBluRayMU> bluRay;

  const OrderMU({
    required this.id,
    required this.dateTime,
    required this.fullPrice,
    required this.orderStatus,
    required this.userName,
    required this.userMail,
    required this.userPhone,
    required this.userCountry,
    required this.userCity,
    required this.userZIP,
    required this.userAdress,
    required this.userNotes,
    this.bluRay = const [],
  });

  factory OrderMU.fromJson(Map<String, dynamic> json) =>
      _$OrderMUFromJson(json);

  Map<String, dynamic> toJson() => _$OrderMUToJson(this);
}

@JsonSerializable()
class OrderME {
  final int id;
  final DateTime dateTime;
  final double fullPrice;
  final BaseClass orderStatus;
  final int userId;
  final String userName;
  final String userMail;
  final String userPhone;
  final String userCountry;
  final String userCity;
  final String userZIP;
  final String userAdress;
  final String userNotes;
  final List<OrderBluRayME> bluRay;

  const OrderME({
    required this.id,
    required this.dateTime,
    required this.fullPrice,
    required this.orderStatus,
    required this.userId,
    required this.userName,
    required this.userMail,
    required this.userPhone,
    required this.userCountry,
    required this.userCity,
    required this.userZIP,
    required this.userAdress,
    required this.userNotes,
    this.bluRay = const [],
  });

  factory OrderME.fromJson(Map<String, dynamic> json) =>
      _$OrderMEFromJson(json);

  Map<String, dynamic> toJson() => _$OrderMEToJson(this);
}

@JsonSerializable()
class OrderIRU {
  final String userPhone;
  final String userCountry;
  final String userCity;
  final String userZIP;
  final String userAdress;
  final String? userNotes;
  final bool bluRayAmountChange;
  final List<OrderBluRayIRU> bluRay;

  const OrderIRU({
    required this.userPhone,
    required this.userCountry,
    required this.userCity,
    required this.userZIP,
    required this.userAdress,
    this.userNotes,
    required this.bluRayAmountChange,
    this.bluRay = const [],
  });

  factory OrderIRU.fromJson(Map<String, dynamic> json) =>
      _$OrderIRUFromJson(json);

  Map<String, dynamic> toJson() => _$OrderIRUToJson(this);
}

@JsonSerializable()
class OrderIRE {
  const OrderIRE();

  factory OrderIRE.fromJson(Map<String, dynamic> json) =>
      _$OrderIREFromJson(json);

  Map<String, dynamic> toJson() => _$OrderIREToJson(this);
}

@JsonSerializable()
class OrderBluRayMU {
  final int orderId;
  final BluRayMU bluRay;
  final int amount;

  const OrderBluRayMU({
    required this.orderId,
    required this.bluRay,
    required this.amount,
  });

  factory OrderBluRayMU.fromJson(Map<String, dynamic> json) =>
      _$OrderBluRayMUFromJson(json);

  Map<String, dynamic> toJson() => _$OrderBluRayMUToJson(this);
}

@JsonSerializable()
class OrderBluRayME {
  final int orderId;
  final BluRayME bluRay;
  final int amount;

  const OrderBluRayME({
    required this.orderId,
    required this.bluRay,
    required this.amount,
  });

  factory OrderBluRayME.fromJson(Map<String, dynamic> json) =>
      _$OrderBluRayMEFromJson(json);

  Map<String, dynamic> toJson() => _$OrderBluRayMEToJson(this);
}

@JsonSerializable()
class OrderBluRayIRU {
  final int bluRayId;
  final int amount;

  const OrderBluRayIRU({required this.bluRayId, required this.amount});

  factory OrderBluRayIRU.fromJson(Map<String, dynamic> json) =>
      _$OrderBluRayIRUFromJson(json);

  Map<String, dynamic> toJson() => _$OrderBluRayIRUToJson(this);
}

@JsonSerializable()
class OrderBluRayIRE {
  const OrderBluRayIRE();

  factory OrderBluRayIRE.fromJson(Map<String, dynamic> json) =>
      _$OrderBluRayIREFromJson(json);

  Map<String, dynamic> toJson() => _$OrderBluRayIREToJson(this);
}
