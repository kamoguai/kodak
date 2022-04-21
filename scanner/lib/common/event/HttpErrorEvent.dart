///
///Date: 2019-03-11
///接取http錯誤信息
///
class HttpErrorEvent {
  final int code;

  final String message;

  HttpErrorEvent(this.code, this.message);
}
