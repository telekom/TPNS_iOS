Pod::Spec.new do |spec|
  spec.name                = 'TPNS_iOS'
  spec.version             = '0.9.2'
  spec.license             = 'MIT'
  spec.authors             = { 'Deutsche Telekom AG' => 'tpns@telekom.de' }
  spec.homepage            = 'http://telekom.de'
  spec.summary             = 'TPNS_iOS is a library to simplify the device registration and unregistration with Telekom Push Notification Service (TPNS).'
  spec.source              = { :git => 'https://github.com/dtag-dbu/TPNS_iOS.git', :tag => spec.version }
  spec.requires_arc        = true
  spec.public_header_files = 'TPNS_iOS/DTPushNotification.h'
  spec.source_files        = 'TPNS_iOS/DTPushNotification.*'
end
