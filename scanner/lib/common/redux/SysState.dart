import 'package:scanner/common/model/UserInfo.dart';

import 'UserInfoRedux.dart';

class SysState {
  ///用戶信息
  UserInfo userInfo;

  SysState({required this.userInfo});
}

///創建 Reducer
///源碼中Reducer 是一個方法 typedef state Reducer<State>(State state, dynamic action);
///這裡自定義appReducer 用於創建store
SysState appReducer(SysState state, action) {
  return SysState(
    ///通過 UserReducdr 將 SysState 內的 userInfo 和 action 關聯在一起
    userInfo: UserInfoReducer(state.userInfo, action),
  );
}
