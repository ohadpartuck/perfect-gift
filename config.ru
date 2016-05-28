require 'bundler'
Bundler.require

require 'facebook/messenger'
require_relative 'main'
require_relative 'bot'
require_relative 'main'

map('/bot') { run Facebook::Messenger::Server }
map('/') { run PerfectGift }