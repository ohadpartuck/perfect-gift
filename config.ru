require 'bundler'
Bundler.require

require 'facebook/messenger'
require File.dirname(__FILE__) + '/bot'
require File.dirname(__FILE__) + '/main'

map('/bot') { run Facebook::Messenger::Server }
map('/') { run PerfectGift }