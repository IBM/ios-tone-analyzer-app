# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'toneanalyzerios' do
    pod 'BMSCore', '~> 2.0'

    # Comment this line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!

    # Pods for toneanalyzerios
    pod "SwiftSpinner", '~> 1.5.0'
    pod 'KTCenterFlowLayout', '~> 1.3.1'

    post_install do |installer|
        installer.pods_project.targets.each do |target|
            if ['SwiftSpinner', 'SwiftCloudant', 'KTCenterFlowLayout'].include? target.name
                target.build_configurations.each do |config|
                    config.build_settings['SWIFT_VERSION'] = '3.2'
                end
            end
        end
    end

    target 'toneanalyzeriosTests' do
        inherit! :search_paths
        # Pods for testing
    end

    target 'toneanalyzeriosUITests' do
        inherit! :search_paths
        # Pods for testing
    end

end
