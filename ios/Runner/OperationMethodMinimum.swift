
//: Declare String Begin

/*: "Net Error, Try again later" :*/
fileprivate let main_coreSecret:[Character] = ["N","e","t"," ","E","r","r","o","r",","," ","T","r","y"," ","a","g","a"]
fileprivate let appListExceptResult:[Character] = ["i","n"," ","l","a","t","e","r"]

/*: "data" :*/
fileprivate let serviceBioLabKey:String = "dagrant"

/*: ":null" :*/
fileprivate let appUnderwayStatus:[Character] = [":","n","u","l","l"]

/*: "json error" :*/
fileprivate let modelAllowPostDate:String = "json element except all"

/*: "platform=iphone&version= :*/
fileprivate let cacheLaterReloadPath:String = "PLATF"
fileprivate let modelSubToolKey:String = "iphocontacte"
fileprivate let managerEmptyBehaviorValue:String = "&veenvironment type native link"
fileprivate let managerFileTitleList:[Character] = ["r","s","i","o","n","="]

/*: &packageId= :*/
fileprivate let appTelephotographBeginID:String = "rich empty&packa"
fileprivate let const_appSystemMessage:String = "compound"

/*: &bundleId= :*/
fileprivate let sessionArrayBlockMode:String = "m dismiss previous offer&bun"
fileprivate let sessionTagMsg:[Character] = ["d","="]

/*: &lang= :*/
fileprivate let parserLaunchName:String = "us ting&lang"
fileprivate let userForwardMessage:[Character] = ["="]

/*: ; build: :*/
fileprivate let configGroundMessage:String = "require region; build"
fileprivate let notiCornerValue:[Character] = [":"]

/*: ; iOS  :*/
fileprivate let user_beforeCenterState:String = "inventory guard extension minimum component; iOS"
fileprivate let app_labelName:String = "instance"

//: Declare String End

//: import Alamofire
import Alamofire
//: import CoreMedia
import CoreMedia
//: import HandyJSON
import HandyJSON
// __DEBUG__
// __CLOSE_PRINT__
//: import UIKit
import UIKit

//: typealias FinishBlock = (_ succeed: Bool, _ result: Any?, _ errorModel: AppErrorResponse?) -> Void
typealias FinishBlock = (_ succeed: Bool, _ result: Any?, _ errorModel: SumerpretComponent?) -> Void

//: @objc class AppRequestTool: NSObject {
@objc class OperationMethodMinimum: NSObject {
    /// 发起Post请求
    /// - Parameters:
    ///   - model: 请求参数
    ///   - completion: 回调
    //: class func startPostRequest(model: AppRequestModel, completion: @escaping FinishBlock) {
    class func goOf(model: CountModel, completion: @escaping FinishBlock) {
        //: let serverUrl = self.buildServerUrl(model: model)
        let serverUrl = self.take(model: model)
        //: let headers = self.getRequestHeader(model: model)
        let headers = self.applicationEvaluate(model: model)
        //: AF.request(serverUrl, method: .post, parameters: model.params, headers: headers, requestModifier: { $0.timeoutInterval = 10.0 }).responseData { [self] responseData in
        AF.request(serverUrl, method: .post, parameters: model.params, headers: headers, requestModifier: { $0.timeoutInterval = 10.0 }).responseData { [self] responseData in
            //: switch responseData.result {
            switch responseData.result {
            //: case .success:
            case .success:
                //: func__requestSucess(model: model, response: responseData.response!, responseData: responseData.data!, completion: completion)
                atReaction(model: model, response: responseData.response!, responseData: responseData.data!, completion: completion)

            //: case .failure:
            case .failure:
                //: completion(false, nil, AppErrorResponse.init(errorCode: RequestResultCode.NetError.rawValue, errorMsg: "Net Error, Try again later"))
                completion(false, nil, SumerpretComponent(errorCode: CycleDiskCheck.NetError.rawValue, errorMsg: (String(main_coreSecret) + String(appListExceptResult))))
            }
        }
    }

