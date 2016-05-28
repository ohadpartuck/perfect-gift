require 'bundler'
Bundler.require

require 'facebook/messenger'
require_relative 'bot'

map('/example') { run Facebook::Messenger::Server }