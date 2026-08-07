import UIKit
import CROSSxCoreSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    /// SDK 인스턴스 (MainViewController에서 설정)
    static var sdk: CROSSxSDK?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: MainViewController())
        window?.makeKeyAndVisible()
        return true
    }
    
    // MARK: - URL Handling (OAuth 콜백 수신)
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        if let sdk = AppDelegate.sdk, sdk.handleURL(url) {
            return true
        }
        
        return false
    }
}
