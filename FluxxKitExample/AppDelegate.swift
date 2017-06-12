import UIKit
import FluxxKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    registerMiddlewares()
    try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)

    return true
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    if !Authentication.shared.isValid() {
      Authentication.shared.invalidate()
    }
  }

}

private extension AppDelegate {
  func registerMiddlewares() {
    let middlewares: [MiddlewareType] = [
        SearchViewModel.SearchMiddleware(),
        AlbumDetailViewModel.AsyncMiddleware(),
        ArtistDetailViewModel.AsyncMiddleware()
    ]
    middlewares.forEach { middleware in
      Dispatcher.shared.register(middleware: middleware)
    }

  }
}
