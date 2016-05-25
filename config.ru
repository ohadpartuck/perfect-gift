require 'bundler'
Bundler.require

Localtunnel::Client.start(port: 5001)
Localtunnel::Client.running? # => true
url = Localtunnel::Client.url # => https://pnevcucqgb.localtunnel.me
p url

require 'facebook/messenger'
require_relative 'bot'

run Facebook::Messenger::Server