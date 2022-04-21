class Address {
  static String domain = "http://192.168.0.0";

  ///------------ kodar scanner api -------------///
  ///取得機器session
  static getSession() {
    return "$domain/api/session";
  }

  ///取得機器設定
  static getConfig() {
    return "$domain/api/config/settings";
  }

  ///取得機器設定
  static getScannerStat() {
    return "$domain/api/scanner/status";
  }

  ///update config
  static updateConfig() {
    return "$domain/api/session";
  }

  ///開啟scan
  static startScan() {
    return "$domain/api/session/StartScan";
  }

  ///取得圖檔metadata
  static getImgMetaData(int count) {
    return "$domain/api/session/metadata/$count";
  }

  ///取得圖檔
  static getImg(int count) {
    return "$domain/api/session/image/$count";
  }

  ///停止session
  static stopSession() {
    return "$domain/api/session";
  }

  static getCapabilities() {
    return "$domain/api/scanner/capabilities";
  }
}
