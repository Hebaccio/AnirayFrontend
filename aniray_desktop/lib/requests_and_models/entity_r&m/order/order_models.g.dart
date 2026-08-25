// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderURU _$OrderURUFromJson(Map<String, dynamic> json) => OrderURU();

Map<String, dynamic> _$OrderURUToJson(OrderURU instance) => <String, dynamic>{};

OrderURE _$OrderUREFromJson(Map<String, dynamic> json) =>
    OrderURE(orderStatusId: (json['orderStatusId'] as num).toInt());

Map<String, dynamic> _$OrderUREToJson(OrderURE instance) => <String, dynamic>{
  'orderStatusId': instance.orderStatusId,
};

OrderSOU _$OrderSOUFromJson(Map<String, dynamic> json) => OrderSOU(
  page: (json['page'] as num?)?.toInt() ?? 0,
  pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
);

Map<String, dynamic> _$OrderSOUToJson(OrderSOU instance) => <String, dynamic>{
  'page': instance.page,
  'pageSize': instance.pageSize,
};

OrderSOE _$OrderSOEFromJson(Map<String, dynamic> json) => OrderSOE(
  page: (json['page'] as num?)?.toInt() ?? 0,
  pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
  dateTimeGTE: json['dateTimeGTE'] == null
      ? null
      : DateTime.parse(json['dateTimeGTE'] as String),
  dateTimeLTE: json['dateTimeLTE'] == null
      ? null
      : DateTime.parse(json['dateTimeLTE'] as String),
  fullPriceGTE: (json['fullPriceGTE'] as num?)?.toDouble(),
  fullPriceLTE: (json['fullPriceLTE'] as num?)?.toDouble(),
  orderStatusId: (json['orderStatusId'] as num?)?.toInt(),
  userId: (json['userId'] as num?)?.toInt(),
  userNameFTS: json['userNameFTS'] as String?,
  userMailFTS: json['userMailFTS'] as String?,
  userCountryFTS: json['userCountryFTS'] as String?,
  userCityFTS: json['userCityFTS'] as String?,
  userZIPFTS: json['userZIPFTS'] as String?,
  orderBy: $enumDecodeNullable(_$OrderSortFieldEnumMap, json['orderBy']),
  sortType: $enumDecodeNullable(_$SortTypeEnumMap, json['sortType']),
);

Map<String, dynamic> _$OrderSOEToJson(OrderSOE instance) => <String, dynamic>{
  'page': instance.page,
  'pageSize': instance.pageSize,
  'dateTimeGTE': instance.dateTimeGTE?.toIso8601String(),
  'dateTimeLTE': instance.dateTimeLTE?.toIso8601String(),
  'fullPriceGTE': instance.fullPriceGTE,
  'fullPriceLTE': instance.fullPriceLTE,
  'orderStatusId': instance.orderStatusId,
  'userId': instance.userId,
  'userNameFTS': instance.userNameFTS,
  'userMailFTS': instance.userMailFTS,
  'userCountryFTS': instance.userCountryFTS,
  'userCityFTS': instance.userCityFTS,
  'userZIPFTS': instance.userZIPFTS,
  'orderBy': _$OrderSortFieldEnumMap[instance.orderBy],
  'sortType': _$SortTypeEnumMap[instance.sortType],
};

const _$OrderSortFieldEnumMap = {
  OrderSortField.dateTime: 'dateTime',
  OrderSortField.fullPrice: 'fullPrice',
};

const _$SortTypeEnumMap = {
  SortType.ascending: 'ascending',
  SortType.descending: 'descending',
};

