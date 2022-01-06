//
//  RouterCenter.swift
//  GLUtils
//
//  Created by caijunlai on 2021/11/15.
//

import UIKit

/// 路由注册信息
public class RegisterInfo {
    var registerUrl: String
    var params: RouterParams = RouterParams()
    var toHandle: ((RouterParams) -> ())?
    
    init(url: String) {
        self.registerUrl = url
    }
    
}


/// 路由参数
public class RouterParams {
    var openUrl = ""
    var userInfo: [String: Any]?
    var tabBarVc: UITabBarController?
    var selectIndex: Int?
    var navVc: UINavigationController?
    var fromVc: UIViewController?
    var toVc: UIViewController?
    var isModal = false
    var callBack: (([String: Any]) -> ())?
    var isWeb = false
    
   required init() {}
}

public let kRouterWebURLString = "http(s)://router/web/default"
public let kRouterWebURLKey = "router.webURL"

public class RouterCenter: NSObject {

    public static let shared = RouterCenter()
 
    lazy var registerInfos: [String: RegisterInfo] = {
        return [String: RegisterInfo]()
    }()
    
    
    /// 注册路由
    /// - Parameters:
    ///   - url: 路由链接
    ///   - toHandle: 路由处理block
    /// - Returns: 路由处理返回空
    public func register(url: String, toHandle:((RouterParams)->())?) {
        if registerInfos[url] != nil {
            print("\(url)已经注册，请勿重复注册")
            return
        }
        let registerInfo = RegisterInfo(url: url)
        if (toHandle != nil) {
            registerInfo.toHandle = toHandle
        }
       
        registerInfos[url] = registerInfo
    }
    
    
    /// 清除路由
    /// - Parameter url: 路由链接
    public func unregister(url: String) {
        registerInfos.removeValue(forKey: url)
        
    }
    
    
    /// 路由跳转
    /// - Parameter url: 路由链接
    public func openURL(url: String) {
        openURL(url: url, userInfo: nil, callBack: nil, selectIndex: nil, modal: false)
    }
    
    
    /// 路由跳转
    /// - Parameters:
    ///   - url: 路由链接
    ///   - selectIndex: 路由tabbar选中索引
    public func openURL(url: String, selectIndex: Int) {
        openURL(url: url, userInfo: nil, callBack: nil, selectIndex: selectIndex, modal: false)
    }
    
    
    /// 路由跳转
    /// - Parameters:
    ///   - url: 路由链接
    ///   - userInfo: 路由参数
    public func openURL(url: String, userInfo: [String: Any]?) {
        openURL(url: url, userInfo: userInfo, callBack: nil, selectIndex: nil, modal: false)
    }
    
    
    /// 路由跳转
    /// - Parameters:
    ///   - url: 路由链接
    ///   - userInfo: 路由参数
    ///   - callBack: 路由回调block
    /// - Returns: 路由回调返回空
    public func openURL(url: String, userInfo: [String: Any]?, callBack: (([String: Any]) -> ())?) {
        openURL(url: url, userInfo: userInfo, callBack: callBack, selectIndex: nil, modal: false)
    }
    
    
    /// 路由跳转
    /// - Parameters:
    ///   - url: 路由链接
    ///   - modal: 路由是否present
    public func openURL(url: String, modal: Bool?) {
        openURL(url: url, userInfo: nil, callBack: nil, selectIndex: nil, modal: modal)
    }
    
    
    /// 路由跳转
    /// - Parameters:
    ///   - url: 路由链接
    ///   - userInfo: 路由参数
    ///   - callBack: 路由回调block
    ///   - selectIndex: 路由tabbar选中索引
    ///   - modal: 路由是否present
    public func openURL(url: String, userInfo: [String: Any]?, callBack: (([String: Any]) -> ())?, selectIndex: Int?, modal: Bool?) {

        var registerInfo: RegisterInfo?
        if url.contains("?") {
            let arr = url.split(separator: "?").compactMap{ "\($0)" }
            if arr.count <= 2 {
                registerInfo = self.registerInfos[arr.first ?? ""]
            }else{
                print("url解析错误")
                return
            }
        }else{
            registerInfo = self.registerInfos[url]
        }

        if registerInfo == nil {
            if url.hasPrefix("http") {
                registerInfo = self.registerInfos[kRouterWebURLString]
                registerInfo?.params.isWeb = true
                if registerInfo == nil {
                    print("您还没注册web对应的控制器")
                    return
                }
            }else{
                print("\(url)没有注册")
                return
            }
        }
     
        var allParams = [String: Any]()
        if let kv = urlParams(url: url) {
            for (k,v) in kv {
                allParams[k] = v
            }
        }
        
        if let u = userInfo {
            for (k,v) in u {
                allParams[k] = v
            }
        }
        
        if registerInfo?.params.isWeb ?? false {
            allParams[kRouterWebURLKey] = url
        }
        
        let fromVc = UIWindow.routerNormalWindow?.routerTopVc
        let navVc = UIWindow.routerNormalWindow?.routerTopVc?.routerTopNavVc
        
        
        registerInfo?.params.openUrl = url
        registerInfo?.params.userInfo = allParams
        registerInfo?.params.fromVc = fromVc
        registerInfo?.params.navVc = navVc
        
        if let c = callBack {
            registerInfo?.params.callBack = c
        }
        
        if let t = fromVc?.tabBarController {
            registerInfo?.params.tabBarVc = t
            if let s = selectIndex {
                registerInfo?.params.selectIndex = s
            }else{
                registerInfo?.params.selectIndex = t.selectedIndex
            }
        }
        
        if let m = modal {
            registerInfo?.params.isModal = m
        }else{
            registerInfo?.params.isModal = false
        }
        
        if let handle = registerInfo?.toHandle {
            handle(registerInfo?.params ?? RouterParams())
        }
        
    }
    
    
    /// 路由链接参数解析
    /// - Parameter url: 路由链接
    /// - Returns: 路由参数
    private func urlParams(url: String) -> [String: Any]? {
        
        var keyValues : [String: Any] = [String: Any]()
        
        let arr = url.split(separator: "?").compactMap{ "\($0)" }
        if arr.count == 2 {
            let urlParamsStr = arr.last
            let arrParams = urlParamsStr?.split(separator: "&").compactMap{ "\($0)" }
            
            if arrParams?.count ?? 0 > 0 {
                for keyValue in arrParams! {
                    let keyValueArr = keyValue.split(separator: "=").compactMap{ "\($0)" }
                    if keyValueArr.count == 2 {
                        keyValues[(keyValueArr.first)!] = keyValueArr.last
                    }else{
                        return nil
                    }
                }
            }else{
                return nil
            }
        }else{
            return nil
        }
        
        return keyValues
    }
    
}


extension UIWindow {
    
    /// 当前的window
    public static var routerNormalWindow: UIWindow? {
        if let keyWindow = UIApplication.shared.keyWindow {
            if keyWindow.windowLevel == UIWindowLevelNormal {
                return keyWindow
            } else {
                for window in UIApplication.shared.windows {
                    if window.windowLevel == UIWindowLevelNormal {
                        return window
                    }
                }
            }
        }
        return nil
    }

    /// 当前的顶部控制器
    public var routerTopVc: UIViewController? {
        return rootViewController?.routerTopVc
    }
    
}


extension UIViewController {
    
    /// 当前的顶部导航控制器
    public var routerTopNavVc: UINavigationController? {
        var next: UIViewController? = self
        var nav: UINavigationController? = next?.navigationController
        while nav == nil && next != nil {
            next = next?.parent
            nav = next?.navigationController
        }
        return nav
    }
    
    /// 当前的顶部控制器
    public var routerTopVc: UIViewController? {
        if let vc = self as? UITabBarController {
            return vc.selectedViewController?.routerTopVc
        } else if let vc = self as? UINavigationController {
            return vc.visibleViewController?.routerTopVc
        } else if let vc = self.presentedViewController {
            return vc.routerTopVc
        }
        return self
    }
    
}
