platform :ios, '10.0'
use_frameworks!

target 'FluxxKitExample' do
  pod 'SwiftLint', '~> 0.17'
  pod 'R.swift'
  pod 'FluxxKit', git: 'https://github.com/keitaoouchi/FluxxKit.git'
  pod 'RxSwift'
  pod 'RxCocoa'

  target 'FluxxKitExampleTests' do
    inherit! :search_paths

    pod 'FBSnapshotTestCase'
    pod 'Nimble-Snapshots'
    pod 'Quick'
    pod 'Nimble'
  end

end