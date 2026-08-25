// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usercart_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserCartURU _$UserCartURUFromJson(Map<String, dynamic> json) => UserCartURU(
  cartNotes: json['cartNotes'] as String? ?? '',
  bluRay:
      (json['bluRay'] as List<dynamic>?)
          ?.map((e) => BluRayCartUR.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$UserCartURUToJson(UserCartURU instance) =>
    <String, dynamic>{
      'cartNotes': instance.cartNotes,
      'bluRay': instance.bluRay,
    };

UserCartURE _$UserCartUREFromJson(Map<String, dynamic> json) => UserCartURE();

Map<String, dynamic> _$UserCartUREToJson(UserCartURE instance) =>
    <String, dynamic>{};

UserCartMU _$UserCartMUFromJson(Map<String, dynamic> json) => UserCartMU(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  fullCartPrice: (json['fullCartPrice'] as num).toDouble(),
  cartNotes: json['cartNotes'] as String? ?? '',
  bluRay:
      (json['bluRay'] as List<dynamic>?)
          ?.map((e) => BluRayCartMU.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$UserCartMUToJson(UserCartMU instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'fullCartPrice': instance.fullCartPrice,
      'cartNotes': instance.cartNotes,
      'bluRay': instance.bluRay,
    };

UserCartME _$UserCartMEFromJson(Map<String, dynamic> json) => UserCartME();

Map<String, dynamic> _$UserCartMEToJson(UserCartME instance) =>
    <String, dynamic>{};

UserCartIRU _$UserCartIRUFromJson(Map<String, dynamic> json) =>
    UserCartIRU(userId: (json['userId'] as num).toInt());

Map<String, dynamic> _$UserCartIRUToJson(UserCartIRU instance) =>
    <String, dynamic>{'userId': instance.userId};

UserCartIRE _$UserCartIREFromJson(Map<String, dynamic> json) => UserCartIRE();

Map<String, dynamic> _$UserCartIREToJson(UserCartIRE instance) =>
    <String, dynamic>{};

UserCartIndividualURU _$UserCartIndividualURUFromJson(
  Map<String, dynamic> json,
) => UserCartIndividualURU(
  bluRay: BluRayCartUR.fromJson(json['bluRay'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserCartIndividualURUToJson(
  UserCartIndividualURU instance,
) => <String, dynamic>{'bluRay': instance.bluRay};

BluRayCartUR _$BluRayCartURFromJson(Map<String, dynamic> json) => BluRayCartUR(
  bluRayId: (json['bluRayId'] as num).toInt(),
  amount: (json['amount'] as num).toInt(),
);

Map<String, dynamic> _$BluRayCartURToJson(BluRayCartUR instance) =>
    <String, dynamic>{'bluRayId': instance.bluRayId, 'amount': instance.amount};

BluRayCartMU _$BluRayCartMUFromJson(Map<String, dynamic> json) => BluRayCartMU(
  bluRay: BluRayMU.fromJson(json['bluRay'] as Map<String, dynamic>),
  amount: (json['amount'] as num).toInt(),
);

Map<String, dynamic> _$BluRayCartMUToJson(BluRayCartMU instance) =>
    <String, dynamic>{'bluRay': instance.bluRay, 'amount': instance.amount};
