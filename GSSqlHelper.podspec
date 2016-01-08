#GSSqlHelper.podspec
Pod::Spec.new do |s|
  s.name         = "GSSqlHelper"
  s.version      = "0.1.0"
  s.summary      = "a sqlite helper class that like SQLiteHelper in Android"

  s.homepage     = "https://github.com/gscool/GSSqlHelper"
  s.license      = 'MIT'
  s.author       = { "gscool" => "gscool@163.com" }
  s.platform     = :ios, "7.0"
  s.ios.deployment_target = "7.0"
  s.source       = { :git => "https://github.com/gscool/GSSqlHelper.git", :tag => s.version}
  s.source_files  = 'GSSqlHelper/*.{h,m}'
  s.requires_arc = true
  
  s.dependency 'FMDB'
end