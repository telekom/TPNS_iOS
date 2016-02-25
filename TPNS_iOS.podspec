Pod::Spec.new do |spec|
  spec.name                = 'TPNS_iOS'
  spec.version             = '0.7.0'
  spec.license             = 'NONE'
  spec.authors             = { 'Bjoern Richter' => 'b.richter@proventa.de' }
  spec.homepage            = 'http://telekom.de'
  spec.summary             = 'Write me'
  spec.source              = { :git => 'https://group-innovation-hub.wesp.telekom.net/gitlab/TPNS/TPNS_iOS.git', :tag => spec.version }
  spec.requires_arc        = true
  spec.public_header_files = 'TPNS_iOS/DTPushNotification.h'
  spec.source_files        = 'TPNS_iOS/DTPushNotification.*'
end

