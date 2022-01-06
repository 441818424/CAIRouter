//
//  RouterLoader.swift
//  GLUtils
//
//  Created by caijunlai on 2021/11/15.
//

import UIKit

public class RouterLoadInfo {
    var url: String
    var name: String
    var desc = ""
    public init(url: String, name: String) {
        self.url = url
        self.name = name
    }
}

public class RouterLoader: NSObject {

    
    /// 路由的注册和处理
    /// - Parameters:
    ///   - info: 路由信息
    ///   - module: 路由所属模块
    public static func routerLoadInfo(info: RouterLoadInfo, module: String) {
 
        RouterCenter.shared.register(url: info.url) { params in
            
            if let toVc = createToVc(vcName: info.name, namespace: module) {
                if let p = params.userInfo {
                    toVc.routerParams = p
                }
                if let c = params.callBack {
                    toVc.routerCallBack = c
                }
                params.fromVc = UIWindow.routerNormalWindow?.routerTopVc
                params.navVc = UIWindow.routerNormalWindow?.routerTopVc?.routerTopNavVc
                
                if let t = params.tabBarVc {
                    if let s = params.selectIndex {
                        if  t.selectedIndex != s {
                            t.selectedIndex = s
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                RouterLoader.jump(params: params, toVc: toVc)
                            }
                        }else{
                            RouterLoader.jump(params: params, toVc: toVc)
                        }
                    }else{
                        RouterLoader.jump(params: params, toVc: toVc)
                    }
                }else{
                    RouterLoader.jump(params: params, toVc: toVc)
                }
            }else{
                print("\(info.name)目标控制器创建失败")
            }
        }
        
    }
    
    
    /// 路由跳转处理
    /// - Parameters:
    ///   - params: 路由内部参数
    ///   - toVc: 目标控制器
    private static func jump(params: RouterParams, toVc: UIViewController) {
        if let n = params.navVc {
            // 当modal，使用present
            if params.isModal {
                toVc.modalPresentationStyle = .fullScreen
                n.present(toVc, animated: true, completion: nil)
            }else{
                toVc.hidesBottomBarWhenPushed = true
                n.pushViewController(toVc, animated: true)
            }
        }else{
            toVc.modalPresentationStyle = .fullScreen
            UIWindow.routerNormalWindow?.routerTopVc?.present(toVc, animated: true, completion: nil)
        }
    }
    
    
    /// 创建目标控制器
    /// - Parameters:
    ///   - vcName: 目标控制器的名字
    ///   - namespace: 目标控制器的命名空间
    /// - Returns: 目标控制器
    private static func createToVc(vcName: String, namespace: String) -> UIViewController? {
        guard let vcClass = NSClassFromString(namespace + "." + vcName) else {
            print("没有获取到字符串对应的Class")
            return nil
        }

        guard let classType = vcClass as? UIViewController.Type else{
            print("没有获取对应控制器的类型")
            return nil;
        }
       
        return classType.init()
    }
}


extension UIViewController {
    
    private static var kVcRouterParamsAssociateKey: String = "kVcRouterParamsAssociateKey"
    private static var kVcRouterCallBackAssociateKey: String = "kVcRouterCallBackAssociateKey"
    
    /// 路由参数
    public var routerParams: [String: Any]? {
        set {
            objc_setAssociatedObject(self, &UIViewController.kVcRouterParamsAssociateKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let e = objc_getAssociatedObject(self, &UIViewController.kVcRouterParamsAssociateKey) as? [String: Any] {
                return e
            }
            return nil
        }
    }
    
    /// 路由回调
    public var routerCallBack: ((_ params: [String: Any])->())? {
        set {
            objc_setAssociatedObject(self, &UIViewController.kVcRouterCallBackAssociateKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let e = objc_getAssociatedObject(self, &UIViewController.kVcRouterCallBackAssociateKey) as? ((_ params: [String: Any])->()) {
                return e
            }
            return nil
        }
    }
}
