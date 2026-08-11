require 'xcodeproj'

project_path = File.expand_path('../ios/Runner.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)
runner = project.targets.find { |target| target.name == 'Runner' }
abort('Runner target not found') unless runner

runner_group = project.main_group.find_subpath('Runner', true)
intent_ref = runner_group.files.find { |file| file.path == 'PlaybackIntents.swift' }
intent_ref ||= runner_group.new_file('PlaybackIntents.swift')
unless runner.source_build_phase.files_references.include?(intent_ref)
  runner.source_build_phase.add_file_reference(intent_ref, true)
end

runner.build_configurations.each do |configuration|
  configuration.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
  configuration.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] =
    configuration.name.include?('Test') ? 'com.alpwarestudio.frekio.RunnerTests' : 'com.alpwarestudio.frekio'
end

widget = project.targets.find { |target| target.name == 'FrekioWidgetExtension' }
widget_group = project.main_group.find_subpath('FrekioWidget', true)
widget_group.path = 'FrekioWidget'
unless widget
  widget = project.new_target(:app_extension, 'FrekioWidgetExtension', :ios, '17.0')
  widget_source = widget_group.new_file('FrekioWidget.swift')
  widget.source_build_phase.add_file_reference(widget_source, true)
  widget.source_build_phase.add_file_reference(intent_ref, true)

  runner.add_dependency(widget)
  embed_phase = runner.new_copy_files_build_phase('Embed App Extensions')
  embed_phase.symbol_dst_subfolder_spec = :plug_ins
  embed_file = embed_phase.add_file_reference(widget.product_reference, true)
  embed_file.settings = { 'ATTRIBUTES' => %w[CodeSignOnCopy RemoveHeadersOnCopy] }
end

# Flutter's Thin Binary phase declares Runner.app outputs. Embed the extension
# first to avoid Xcode's Info.plist metadata dependency cycle.
embed_phase = runner.build_phases.find { |phase| phase.display_name == 'Embed App Extensions' }
thin_index = runner.build_phases.index { |phase| phase.display_name == 'Thin Binary' }
if embed_phase && thin_index
  runner.build_phases.delete(embed_phase)
  runner.build_phases.insert(thin_index, embed_phase)
end

runner_team = runner.build_configurations.first.build_settings['DEVELOPMENT_TEAM']
widget.build_configurations.each do |configuration|
  settings = configuration.build_settings
  settings['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
  settings['CODE_SIGN_ENTITLEMENTS'] = 'FrekioWidget/FrekioWidget.entitlements'
  settings['CURRENT_PROJECT_VERSION'] = '4'
  settings['GENERATE_INFOPLIST_FILE'] = 'NO'
  settings['INFOPLIST_FILE'] = 'FrekioWidget/Info.plist'
  settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
  settings['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks'
  settings['MARKETING_VERSION'] = '1.3.0'
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.alpwarestudio.frekio.widget'
  settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  settings['SKIP_INSTALL'] = 'YES'
  settings['SWIFT_EMIT_LOC_STRINGS'] = 'YES'
  settings['SWIFT_VERSION'] = '5.0'
  settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  settings['DEVELOPMENT_TEAM'] = runner_team if runner_team
end

project.save
puts 'Configured the FrekioWidgetExtension target and App Group entitlements.'
