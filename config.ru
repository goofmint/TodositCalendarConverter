require 'bundler'
Bundler.require
#$stdout.sync = true

require './app'
run Sinatra::Application
