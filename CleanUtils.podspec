Pod::Spec.new do |s|
    s.name             = 'CleanUtils'
    s.version          = '0.1.0'
    s.summary          = 'Swift toolkit to help building simple and clean viewModels with states handling using RxSwift'
    s.homepage         = 'https://github.com/Tonbouy/CleanUtils'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }

    s.author           = { 'Tonbouy' => 'nicolas.ribeiroteixeira@gmail.com' }

    s.source           = { :git => 'https://github.com/Tonbouy/CleanUtils.git', :tag => "v#{s.version.to_s}" }

    s.source_files = 'CleanUtils/Classes/**/*'

    s.ios.deployment_target  = '10.0'
    s.swift_version = "4.2"

    s.frameworks = 'UIKit', 'Foundation'
    s.dependency 'RxSwift'
    s.dependency 'RxCocoa'
end
