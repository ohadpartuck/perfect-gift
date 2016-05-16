require 'bundler'
Bundler.require


class PerfectGift < Sinatra::Base
  get '/' do
    'Hello world!'
  end

  get '/hello/:name' do
    # matches "GET /hello/foo" and "GET /hello/bar"
    # params['name'] is 'foo' or 'bar'
    "Hello #{params['name']}!"
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end

