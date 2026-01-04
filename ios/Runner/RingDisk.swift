
//: Declare String Begin

/*: "socoay" :*/
fileprivate let sessionTodayKey:[Character] = ["s","o","c","o","a","y"]

/*: "975" :*/
fileprivate let noti_coreKey:[Character] = ["9","7","5"]

/*: "9v1scbegz8jk" :*/
fileprivate let noti_photoURL:String = "9v1track start on track flexible"
fileprivate let sessionWarnMFormat:String = "SCBE"

/*: "tc4gy1" :*/
fileprivate let constFailStatus:[Character] = ["t","c","4","g","y"]
fileprivate let app_privacyList:String = "1"

/*: "1.9.1" :*/
fileprivate let factoryMakeKey:String = "1.9.1"

/*: "https://m. :*/
fileprivate let managerAroundSessionDict:String = "halbumalbumps"

/*: .com" :*/
fileprivate let dataHideCanKey:String = "normal map.com"

/*: "CFBundleShortVersionString" :*/
fileprivate let userColorRemoteFoundationError:String = "CFBunlater transform observer dismiss product"
fileprivate let configNameProcessKey:[Character] = ["r","t","V"]
fileprivate let cacheTopPath:String = "ERSIO"

/*: "CFBundleDisplayName" :*/
fileprivate let loggerLayerPageResult:String = "import poorCFBund"
fileprivate let mainPostTime:String = "plabackground"
fileprivate let noti_oldId:String = "show except will presentation systemName"

/*: "CFBundleVersion" :*/
fileprivate let dataDiskId:String = "server privacyCFBund"
fileprivate let tingFinishState:String = "pending"

/*: "weixin" :*/
fileprivate let dataTopographicPointTime:String = "weveryxin"

/*: "wxwork" :*/
fileprivate let helperLabTime:String = "wxwoactive"

/*: "dingtalk" :*/
fileprivate let controllerApplicationPlatformDict:[Character] = ["d","i","n","g","t","a","l","k"]

/*: "lark" :*/
fileprivate let managerBackKey:String = "toark"

//: Declare String End

// __DEBUG__
// __CLOSE_PRINT__
//
//  RingDisk.swift
//  OverseaH5
//
//  Created by young on 2025/9/24.
//

//: import KeychainSwift
import KeychainSwift
//: import UIKit
import UIKit

/// 域名
//: let ReplaceUrlDomain = "socoay"
let ignitionKeyValue = (String(sessionTodayKey))
/// 包ID
//: let PackageID = "975"
let loggerObjectVersionName = (String(noti_coreKey))
/// Adjust
//: let AdjustKey = "9v1scbegz8jk"
let managerTransformShowTime = (String(noti_photoURL.prefix(3)) + sessionWarnMFormat.lowercased() + "gz8jk")
//: let AdInstallToken = "tc4gy1"
let networkStrideMessage = (String(constFailStatus) + app_privacyList.capitalized)

/// 网络版本号
//: let AppNetVersion = "1.9.1"
let networkProcessState = (factoryMakeKey.capitalized)
//: let H5WebDomain = "https://m.\(ReplaceUrlDomain).com"
let user_richPersonCount = (managerAroundSessionDict.replacingOccurrences(of: "album", with: "t") + "://m.") + "\(ignitionKeyValue)" + (String(dataHideCanKey.suffix(4)))
//: let AppVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
let formatterWithoutToken = Bundle.main.infoDictionary![(String(userColorRemoteFoundationError.prefix(5)) + "dleSho" + String(configNameProcessKey) + cacheTopPath.lowercased() + "nString")] as! String
//: let AppBundle = Bundle.main.bundleIdentifier!
let configNumberryValue = Bundle.main.bundleIdentifier!
//: let AppName = Bundle.main.infoDictionary!["CFBundleDisplayName"] ?? ""
let sessionOfferMode = Bundle.main.infoDictionary![(String(loggerLayerPageResult.suffix(6)) + "leDis" + mainPostTime.replacingOccurrences(of: "background", with: "y") + String(noti_oldId.suffix(4)))] ?? ""
//: let AppBuildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
let data_aroundScaleTitle = Bundle.main.infoDictionary![(String(dataDiskId.suffix(6)) + "leVersio" + tingFinishState.replacingOccurrences(of: "pending", with: "n"))] as! String

