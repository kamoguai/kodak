import 'package:event_bus/event_bus.dart';
import 'package:scanner/common/event/HttpErrorEvent.dart';

///错误编码
class Code {
  ///网络错误
  static const network_error = -1;

  ///网络超时
  static const network_timeout = -2;

  ///网络返回数据格式化一次
  static const network_json_exception = -3;

  static const success = 200;

  static final EventBus eventBus = EventBus();

  static errorHandleFunction(code, message, noTip) {
    if (noTip) {
      return message;
    }
    eventBus.fire(HttpErrorEvent(code, message));
    return message;
  }
}
