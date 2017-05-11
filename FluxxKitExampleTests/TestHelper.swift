final class TestHelper {

  typealias JSON = [String: Any]

  static func load(json name: String) -> JSON {
    guard
        let pathString = Bundle(for: self).path(forResource: name, ofType: "json"),
        let jsonString = try? NSString(contentsOfFile: pathString, encoding: String.Encoding.utf8.rawValue),
        let jsonData = jsonString.data(using: String.Encoding.utf8.rawValue),
        let json = (try? JSONSerialization.jsonObject(with: jsonData, options: [])) as? JSON
        else {
      fatalError("something wrong")
    }

    return json
  }

  static func wait(for seconds: TimeInterval, view: UIView? = nil, postWait: TimeInterval = 0.5) {
    let date = Date(timeIntervalSinceNow: seconds)
    RunLoop.current.run(until: date)
    if let view = view {
      view.layoutIfNeeded()
      RunLoop.current.run(until: Date(timeIntervalSinceNow: postWait))
    }
  }

  static let error = TestError()
  struct TestError: Error {
  }
}
