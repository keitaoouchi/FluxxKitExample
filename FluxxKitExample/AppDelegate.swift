import UIKit
import FluxxKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    registerMiddlewares()

    return true
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
