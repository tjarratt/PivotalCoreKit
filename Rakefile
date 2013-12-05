require 'tmpdir'

CONFIGURATION = "Release"
SDK_VERSION = "6.1"
BUILD_DIR = File.join(File.dirname(__FILE__), "build")

# Xcode 4.3 stores its /Developer inside /Applications/Xcode.app, Xcode 4.2 stored it in /Developer
def xcode_developer_dir
  `xcode-select -print-path`.strip
end

def sdk_dir
  "#{xcode_developer_dir}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator#{SDK_VERSION}.sdk"
end

def build_dir(effective_platform_name)
  File.join(BUILD_DIR, CONFIGURATION + effective_platform_name)
end

def system_or_exit(cmd, env_overrides = {}, stdout = nil)
  puts "Executing #{cmd}"
  cmd += " >#{stdout}" if stdout

  old_env = {}
  env_overrides.each do |key, value|
    old_env[key] = ENV[key]
    ENV[key] = value
  end

  system(cmd) or begin
    puts "******** Build failed ********"
    exit(1)
  end

  env_overrides.each do |key, value|
    ENV[key] = old_env[key]
  end
end

def output_file(target)
  output_dir = if ENV['IS_CI_BOX']
    ENV['CC_BUILD_ARTIFACTS']
  else
    build_dir = File.join(File.dirname(__FILE__), "build")
    Dir.mkdir(build_dir) unless File.exists?(build_dir)
    build_dir
  end

  output_file = File.join(output_dir, "#{target}.output")
  puts "Output: #{output_file}"
  output_file
end

task :default => [:trim_whitespace, "all:spec"]
task :cruise => ["all:clean", "all:build", "all:spec"]

desc 'remove whitespace'
task :trim_whitespace do
  system_or_exit(%Q[git status --short | awk '{if ($1 != "D" && $1 != "R") print $2}' | grep -e '.*\.[mh]$' | xargs sed -i '' -e 's/	/    /g;s/ *$//g;'])
end

