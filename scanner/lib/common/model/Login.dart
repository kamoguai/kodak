import 'package:json_annotation/json_annotation.dart';

part 'Login.g.dart';

@JsonSerializable()
class Login {
  String retCode; // 回傳code
  String retMSG; // 回傳msg

  Login(this.retCode, this.retMSG);
// 反序列化
  factory Login.fromJson(Map<String, dynamic> json) => _$LoginFromJson(json);
// 序列化
  Map<String, dynamic> toJson() => _$LoginToJson(this);
// 命名構造函數
  // Login.empty();
}
