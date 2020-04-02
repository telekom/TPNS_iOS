Pod::Spec.new do |spec|
  spec.name                = 'TPNS_iOS'
  spec.version             = '1.1.1'
  spec.license             = 'MIT'
  spec.authors             = { 'Deutsche Telekom AG' => 'tpns@telekom.de' }
  spec.homepage            = 'https://www.telekom.de'
  spec.summary             = 'TPNS_iOS is a library to simplify the device registration and unregistration with Telekom Push Notification Service (TPNS).'
  spec.source              = { :git => 'https://github.com/dtag-dbu/TPNS_iOS.git', :tag => spec.version }
  spec.requires_arc        = true
  spec.source_files        = 'TPNS_iOS/*.{h,m}'
  spec.frameworks          = 'UIKit', 'Foundation'
  spec.platform            = :ios
end
