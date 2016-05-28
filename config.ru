require 'bundler'
Bundler.require

require 'facebook/messenger'
require_relative 'bot'

map('/bot') { run Facebook::Messenger::Server }