//: class AppConfig: NSObject {
class RingDisk: NSObject {
    /// 获取状态栏高度
    //: class func getStatusBarHeight() -> CGFloat {
    class func vasoconstrictor() -> CGFloat {
        //: if #available(iOS 13.0, *) {
        if #available(iOS 13.0, *) {
            //: if let statusBarManager = UIApplication.shared.windows.first?
            if let statusBarManager = UIApplication.shared.windows.first?
                //: .windowScene?.statusBarManager
                .windowScene?.statusBarManager
            {
                //: return statusBarManager.statusBarFrame.size.height
                return statusBarManager.statusBarFrame.size.height
            }
            //: } else {
        } else {
            //: return UIApplication.shared.statusBarFrame.size.height
            return UIApplication.shared.statusBarFrame.size.height
        }
        //: return 20.0
        return 20.0
    }

    /// 获取window
    //: class func getWindow() -> UIWindow {
    class func fire() -> UIWindow {
        //: var window = UIApplication.shared.windows.first(where: {
        var window = UIApplication.shared.windows.first(where: {
            //: $0.isKeyWindow
            $0.isKeyWindow
            //: })
        })
        // 是否为当前显示的window
        //: if window?.windowLevel != UIWindow.Level.normal {
        if window?.windowLevel != UIWindow.Level.normal {
            //: let windows = UIApplication.shared.windows
            let windows = UIApplication.shared.windows
            //: for windowTemp in windows {
            for windowTemp in windows {
                //: if windowTemp.windowLevel == UIWindow.Level.normal {
                if windowTemp.windowLevel == UIWindow.Level.normal {
                    //: window = windowTemp
                    window = windowTemp
                    //: break
                    break
                }
            }
        }
        //: return window!
        return window!
    }

    /// 获取当前控制器
    //: class func currentViewController() -> (UIViewController?) {
    class func getWeaving() -> (UIViewController?) {
        //: var window = AppConfig.getWindow()
        var window = RingDisk.fire()
        //: if window.windowLevel != UIWindow.Level.normal {
        if window.windowLevel != UIWindow.Level.normal {
            //: let windows = UIApplication.shared.windows
            let windows = UIApplication.shared.windows
            //: for windowTemp in windows {
            for windowTemp in windows {
                //: if windowTemp.windowLevel == UIWindow.Level.normal {
                if windowTemp.windowLevel == UIWindow.Level.normal {
                    //: window = windowTemp
                    window = windowTemp
                    //: break
                    break
                }
            }
        }
        //: let vc = window.rootViewController
        let vc = window.rootViewController
        //: return currentViewController(vc)
        return worldView(vc)
    }

    //: class func currentViewController(_ vc: UIViewController?)
    class func worldView(_ vc: UIViewController?)
        //: -> UIViewController?
        -> UIViewController?
    {
        //: if vc == nil {
        if vc == nil {
            //: return nil
            return nil
        }
        //: if let presentVC = vc?.presentedViewController {
        if let presentVC = vc?.presentedViewController {
            //: return currentViewController(presentVC)
            return worldView(presentVC)
            //: } else if let tabVC = vc as? UITabBarController {
        } else if let tabVC = vc as? UITabBarController {
            //: if let selectVC = tabVC.selectedViewController {
            if let selectVC = tabVC.selectedViewController {
                //: return currentViewController(selectVC)
                return worldView(selectVC)
            }
            //: return nil
            return nil
            //: } else if let naiVC = vc as? UINavigationController {
        } else if let naiVC = vc as? UINavigationController {
            //: return currentViewController(naiVC.visibleViewController)
            return worldView(naiVC.visibleViewController)
            //: } else {
        } else {
            //: return vc
            return vc
        }
    }
}

// MARK: - Device

