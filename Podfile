# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

install! 'cocoapods',
         :warn_for_unused_master_specs_repo => false,
         :deterministic_uuids => false

target 'Gida Kurdu' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Gida Kurdu
  
  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
    
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      end
    end
  end
end 
