platform :ios, '11.0'

target 'Sapphire' do
  use_frameworks!

  pod 'SwiftLint'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'APIKit'
  pod 'ChameleonFramework/Swift', git: 'https://github.com/ViccAlexander/Chameleon', branch: 'wip/swift4'
  pod 'FontAwesome.swift'
  pod 'Whisper'
  pod 'Charts'
  pod 'MBProgressHUD'

  post_install do |installer|
    swift3_pods = %w(FontAwesome.swift Whisper RxSwift RxCocoa RxDataSources Charts)

    installer.pods_project.targets.each do |target|
      if swift3_pods.include?(target.name)
        target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '3.2'
        end
      end

      target.build_configurations.each do |config|
        config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
        config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
        config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
      end
    end
  end
end