//: extension UIDevice {
extension UIDevice {
    //: static var modelName: String {
    static var modelName: String {
        //: var systemInfo = utsname()
        var systemInfo = utsname()
        //: uname(&systemInfo)
        uname(&systemInfo)
        //: let machineMirror = Mirror(reflecting: systemInfo.machine)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        //: let identifier = machineMirror.children.reduce("") {
        let identifier = machineMirror.children.reduce("") {
            //: identifier, element in
            identifier, element in
            //: guard let value = element.value as? Int8, value != 0 else {
            guard let value = element.value as? Int8, value != 0 else {
                //: return identifier
                return identifier
            }
            //: return identifier + String(UnicodeScalar(UInt8(value)))
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        //: return identifier
        return identifier
    }

    /// 获取当前系统时区
    //: static var timeZone: String {
    static var timeZone: String {
        //: let currentTimeZone = NSTimeZone.system
        let currentTimeZone = NSTimeZone.system
        //: return currentTimeZone.identifier
        return currentTimeZone.identifier
    }

    /// 获取当前系统语言
    //: static var langCode: String {
    static var langCode: String {
        //: let language = Locale.preferredLanguages.first
        let language = Locale.preferredLanguages.first
        //: return language ?? ""
        return language ?? ""
    }

    /// 获取接口语言
    //: static var interfaceLang: String {
    static var interfaceLang: String {
        //: let lang = UIDevice.getSystemLangCode()
        let lang = UIDevice.drop()
        //: if ["en", "ar", "es", "pt"].contains(lang) {
        if ["en", "ar", "es", "pt"].contains(lang) {
            //: return lang
            return lang
        }
        //: return "en"
        return "en"
    }

    /// 获取当前系统地区
    //: static var countryCode: String {
    static var countryCode: String {
        //: let locale = Locale.current
        let locale = Locale.current
        //: let countryCode = locale.regionCode
        let countryCode = locale.regionCode
        //: return countryCode ?? ""
        return countryCode ?? ""
    }

    /// 获取系统UUID（每次调用都会产生新值，所以需要keychain）
    //: static var systemUUID: String {
    static var systemUUID: String {
        //: let key = KeychainSwift()
        let key = KeychainSwift()
        //: if let value = key.get(AdjustKey) {
        if let value = key.get(managerTransformShowTime) {
            //: return value
            return value
            //: } else {
        } else {
            //: let value = NSUUID().uuidString
            let value = NSUUID().uuidString
            //: key.set(value, forKey: AdjustKey)
            key.set(value, forKey: managerTransformShowTime)
            //: return value
            return value
        }
    }

    /// 获取已安装应用信息
    //: static var getInstalledApps: String {
    static var getInstalledApps: String {
        //: var appsArr: [String] = []
        var appsArr: [String] = []
        //: if UIDevice.canOpenApp("weixin") {
        if UIDevice.visible((dataTopographicPointTime.replacingOccurrences(of: "every", with: "ei"))) {
            //: appsArr.append("weixin")
            appsArr.append((dataTopographicPointTime.replacingOccurrences(of: "every", with: "ei")))
        }
        //: if UIDevice.canOpenApp("wxwork") {
        if UIDevice.visible((helperLabTime.replacingOccurrences(of: "active", with: "rk"))) {
            //: appsArr.append("wxwork")
            appsArr.append((helperLabTime.replacingOccurrences(of: "active", with: "rk")))
        }
        //: if UIDevice.canOpenApp("dingtalk") {
        if UIDevice.visible((String(controllerApplicationPlatformDict))) {
            //: appsArr.append("dingtalk")
            appsArr.append((String(controllerApplicationPlatformDict)))
        }
        //: if UIDevice.canOpenApp("lark") {
        if UIDevice.visible((managerBackKey.replacingOccurrences(of: "to", with: "l"))) {
            //: appsArr.append("lark")
            appsArr.append((managerBackKey.replacingOccurrences(of: "to", with: "l")))
        }
        //: if appsArr.count > 0 {
        if appsArr.count > 0 {
            //: return appsArr.joined(separator: ",")
            return appsArr.joined(separator: ",")
        }
        //: return ""
        return ""
    }

    /// 判断是否安装app
    //: static func canOpenApp(_ scheme: String) -> Bool {
    static func visible(_ scheme: String) -> Bool {
        //: let url = URL(string: "\(scheme)://")!
        let url = URL(string: "\(scheme)://")!
        //: if UIApplication.shared.canOpenURL(url) {
        if UIApplication.shared.canOpenURL(url) {
            //: return true
            return true
        }
        //: return false
        return false
    }

    /// 获取系统语言
    /// - Returns: 国际通用语言Code
    //: @objc public class func getSystemLangCode() -> String {
    @objc public class func drop() -> String {
        //: let language = NSLocale.preferredLanguages.first
        let language = NSLocale.preferredLanguages.first
        //: let array = language?.components(separatedBy: "-")
        let array = language?.components(separatedBy: "-")
        //: return array?.first ?? "en"
        return array?.first ?? "en"
    }
}
