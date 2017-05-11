import UIKit

extension UIView {
  func fill(with childView: UIView?) {
    guard let childView = childView else {
      return
    }
    self.subviews.forEach { (subView) in
      subView.removeFromSuperview()
    }

    childView.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(childView)
    childView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    childView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    childView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    childView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
  }

  func clone() -> UIView? {
    return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as? UIView
  }
}
