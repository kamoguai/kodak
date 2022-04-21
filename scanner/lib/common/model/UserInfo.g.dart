// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserInfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
      json['account'] as String,
      json['password'] as String,
      json['token'] as String,
      json['aesIv'] as String,
      json['aesKey'] as String,
      json['downloadAppUrl'] as String,
      json['version'] as String,
      json['useAes'] == null ? '' : json['useAes'] as String,
    );

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
      'account': instance.account,
      'password': instance.password,
      'token': instance.token,
      'aesIv': instance.aesIv,
      'aesKey': instance.aesKey,
      'downloadAppUrl': instance.downloadAppUrl,
      'version': instance.version,
      'useAes': instance.useAes,
    };
