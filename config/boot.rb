ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
# Bootsnap 1.3.2 is incompatible with Ruby 2.7.
# require 'bootsnap/setup'
