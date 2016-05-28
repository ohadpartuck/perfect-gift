require 'bundler'
Bundler.require

require 'facebook/messenger'
require_relative 'bot'

run Facebook::Messenger::Server