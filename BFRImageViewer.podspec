Pod::Spec.new do |s|
    s.name         = "BFRImageViewer"
    s.version      = "1.0.2"
    s.summary      = "BFRImageViewer."
    s.homepage     = "https://bufferapp.com"
    s.license      = { :type => 'MIT', :file => 'LICENSE' }
    s.author       = { "Andrew Yates" => "andy@bufferapp.com" }
    s.source       = { :git => "https://github.com/bufferapp/buffer-ios-image-viewer.git", :tag => 'v1.0.2'  }
    s.source_files = 'Classes', 'BFRImageViewController/**/*.{h,m}'
    s.platform     = :ios, '8.0'
    s.requires_arc = true
    s.dependency 'DACircularProgress'
    s.dependency 'AFNetworking'
end
