import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let mapsChannel = FlutterMethodChannel(name: "season_app/maps",
                                          binaryMessenger: controller.binaryMessenger)
    mapsChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      switch call.method {
      case "launchAppleMaps":
        if let args = call.arguments as? [String: Any],
           let latitude = args["latitude"] as? Double,
           let longitude = args["longitude"] as? Double {
          self.launchAppleMaps(latitude: latitude, longitude: longitude, result: result)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Latitude and longitude are required", details: nil))
        }
      case "launchGoogleMaps":
        if let args = call.arguments as? [String: Any],
           let latitude = args["latitude"] as? Double,
           let longitude = args["longitude"] as? Double {
          self.launchGoogleMaps(latitude: latitude, longitude: longitude, result: result)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Latitude and longitude are required", details: nil))
        }
      case "launchUrl":
        if let args = call.arguments as? [String: Any],
           let url = args["url"] as? String {
          self.launchUrl(url: url, result: result)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "URL is required", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func launchAppleMaps(latitude: Double, longitude: Double, result: @escaping FlutterResult) {
    let urlString = "http://maps.apple.com/?q=\(latitude),\(longitude)"
    if let url = URL(string: urlString) {
      if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: { success in
          if success {
            result("Apple Maps launched successfully")
          } else {
            result(FlutterError(code: "LAUNCH_ERROR", message: "Failed to launch Apple Maps", details: nil))
          }
        })
      } else {
        result(FlutterError(code: "APP_NOT_FOUND", message: "Apple Maps not available", details: nil))
      }
    } else {
      result(FlutterError(code: "INVALID_URL", message: "Invalid URL format", details: nil))
    }
  }
  
  private func launchGoogleMaps(latitude: Double, longitude: Double, result: @escaping FlutterResult) {
    let urlString = "comgooglemaps://?q=\(latitude),\(longitude)"
    if let url = URL(string: urlString) {
      if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: { success in
          if success {
            result("Google Maps launched successfully")
          } else {
            result(FlutterError(code: "LAUNCH_ERROR", message: "Failed to launch Google Maps", details: nil))
          }
        })
      } else {
        // Fallback to web version
        let webUrlString = "https://www.google.com/maps/search/?api=1&query=\(latitude),\(longitude)"
        if let webUrl = URL(string: webUrlString) {
          UIApplication.shared.open(webUrl, options: [:], completionHandler: { success in
            if success {
              result("Google Maps web launched successfully")
            } else {
              result(FlutterError(code: "LAUNCH_ERROR", message: "Failed to launch Google Maps web", details: nil))
            }
          })
        } else {
          result(FlutterError(code: "INVALID_URL", message: "Invalid web URL format", details: nil))
        }
      }
    } else {
      result(FlutterError(code: "INVALID_URL", message: "Invalid URL format", details: nil))
    }
  }
  
  private func launchUrl(url: String, result: @escaping FlutterResult) {
    if let urlObj = URL(string: url) {
      if UIApplication.shared.canOpenURL(urlObj) {
        UIApplication.shared.open(urlObj, options: [:], completionHandler: { success in
          if success {
            result("URL launched successfully")
          } else {
            result(FlutterError(code: "LAUNCH_ERROR", message: "Failed to launch URL", details: nil))
          }
        })
      } else {
        result(FlutterError(code: "NO_BROWSER", message: "No browser available", details: nil))
      }
    } else {
      result(FlutterError(code: "INVALID_URL", message: "Invalid URL format", details: nil))
    }
  }
}