OrderMU _$OrderMUFromJson(Map<String, dynamic> json) => OrderMU(
  id: (json['id'] as num).toInt(),
  dateTime: DateTime.parse(json['dateTime'] as String),
  fullPrice: (json['fullPrice'] as num).toDouble(),
  orderStatus: BaseClassMU.fromJson(
    json['orderStatus'] as Map<String, dynamic>,
  ),
  userName: json['userName'] as String,
  userMail: json['userMail'] as String,
  userPhone: json['userPhone'] as String,
  userCountry: json['userCountry'] as String,
  userCity: json['userCity'] as String,
  userZIP: json['userZIP'] as String,
  userAdress: json['userAdress'] as String,
  userNotes: json['userNotes'] as String,
  bluRay:
      (json['bluRay'] as List<dynamic>?)
          ?.map((e) => OrderBluRayMU.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$OrderMUToJson(OrderMU instance) => <String, dynamic>{
  'id': instance.id,
  'dateTime': instance.dateTime.toIso8601String(),
  'fullPrice': instance.fullPrice,
  'orderStatus': instance.orderStatus,
  'userName': instance.userName,
  'userMail': instance.userMail,
  'userPhone': instance.userPhone,
  'userCountry': instance.userCountry,
  'userCity': instance.userCity,
  'userZIP': instance.userZIP,
  'userAdress': instance.userAdress,
  'userNotes': instance.userNotes,
  'bluRay': instance.bluRay,
};

OrderME _$OrderMEFromJson(Map<String, dynamic> json) => OrderME(
  id: (json['id'] as num).toInt(),
  dateTime: DateTime.parse(json['dateTime'] as String),
  fullPrice: (json['fullPrice'] as num).toDouble(),
  orderStatus: BaseClass.fromJson(json['orderStatus'] as Map<String, dynamic>),
  userId: (json['userId'] as num).toInt(),
  userName: json['userName'] as String,
  userMail: json['userMail'] as String,
  userPhone: json['userPhone'] as String,
  userCountry: json['userCountry'] as String,
  userCity: json['userCity'] as String,
  userZIP: json['userZIP'] as String,
  userAdress: json['userAdress'] as String,
  userNotes: json['userNotes'] as String,
  bluRay:
      (json['bluRay'] as List<dynamic>?)
          ?.map((e) => OrderBluRayME.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$OrderMEToJson(OrderME instance) => <String, dynamic>{
  'id': instance.id,
  'dateTime': instance.dateTime.toIso8601String(),
  'fullPrice': instance.fullPrice,
  'orderStatus': instance.orderStatus,
  'userId': instance.userId,
  'userName': instance.userName,
  'userMail': instance.userMail,
  'userPhone': instance.userPhone,
  'userCountry': instance.userCountry,
  'userCity': instance.userCity,
  'userZIP': instance.userZIP,
  'userAdress': instance.userAdress,
  'userNotes': instance.userNotes,
  'bluRay': instance.bluRay,
};

OrderIRU _$OrderIRUFromJson(Map<String, dynamic> json) => OrderIRU(
  userPhone: json['userPhone'] as String,
  userCountry: json['userCountry'] as String,
  userCity: json['userCity'] as String,
  userZIP: json['userZIP'] as String,
  userAdress: json['userAdress'] as String,
  userNotes: json['userNotes'] as String?,
  bluRayAmountChange: json['bluRayAmountChange'] as bool,
  bluRay:
      (json['bluRay'] as List<dynamic>?)
          ?.map((e) => OrderBluRayIRU.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$OrderIRUToJson(OrderIRU instance) => <String, dynamic>{
  'userPhone': instance.userPhone,
  'userCountry': instance.userCountry,
  'userCity': instance.userCity,
  'userZIP': instance.userZIP,
  'userAdress': instance.userAdress,
  'userNotes': instance.userNotes,
  'bluRayAmountChange': instance.bluRayAmountChange,
  'bluRay': instance.bluRay,
};

OrderIRE _$OrderIREFromJson(Map<String, dynamic> json) => OrderIRE();

Map<String, dynamic> _$OrderIREToJson(OrderIRE instance) => <String, dynamic>{};

OrderBluRayMU _$OrderBluRayMUFromJson(Map<String, dynamic> json) =>
    OrderBluRayMU(
      orderId: (json['orderId'] as num).toInt(),
      bluRay: BluRayMU.fromJson(json['bluRay'] as Map<String, dynamic>),
      amount: (json['amount'] as num).toInt(),
    );

Map<String, dynamic> _$OrderBluRayMUToJson(OrderBluRayMU instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'bluRay': instance.bluRay,
      'amount': instance.amount,
    };

OrderBluRayME _$OrderBluRayMEFromJson(Map<String, dynamic> json) =>
    OrderBluRayME(
      orderId: (json['orderId'] as num).toInt(),
      bluRay: BluRayME.fromJson(json['bluRay'] as Map<String, dynamic>),
      amount: (json['amount'] as num).toInt(),
    );

Map<String, dynamic> _$OrderBluRayMEToJson(OrderBluRayME instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'bluRay': instance.bluRay,
      'amount': instance.amount,
    };

OrderBluRayIRU _$OrderBluRayIRUFromJson(Map<String, dynamic> json) =>
    OrderBluRayIRU(
      bluRayId: (json['bluRayId'] as num).toInt(),
      amount: (json['amount'] as num).toInt(),
    );

Map<String, dynamic> _$OrderBluRayIRUToJson(OrderBluRayIRU instance) =>
    <String, dynamic>{'bluRayId': instance.bluRayId, 'amount': instance.amount};

OrderBluRayIRE _$OrderBluRayIREFromJson(Map<String, dynamic> json) =>
    OrderBluRayIRE();

Map<String, dynamic> _$OrderBluRayIREToJson(OrderBluRayIRE instance) =>
    <String, dynamic>{};
