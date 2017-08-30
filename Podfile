platform :ios, '11.0'

target 'Sapphire' do
  use_frameworks!

  pod 'SwiftLint'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'APIKit'
  pod 'ChameleonFramework/Swift', git: 'https://github.com/ViccAlexander/Chameleon', branch: 'wip/swift4'
  pod 'FontAwesome.swift'
  pod 'Whisper'
  pod 'Eureka', git: 'https://github.com/xmartlabs/Eureka', branch: 'feature/Xcode9-Swift4'

  post_install do |installer|
      swift3_pods = %w(FontAwesome.swift Whisper RxSwift RxCocoa)

      installer.pods_project.targets.each do |target|
          if swift3_pods.include?(target.name)
              target.build_configurations.each do |config|
                  config.build_settings['SWIFT_VERSION'] = '3.2'
              end
          end
      end
  end
end