namespace :foundation do
  project_name = "Foundation/Foundation"

  namespace :build do
    namespace :core do
      desc 'build core Foundation+PCK for OS X'
      task :osx do
        system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target Foundation+PivotalCore -configuration #{CONFIGURATION} build SYMROOT=#{BUILD_DIR}], {}, output_file("foundation:build:core:osx"))
      end

      desc 'build core Foundation+PCK for iOS'
      task :ios do
        system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target Foundation+PivotalCore-StaticLib -configuration #{CONFIGURATION} ARCHS=i386 -sdk iphonesimulator build SYMROOT=#{BUILD_DIR}], {}, output_file("foundation:build:core:ios"))
      end
    end

    desc 'build core Foundation+PCK'
    task :core => ["core:osx", "core:ios"]

    namespace :spec_helper do
      desc 'build spec helper for Foundation+PCK OS X'
      task :osx do
        system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target Foundation+PivotalSpecHelper -configuration #{CONFIGURATION} build SYMROOT=#{BUILD_DIR}], {}, output_file("foundation:build:spec_helper:osx"))
      end

      desc 'build spec helper for Foundation+PCK iOS'
      task :ios do
        system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target Foundation+PivotalSpecHelper-StaticLib -configuration #{CONFIGURATION} ARCHS=i386 -sdk iphonesimulator build SYMROOT=#{BUILD_DIR}], {}, output_file("foundation:build:spec_helper:ios"))
      end
    end

    desc 'build spec helper for Foundation+PCK'
    task :spec_helper => ["spec_helper:osx", "spec_helper:ios"]

    namespace :spec_helper_framework do
      desc 'build spec helper framework for Foundation+PCK iOS'
      task :ios do
        system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target Foundation+PivotalSpecHelper-iOS -configuration #{CONFIGURATION} build SYMROOT=#{BUILD_DIR}], {}, output_file("foundation:build:spec_helper_framework:ios"))
      end
    end

    task :spec_helper_framework => ["spec_helper_framework:ios"]
  end

  namespace :spec do
    desc 'build and run specs for Foundation+PCK OS X'
    task :osx => ["build:core:osx", "build:spec_helper:osx"] do
      system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target FoundationSpec -configuration #{CONFIGURATION} build SYMROOT=#{BUILD_DIR}], {}, output_file("foundation:spec:osx"))

      build_dir = build_dir("")
      env_vars = {
        "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
        "IPHONE_SIMULATOR_ROOT" => sdk_dir,
        "CFFIXED_USER_HOME" => Dir.tmpdir,
        "DYLD_FRAMEWORK_PATH" => build_dir
      }
      system_or_exit("cd #{build_dir}; ./FoundationSpec", env_vars)
    end

    desc 'build and run specs for Foundation+PCK iOS'
    task :ios => ["build:core:ios", "build:spec_helper:ios"] do
      system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target Foundation-StaticLibSpec -configuration #{CONFIGURATION} ARCHS=i386 -sdk iphonesimulator build SYMROOT=#{BUILD_DIR}], {}, output_file("foundation:spec:ios"))

      `osascript -e 'tell application "iPhone Simulator" to quit'`
      env_vars = {
        "DYLD_ROOT_PATH" => sdk_dir,
        "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
        "IPHONE_SIMULATOR_ROOT" => sdk_dir,
        "CFFIXED_USER_HOME" => Dir.tmpdir,
        "CEDAR_HEADLESS_SPECS" => "1"
      }
      system_or_exit(%Q[#{File.join(build_dir("-iphonesimulator"), "Foundation-StaticLibSpec.app", "Foundation-StaticLibSpec")} -RegisterForSystemEvents], env_vars)
      `osascript -e 'tell application "iPhone Simulator" to quit'`
    end
  end

  task :build => ["foundation:build:core", "foundation:build:spec_helper"]
  task :spec => ["foundation:spec:osx", "foundation:spec:ios"]
  task :clean do
    system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -alltargets -configuration #{CONFIGURATION} clean SYMROOT=#{BUILD_DIR}], output_file("foundation:clean"))
  end

  desc 'Build Foundation+PCK and run specs'
  task :foundation => ["foundation:build", "foundation:spec"]
end

namespace :uikit do
  project_name = "UIKit/UIKit"

  namespace :build do
    namespace :core do
      desc 'build core UIKit+PCK'
      task :ios do
        system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target UIKit+PivotalCore-StaticLib -configuration #{CONFIGURATION} ARCHS=i386 -sdk iphonesimulator build SYMROOT=#{BUILD_DIR}], {}, output_file("uikit:build:core:ios"))
      end
    end

    task :core => ["core:ios"]

    namespace :spec_helper do
      desc 'build spec helper for UIKit+PCK'
      task :ios do
        system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target UIKit+PivotalSpecHelper-StaticLib -configuration #{CONFIGURATION} ARCHS=i386 -sdk iphonesimulator build SYMROOT=#{BUILD_DIR}], {}, output_file("uikit:build:spec_helper:ios"))
      end

      desc 'build stubs for UIKit+PCK'
      task :ios_stubs do
        system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target UIKit+PivotalSpecHelperStubs-StaticLib -configuration #{CONFIGURATION} ARCHS=i386 -sdk iphonesimulator build SYMROOT=#{BUILD_DIR}], {}, output_file("uikit:build:spec_helper:ios_stubs"))
      end
    end

    task :spec_helper => ["spec_helper:ios", "spec_helper:ios_stubs"]

    namespace :spec_helper_framework do
      task :ios do
        system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target UIKit+PivotalSpecHelper-iOS -configuration #{CONFIGURATION} build SYMROOT=#{BUILD_DIR}], {}, output_file("uikit:build:spec_helper_framework:ios"))
      end

      task :ios_stubs do
        system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target UIKit+PivotalSpecHelperStubs-iOS -configuration #{CONFIGURATION} build SYMROOT=#{BUILD_DIR}], {}, output_file("uikit:build:spec_helper_framework:ios_stubs"))
      end
    end

    task :spec_helper_framework => ["spec_helper_framework:ios", "spec_helper_framework:ios_stubs"]
  end

  namespace :spec do
    desc 'build and run specs for UIKit+PCK'
    task :ios => ["build:core:ios", "build:spec_helper:ios", "build:spec_helper:ios_stubs"] do
      system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target UIKit-StaticLibSpec -configuration #{CONFIGURATION} ARCHS=i386 -sdk iphonesimulator build SYMROOT=#{BUILD_DIR}], {}, output_file("uikit:spec:ios"))
      `osascript -e 'tell application "iPhone Simulator" to quit'`
      env_vars = {
        "DYLD_ROOT_PATH" => sdk_dir,
        "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
        "IPHONE_SIMULATOR_ROOT" => sdk_dir,
        "CFFIXED_USER_HOME" => Dir.tmpdir,
        "CEDAR_HEADLESS_SPECS" => "1"
      }
      system_or_exit(%Q[#{File.join(build_dir("-iphonesimulator"), "UIKit-StaticLibSpec.app", "UIKit-StaticLibSpec")} -RegisterForSystemEvents], env_vars);
      `osascript -e 'tell application "iPhone Simulator" to quit'`
    end
  end

  task :build => ["build:core"]
  task :spec => ["spec:ios"]
  task :clean do
    system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -alltargets -configuration #{CONFIGURATION} clean SYMROOT=#{BUILD_DIR}], output_file("uikit:clean"))
  end
end

desc 'build UIKit+PCK and run specs'
task :uikit => ["uikit:build", "uikit:spec"]

namespace :core_location do
  project_name = "CoreLocation/CoreLocation"

  namespace :build do
    namespace :spec_helper do
      desc 'build spec_helper for CoreLocation+PCK OS X'
      task :osx do
        system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target CoreLocation+PivotalSpecHelper -configuration #{CONFIGURATION} build SYMROOT=#{BUILD_DIR}], {}, output_file("core_location:build:spec_helper:osx"))
      end

      task :ios do
        desc 'build spec_helper for CoreLocation+PCK iOS'
        system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target CoreLocation+PivotalSpecHelper-StaticLib -configuration #{CONFIGURATION} ARCHS=i386 -sdk iphonesimulator build SYMROOT=#{BUILD_DIR}], {}, output_file("core_location:build:spec_helper:ios"))
      end
    end

    task :spec_helper => ["spec_helper:osx", "spec_helper:ios"]
  end

  namespace :spec do
    desc 'run specs for CoreLocation+PCK OS X'
    task :osx => ["build:spec_helper:osx"] do
      system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target CoreLocationSpec -configuration #{CONFIGURATION} build SYMROOT=#{BUILD_DIR}], {}, output_file("core_location:spec:osx"))

      build_dir = build_dir("")
      env_vars = {
        "DYLD_FRAMEWORK_PATH" => build_dir,
        "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter"
      }
      system_or_exit("cd #{build_dir}; ./CoreLocationSpec", env_vars)
    end

    desc 'run specs for CoreLocation+PCK iOS'
    task :ios => ["build:spec_helper:ios"] do
      system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target CoreLocation-StaticLibSpec -configuration #{CONFIGURATION} ARCHS=i386 -sdk iphonesimulator build SYMROOT=#{BUILD_DIR}], {}, output_file("core_location:spec:ios"))
      `osascript -e 'tell application "iPhone Simulator" to quit'`
      env_vars = {
        "DYLD_ROOT_PATH" => sdk_dir,
        "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
        "IPHONE_SIMULATOR_ROOT" => sdk_dir,
        "CFFIXED_USER_HOME" => Dir.tmpdir,
        "CEDAR_HEADLESS_SPECS" => "1"
      }
      system_or_exit(%Q[#{File.join(build_dir("-iphonesimulator"), "CoreLocation-StaticLibSpec.app", "CoreLocation-StaticLibSpec")} -RegisterForSystemEvents], env_vars);
      `osascript -e 'tell application "iPhone Simulator" to quit'`
    end
  end

  task :build => ["build:spec_helper"]
  task :spec => ["spec:osx", "spec:ios"]
  task :clean do
    system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -alltargets -configuration #{CONFIGURATION} clean SYMROOT=#{BUILD_DIR}], {}, output_file("core_location:clean"))
  end
end

namespace :parsers do
  project_name = 'Parsers/Parsers'

  namespace :build do
    desc 'build Parsers+PCK for OS X'
    task :osx do
      system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target Parsers+PivotalCore -configuration #{CONFIGURATION} build SYMROOT=#{BUILD_DIR}], {}, output_file("parsers:build:core:osx"))
    end

    desc 'build Parsers+PCK for iOS'
    task :ios do
      system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target Parsers+PivotalCore-StaticLib -configuration #{CONFIGURATION} ARCHS=i386 -sdk iphonesimulator build SYMROOT=#{BUILD_DIR}], {}, output_file("parsers:core:ios"))
    end
  end

  namespace :spec do
    desc 'run specs for Parsers+PCK OS X'
    task :osx do
      system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target ParsersSpec -configuration #{CONFIGURATION} build SYMROOT=#{BUILD_DIR}], {}, output_file("parsers:spec:osx"))

      build_dir = build_dir("")
      env_vars = {
        "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
        "IPHONE_SIMULATOR_ROOT" => sdk_dir,
        "CFFIXED_USER_HOME" => Dir.tmpdir,
        "DYLD_FRAMEWORK_PATH" => build_dir
      }
      system_or_exit("cd #{build_dir}; ./ParsersSpec", env_vars)
    end

    desc 'run specs for Parsers+PCK iOS'
    task :ios do
      system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -target Parsers-StaticLibSpec -configuration #{CONFIGURATION} ARCHS=i386 -sdk iphonesimulator build SYMROOT=#{BUILD_DIR}], {}, output_file("parsers:spec:ios"))

      `osascript -e 'tell application "iPhone Simulator" to quit'`
      env_vars = {
        "DYLD_ROOT_PATH" => sdk_dir,
        "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
        "IPHONE_SIMULATOR_ROOT" => sdk_dir,
        "CFFIXED_USER_HOME" => Dir.tmpdir,
        "CEDAR_HEADLESS_SPECS" => "1"
      }
      system_or_exit(%Q[#{File.join(build_dir("-iphonesimulator"), "Parsers-StaticLibSpec.app", "Parsers-StaticLibSpec")} -RegisterForSystemEvents], env_vars)
      `osascript -e 'tell application "iPhone Simulator" to quit'`
    end
  end

  task :build => ['build:osx', 'build:ios']
  task :spec => ['spec:osx', 'spec:ios']
  task :clean do
    system_or_exit(%Q[xcodebuild -project #{project_name}.xcodeproj -alltargets -configuration #{CONFIGURATION} clean SYMROOT=#{BUILD_DIR}], output_file("parsers:clean"))
  end
end

desc 'build CoreLocation+PCK and run specs'
task :core_location => ["core_location:build", "core_location:spec"]

namespace :all do
  desc 'build all the projects'
  task :build => ["foundation:build", "uikit:build", "core_location:build", "parsers:build"]

  desc 'run all the specs'
  task :spec => ["foundation:spec", "uikit:spec", "core_location:spec", "parsers:spec"]

  desc 'clean all of the projects'
  task :clean => ["foundation:clean", "uikit:clean", "core_location:clean", "parsers:clean"]
end
