import UIKit
import Flutter
import CoreAudio

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      
    let METHOD_CHANNEL_NAME = "wifiSwift"
      let swiftChannel = FlutterMethodChannel(name: METHOD_CHANNEL_NAME, binaryMessenger: controller.binaryMessenger)
      
      swiftChannel.setMethodCallHandler({
          (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          switch call.method {
          case "getSwiftWifiInfo":
              let args = ""
          default:
              result(FlutterMethodNotImplemented)
          }
      })
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
   
   
}
/*
extension FlutterViewController: CLLocationManagerDelegate{
    var locationManager = CLLocationManager()
     var currentNetworkInfos: Array<NetworkInfo>? {
         get {
             return SSID.fetchNetworkInfo()
         }
     }
    
    func updateWiFi() {
         print("SSID: \(currentNetworkInfos?.first?.ssid ?? "")")
         
         if let ssid = currentNetworkInfos?.first?.ssid {
             ssidLabel.text = "SSID: \(ssid)"
         }
         
         if let bssid = currentNetworkInfos?.first?.bssid {
             bssidLabel.text = "BSSID: \(bssid)"
         }
         
     }
     
     func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
         if status == .authorizedWhenInUse {
             updateWiFi()
         }
       }
     
      }
    
    public class SSID {
     class func fetchNetworkInfo() -> [NetworkInfo]? {
         if let interfaces: NSArray = CNCopySupportedInterfaces() {
             var networkInfos = [NetworkInfo]()
             for interface in interfaces {
                 let interfaceName = interface as! String
                 var networkInfo = NetworkInfo(interface: interfaceName,
                                               success: false,
                                               ssid: nil,
                                               bssid: nil)
                 if let dict = CNCopyCurrentNetworkInfo(interfaceName as CFString) as NSDictionary? {
                     networkInfo.success = true
                     networkInfo.ssid = dict[kCNNetworkInfoKeySSID as String] as? String
                     networkInfo.bssid = dict[kCNNetworkInfoKeyBSSID as String] as? String
                 }
                 networkInfos.append(networkInfo)
             }
             return networkInfos
         }
         return nil
       }
     }
    
    
    struct NetworkInfo {
    var interface: String
    var success: Bool = false
    var ssid: String?
    var bssid: String?
    }
}
*/
