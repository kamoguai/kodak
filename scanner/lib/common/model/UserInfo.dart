import 'package:json_annotation/json_annotation.dart';

part 'UserInfo.g.dart';

@JsonSerializable()
class UserInfo {
  String account = "";
  String password = "";
  String token = "";
  String aesIv = "";
  String aesKey = "";
  String downloadAppUrl = "";
  String version = "";
  String useAes = "";

  UserInfo(this.account, this.password, this.token, this.aesIv, this.aesKey,
      this.downloadAppUrl, this.version, this.useAes);

  // 反序列化
  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);
  // 序列化
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);

  // 命名構造函數
  UserInfo.empty();
}