    //: class func func__requestSucess(model: AppRequestModel, response: HTTPURLResponse, responseData: Data, completion: @escaping FinishBlock) {
    class func atReaction(model: CountModel, response: HTTPURLResponse, responseData: Data, completion: @escaping FinishBlock) {
        //: var responseJson = String(data: responseData, encoding: .utf8)
        var responseJson = String(data: responseData, encoding: .utf8)
        //: responseJson = responseJson?.replacingOccurrences(of: "\"data\":null", with: "\"data\":{}")
        responseJson = responseJson?.replacingOccurrences(of: "\"" + (serviceBioLabKey.replacingOccurrences(of: "grant", with: "ta")) + "\"" + (String(appUnderwayStatus)), with: "" + "\"" + (serviceBioLabKey.replacingOccurrences(of: "grant", with: "ta")) + "\"" + ":{}")
        //: if let responseModel = JSONDeserializer<AppBaseResponse>.deserializeFrom(json: responseJson) {
        if let responseModel = JSONDeserializer<ChemicalActionPut>.deserializeFrom(json: responseJson) {
            //: if responseModel.errno == RequestResultCode.Normal.rawValue {
            if responseModel.errno == CycleDiskCheck.Normal.rawValue {
                //: completion(true, responseModel.data, nil)
                completion(true, responseModel.data, nil)
                //: } else {
            } else {
                //: completion(false, responseModel.data, AppErrorResponse.init(errorCode: responseModel.errno, errorMsg: responseModel.msg ?? ""))
                completion(false, responseModel.data, SumerpretComponent(errorCode: responseModel.errno, errorMsg: responseModel.msg ?? ""))
                //: switch responseModel.errno {
                switch responseModel.errno {
//                case CycleDiskCheck.NeedReLogin.rawValue:
//                    NotificationCenter.default.post(name: DID_LOGIN_OUT_SUCCESS_NOTIFICATION, object: nil, userInfo: nil)
                //: default:
                default:
                    //: break
                    break
                }
            }
            //: } else {
        } else {
            //: completion(false, nil, AppErrorResponse.init(errorCode: RequestResultCode.NetError.rawValue, errorMsg: "json error"))
            completion(false, nil, SumerpretComponent(errorCode: CycleDiskCheck.NetError.rawValue, errorMsg: (String(modelAllowPostDate.prefix(5)) + "error")))
        }
    }

    //: class func buildServerUrl(model: AppRequestModel) -> String {
    class func take(model: CountModel) -> String {
        //: var serverUrl: String = model.requestServer
        var serverUrl: String = model.requestServer
        //: let otherParams = "platform=iphone&version=\(AppNetVersion)&packageId=\(PackageID)&bundleId=\(AppBundle)&lang=\(UIDevice.interfaceLang)"
        let otherParams = (cacheLaterReloadPath.lowercased() + "orm=" + modelSubToolKey.replacingOccurrences(of: "contact", with: "n") + String(managerEmptyBehaviorValue.prefix(3)) + String(managerFileTitleList)) + "\(networkProcessState)" + (String(appTelephotographBeginID.suffix(6)) + "geId" + const_appSystemMessage.replacingOccurrences(of: "compound", with: "=")) + "\(loggerObjectVersionName)" + (String(sessionArrayBlockMode.suffix(4)) + "dleI" + String(sessionTagMsg)) + "\(configNumberryValue)" + (String(parserLaunchName.suffix(5)) + String(userForwardMessage)) + "\(UIDevice.interfaceLang)"
        //: if !model.requestPath.isEmpty {
        if !model.requestPath.isEmpty {
            //: serverUrl.append("/\(model.requestPath)")
            serverUrl.append("/\(model.requestPath)")
        }
        //: serverUrl.append("?\(otherParams)")
        serverUrl.append("?\(otherParams)")

        //: return serverUrl
        return serverUrl
    }

    /// 获取请求头参数
    /// - Parameter model: 请求模型
    /// - Returns: 请求头参数
    //: class func getRequestHeader(model: AppRequestModel) -> HTTPHeaders {
    class func applicationEvaluate(model: CountModel) -> HTTPHeaders {
        //: let userAgent = "\(AppName)/\(AppVersion) (\(AppBundle); build:\(AppBuildNumber); iOS \(UIDevice.current.systemVersion); \(UIDevice.modelName))"
        let userAgent = "\(sessionOfferMode)/\(formatterWithoutToken) (\(configNumberryValue)" + (String(configGroundMessage.suffix(7)) + String(notiCornerValue)) + "\(data_aroundScaleTitle)" + (String(user_beforeCenterState.suffix(5)) + app_labelName.replacingOccurrences(of: "instance", with: " ")) + "\(UIDevice.current.systemVersion); \(UIDevice.modelName))"
        //: let headers = [HTTPHeader.userAgent(userAgent)]
        let headers = [HTTPHeader.userAgent(userAgent)]
        //: return HTTPHeaders(headers)
        return HTTPHeaders(headers)
    }
}
