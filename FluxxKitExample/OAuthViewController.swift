import UIKit
import WebKit
import RxSwift

final class OAuthViewController: UIViewController {

  var webView: WKWebView = WKWebView()
  let oAuthState = NSUUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
  let clientId = "57e837fb225048c286c07d06bd236631"
  let redirectTo =
    "https://github.com/keitaoouchi/FluxxKitExample"
      .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
}

// MARK: - Lifecycles
extension OAuthViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    fill(view, with: webView)
    webView.navigationDelegate = self
    let urlStr = "https://accounts.spotify.com/authorize?" +
                 "client_id=\(clientId)&" +
                 "response_type=token&" +
                 "redirect_uri=\(redirectTo)&" +
                 "state=\(oAuthState)"
    let url = URL(string: urlStr)!
    let request = URLRequest(url: url)
    webView.load(request)
  }
}

// MARK: WKNavigationDelegate
extension OAuthViewController: WKNavigationDelegate {

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    if let url = webView.url,
      url.host == "github.com" &&
      url.absoluteString.contains("state=\(oAuthState)") {
      self.processResponse(url: url)
    }
  }

}

// MARK: Private
private extension OAuthViewController {

  func fill(_ container: UIView, with childView: UIView) {
    childView.backgroundColor = UIColor.white
    view.backgroundColor = childView.backgroundColor
    childView.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(childView)
    childView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
    childView.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
    childView.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
    childView.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
  }

  func processResponse(url: URL) {
    var items = [String: String]()
    url
      .fragment?
      .components(separatedBy: "&")
      .map { $0.components(separatedBy: "=") }
      .forEach { keyValue in
        if let key = keyValue.first, let value = keyValue.last {
          items[key] = value
        }
      }
    if let token = items["access_token"],
       let expiresStr = items["expires_in"],
       let expiresIn = Double(expiresStr) {
      let expiresSince1970 = Date().timeIntervalSince1970 + expiresIn
      Authentication.shared.accessToken = token
      Authentication.shared.expiresIn = expiresSince1970
      self.dismiss(animated: true, completion: nil)
    }
  }
}
