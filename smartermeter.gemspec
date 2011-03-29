## This is the rakegem gemspec template. Make sure you read and understand
## all of the comments. Some sections require modification, and others can
## be deleted if you don't need them. Once you understand the contents of
## this file, feel free to delete any comments that begin with two hash marks.
## You can find comprehensive Gem::Specification documentation, at
## http://docs.rubygems.org/read/chapter/20
Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  ## Leave these as is they will be modified for you by the rake gemspec task.
  ## If your rubyforge_project name is different, then edit it and comment out
  ## the sub! line in the Rakefile
  s.name              = 'smartermeter'
  s.version           = '0.3.2'
  s.date              = '2011-03-29'
  s.rubyforge_project = 'smartermeter'

  ## Make sure your summary is short. The description may be as long
  ## as you like.
  s.summary     = "Fetches SmartMeter data from PG&E"
  s.description = "Fetches SmartMeter data from PG&E and can upload to Google PowerMeter"

  ## List the primary authors. If there are a bunch of authors, it's probably
  ## better to set the email to an email list or something. If you don't have
  ## a custom homepage, consider using your GitHub URL or the like.
  s.authors  = ["Matt Colyer"]
  s.email    = 'matt.removethis@nospam.colyer.name'
  s.homepage = 'http://github.com/mcolyer/smartermeter'

  ## This gets added to the $LOAD_PATH so that 'lib/NAME.rb' can be required as
  ## require 'NAME.rb' or'/lib/NAME/file.rb' can be as require 'NAME/file.rb'
  s.require_paths = %w[lib]

  ## This sections is only necessary if you have C extensions.
  #s.require_paths << 'ext'
  #s.extensions = %w[ext/extconf.rb]

  ## If your gem includes any executables, list them here.
  s.executables = ["smartermeter"]
  s.default_executable = 'smartermeter'

  ## Specify any RDoc options here. You'll want to add your README and
  ## LICENSE files to the extra_rdoc_files list.
  #s.rdoc_options = ["--charset=UTF-8"]
  #s.extra_rdoc_files = %w[README.md]

  ## List your runtime dependencies here. Runtime dependencies are those
  ## that are needed for an end user to actually USE your code.
  s.add_dependency('mechanize', ["= 1.0.0"])
  s.add_dependency('crypt19', ["= 1.2.1"])
  s.add_dependency('rest-client', ["= 1.6.1"])
  s.add_dependency('json_pure', ["= 1.5.1"])

  ## List your development dependencies here. Development dependencies are
  ## those that are only needed during development
  s.add_development_dependency('rspec', ["~> 2.5.0"])
  s.add_development_dependency('vcr', ["~> 1.7.0"])
  s.add_development_dependency('webmock', ["~> 1.6.2"])
  s.add_development_dependency('minitar', ["~> 0.5.2"])

  ## Leave this section as-is. It will be automatically generated from the
  ## contents of your Git repository via the gemspec task. DO NOT REMOVE
  ## THE MANIFEST COMMENTS, they are used as delimiters by the task.
  # = MANIFEST =
  s.files = %w[
    CHANGELOG.md
    Gemfile
    LICENSE
    README.md
    Rakefile
    bin/smartermeter
    icons/smartermeter-16x16.png
    icons/smartermeter-32x32.png
    icons/smartermeter.ico
    icons/smartermeter.svg
    installer/launch4j.xml
    installer/main.rb
    installer/nsis.nsi
    lib/smartermeter.rb
    lib/smartermeter/daemon.rb
    lib/smartermeter/interfaces/cli.rb
    lib/smartermeter/interfaces/swing.rb
    lib/smartermeter/sample.rb
    lib/smartermeter/samples.rb
    lib/smartermeter/service.rb
    lib/smartermeter/services/brighterplanet.rb
    lib/smartermeter/services/cacert.pem
    lib/smartermeter/services/google_powermeter.erb
    lib/smartermeter/services/google_powermeter.rb
    smartermeter.gemspec
    spec/fixtures/data.csv
    spec/fixtures/expected_google_request.xml
    spec/fixtures/vcr_cassettes/brighterplanet.yml
    spec/sample_spec.rb
    spec/samples_spec.rb
    spec/service_spec.rb
    spec/services/brighterplanet_spec.rb
    spec/services/google_powermeter_spec.rb
    spec/spec_helper.rb
  ]
  # = MANIFEST =

  ## Test files will be grabbed from the file list. Make sure the path glob
  ## matches what you actually use.
  s.test_files = s.files.select { |path| path =~ /^spec\/*_spec.rb/ }
end
