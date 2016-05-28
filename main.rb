require 'bundler'
Bundler.require
# require 'net/http'
require 'json'
require 'facebook/messenger'

include Facebook::Messenger

$validation_token = 'kkkooo'
$page_access_token = 'EAAETipyTdlMBAAi84aBpTLPTyLfTMTj82mUKro0d6aamlEJMN81WrCq94ricC5daDGgVMJ0K2iL9eZC8sXAxcRP4vZCZCQJ8qolBQGEQ9kMdZCQZAJA9MSNHdTqZBt168QghHXdUiqOTFOnGiblHZBbQbMOie7optWK9I80gGhL2QZDZD'

Facebook::Messenger.configure do |config|
  config.access_token = $page_access_token
  # config.app_secret = '9f8930ef5e21ac521ddd3bbb0ce731fc'
  config.verify_token = $validation_token
end

class PerfectGift < Sinatra::Base

  before do
    content_type :json
  end


  get '/' do
    # File.read(File.join('website', 'index.html'))
    erb 'website/index.html'
  end


  # start the server if ruby file executed directly
  run! if app_file == $0
end



