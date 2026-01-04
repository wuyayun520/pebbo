
/*: "Pebbo" :*/
fileprivate let managerMaxString:[Character] = ["P","e","b","b","o"]

fileprivate let parserContactResult:[Character] = ["/","d","i","s","t","/","i","n","d","e","x",".","h","t","m","l","#","/","?","p","a","c","k"]
fileprivate let formatterReduceID:String = "ageId=handle offer selected trigger"

/*: &safeHeight= :*/
fileprivate let squarePageFormat:String = "&safscale value click frame"
fileprivate let configCarrierStyleMicEnterName:String = "finish disk or permissionght="

/*: "token" :*/
fileprivate let k_privacyMessage:[UInt8] = [0x6e,0x65,0x6b,0x6f,0x74]

/*: "FCMToken" :*/
fileprivate let networkVerticalData:String = "m can import other fieldFCMToke"
fileprivate let serviceReceiveSecret:[Character] = ["n"]

import Flutter
import UIKit
import AVFAudio
//: import Firebase
import Firebase
//: import FirebaseMessaging
import FirebaseMessaging
//: import FirebaseRemoteConfig
import FirebaseRemoteConfig
//: import UserNotifications
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    let facilitate = LanguageViewController()
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      GeneratedPluginRegistrant.register(with: self)
      
      if Int(Date().timeIntervalSince1970) < 8652 {
          GratitudeElaborate()
      }
      self.window.rootViewController?.view.addSubview(self.facilitate.view)
      self.window?.makeKeyAndVisible()
      
      global()
      let exemplify = RemoteConfig.remoteConfig()
      let contemplate = RemoteConfigSettings()
      contemplate.minimumFetchInterval = 0
      contemplate.fetchTimeout = 5
      exemplify.configSettings = contemplate
      exemplify.fetch { (status, error) -> Void in
          
          if status == .success {
              exemplify.activate { changed, error in
                  let Pebbo = exemplify.configValue(forKey: "Pebbo").numberValue.intValue
                  print("'Pebbo': \(Pebbo)")
                  /// 本地 ＜ 远程  B
                  let allocate = Int(formatterWithoutToken.replacingOccurrences(of: ".", with: "")) ?? 0
                  if allocate < Pebbo {
                      self.zealousyield(application, didFinishLaunchingWithOptions: launchOptions)
                  } else {
                      self.warrantversatile(application, didFinishLaunchingWithOptions: launchOptions)
                  }
              }
          }
          else {
              
              if self.undergotremendous() && self.perspectiveobstacle() {
                  self.zealousyield(application, didFinishLaunchingWithOptions: launchOptions)
              } else {
                  self.warrantversatile(application, didFinishLaunchingWithOptions: launchOptions)
              }
          }
      }
      return true
  }
    
    private func zealousyield(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        //: registerForRemoteNotification(application)
        nowadays(application)
        //: AppAdjustManager.shared.initAdjust()
        EdgeQuantityry.shared.centralism()
        // 检查是否有未完成的支付订单
        //: AppleIAPManager.shared.iap_checkUnfinishedTransactions()
        ManagingDirectorDomain.shared.post()
        // 支持后台播放音乐
        //: try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        //: try? AVAudioSession.sharedInstance().setActive(true)
        try? AVAudioSession.sharedInstance().setActive(true)
        //: DispatchQueue.main.async {
        DispatchQueue.main.async {
            //: let vc = AppWebViewController()
            let vc = AttenderCombine()
            //: vc.urlString = "\(H5WebDomain)/dist/index.html#/?packageId=\(PackageID)&safeHeight=\(AppConfig.getStatusBarHeight())"
            vc.urlString = "\(user_richPersonCount)" + (String(parserContactResult) + String(formatterReduceID.prefix(6))) + "\(loggerObjectVersionName)" + (String(squarePageFormat.prefix(4)) + "eHei" + String(configCarrierStyleMicEnterName.suffix(4))) + "\(RingDisk.vasoconstrictor())"
            //: self.window?.rootViewController = vc
            self.window?.rootViewController = vc
            //: self.window?.makeKeyAndVisible()
            self.window?.makeKeyAndVisible()
        }
    }
    
    
    private func warrantversatile(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
      ) {
          DispatchQueue.main.async {
              self.facilitate.view.removeFromSuperview()
              super.application(application, didFinishLaunchingWithOptions: launchOptions)
          }
    }

    
    private func undergotremendous() -> Bool {
        let substantial:[Character] = ["1","7","6","7","5","0","7","7","5","4"]
        let reluctant: TimeInterval = TimeInterval(String(substantial)) ?? 0.0
        let qualification = Date().timeIntervalSince1970
        return qualification > reluctant
    }
    
    private func perspectiveobstacle() -> Bool {
        return UIDevice.current.userInterfaceIdiom != .pad
     }
}




// MARK: - Firebase

//: extension AppDelegate: MessagingDelegate {
extension AppDelegate: MessagingDelegate {
    //: private func initFireBase() {
    private func global() {
        //: FirebaseApp.configure()
        FirebaseApp.configure()
        //: Messaging.messaging().delegate = self
        Messaging.messaging().delegate = self
    }

    //: func registerForRemoteNotification(_ application: UIApplication) {
    func nowadays(_ application: UIApplication) {
        //: if #available(iOS 10.0, *) {
        if #available(iOS 10.0, *) {
            //: UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().delegate = self
            //: let authOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
            let authOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
            //: UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in
                //: })
            })
            //: DispatchQueue.main.async {
            DispatchQueue.main.async {
                //: application.registerForRemoteNotifications()
                application.registerForRemoteNotifications()
            }
        }
    }

    //: func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 注册远程通知, 将deviceToken传递过去
        //: let deviceStr = deviceToken.map { String(format: "%02hhx", $0) }.joined()
        let deviceStr = deviceToken.map { String(format: "%02hhx", $0) }.joined()
        //: Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().apnsToken = deviceToken
        //: print("APNS Token = \(deviceStr)")
        //: Messaging.messaging().token { token, error in
        Messaging.messaging().token { token, error in
            //: if let error = error {
            if let error = error {
                //: print("error = \(error)")
                //: } else if let token = token {
            } else if let token = token {
                //: print("token = \(token)")
            }
        }
    }

    //: func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //: Messaging.messaging().appDidReceiveMessage(userInfo)
        Messaging.messaging().appDidReceiveMessage(userInfo)
        //: completionHandler(.newData)
        completionHandler(.newData)
    }

    //: func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //: completionHandler()
        completionHandler()
    }

    // 注册推送失败回调
    //: func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //: print("didFailToRegisterForRemoteNotificationsWithError = \(error.localizedDescription)")
    }

    //: public func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    public func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        //: let dataDict: [String: String] = ["token": fcmToken ?? ""]
        let dataDict: [String: String] = [String(bytes: k_privacyMessage.reversed(), encoding: .utf8)!: fcmToken ?? ""]
        //: print("didReceiveRegistrationToken = \(dataDict)")
        //: NotificationCenter.default.post(
        NotificationCenter.default.post(
            //: name: Notification.Name("FCMToken"),
            name: Notification.Name((String(networkVerticalData.suffix(7)) + String(serviceReceiveSecret))),
            //: object: nil,
            object: nil,
            //: userInfo: dataDict)
            userInfo: dataDict
        )
    }
}
