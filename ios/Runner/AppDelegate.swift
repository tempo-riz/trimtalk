import UIKit
import Flutter
import flutter_local_notifications
// import workmanager

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // This is required to make any communication available in the action isolate.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    // In AppDelegate.application method - depracated after ios 12
    // WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "task-identifier")

    // Register a periodic task in iOS 13+
    // WorkmanagerPlugin.registerPeriodicTask(withIdentifier: "com.trimtalk.app.iOSBackgroundAppRefresh", frequency: NSNumber(value: 20 * 60))

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
