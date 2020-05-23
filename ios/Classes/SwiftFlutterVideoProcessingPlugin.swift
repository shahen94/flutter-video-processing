import Flutter
import UIKit

enum QUALITY_ENUM: String {
  case QUALITY_LOW = "low"
  case QUALITY_MEDIUM = "medium"
  case QUALITY_HIGHEST = "highest"
  case QUALITY_640x480 = "640x480"
  case QUALITY_960x540 = "960x540"
  case QUALITY_1280x720 = "1280x720"
  case QUALITY_1920x1080 = "1920x1080"
  case QUALITY_3840x2160 = "3840x2160"
  case QUALITY_PASS_THROUGH = "passthrough"
}

public class SwiftFlutterVideoProcessingPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_video_processing", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterVideoProcessingPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if (call.method == "boomerang") {
        Boomerang.exec(call.arguments as! String, result: result)
        return;
    }
    result("iOS " + UIDevice.current.systemVersion)
  }
}
