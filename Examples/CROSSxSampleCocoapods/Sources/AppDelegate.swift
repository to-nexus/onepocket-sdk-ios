import UIKit
import CROSSxCoreSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
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
