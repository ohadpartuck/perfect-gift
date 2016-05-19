require 'bundler'
Bundler.require

$validation_token = 'kkkooo'

class PerfectGift < Sinatra::Base
  get '/' do
    'Hello world!'
  end

  get '/hello/:name' do
    # matches "GET /hello/foo" and "GET /hello/bar"
    # params['name'] is 'foo' or 'bar'
    "Hello #{params['name']}!"
  end

  get '/webhook-perfect-gift/' do
    if @request.params['hub.verify_token'] == $validation_token
      @request.params['hub.challenge']
    else
      'Error, wrong validation token'
    end
  end

  post '/webhook-perfect-gift/' do
    @request.params
  end


  # start the server if ruby file executed directly
  run! if app_file == $0
end



