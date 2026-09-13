// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  uid: json['uid'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  fundIds:
      (json['fundIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  createdAt: const IsoDateTimeConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'uid': instance.uid,
  'name': instance.name,
  'phone': instance.phone,
  'role': _$UserRoleEnumMap[instance.role]!,
  'fundIds': instance.fundIds,
  'createdAt': ?const IsoDateTimeConverter().toJson(instance.createdAt),
};

const _$UserRoleEnumMap = {UserRole.admin: 'admin', UserRole.member: 'member'};
