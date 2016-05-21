require 'bundler'
Bundler.require
require 'net/http'
require 'json'


$validation_token = 'kkkooo'


def send_text_message(sender, text)
  message_data = {
      text:text
  }

  post_data = Net::HTTP.post_form(
      URI.parse('https://graph.facebook.com/v2.6/me/messages'),
      {
          recipient: {id:sender},
          message: message_data,
      }
  )

  puts post_data.body


end

class PerfectGift < Sinatra::Base

  before do
    content_type :json
  end


  get '/' do
    'Hello world!'
  end

  get '/hello/:name' do
    # matches "GET /hello/foo" and "GET /hello/bar"
    # params['name'] is 'foo' or 'bar'
    "Hello #{params['name']}!"
  end

  get '/webhook-perfect-gift/' do
    puts "get webhook-perfect-gift!"
    puts @request.params.inspect
    puts "get webhook-perfect-gift! end"
    if @request.params['hub.verify_token'] == $validation_token
      @request.params['hub.challenge']
    else
      'Error, wrong validation token'
    end
  end

  post '/abc/' do
    params = JSON.parse(request.body.read)
    "HELLO WORLD #{params.to_s}".to_json
  end
  post '/webhook-perfect-gift/' do
    content_type :json
    puts "Hello, logs!111"
    params = JSON.parse(request.body.read)
    puts params
    puts params.class.inspect
    puts "goodbye, logs!111"
    return @request.params.to_json

    messaging_events = @request.params[0].messaging

    for i in 0..(messaging_events.length -1)
        event = messaging_events[i]
        sender = event.sender.id
        if event.message && event.message.text
          text = event.message.text
          send_text_message(sender, "Text received, echo: "+ text)
          # // Handle a text message from this sender
        end
    end
  end


  # start the server if ruby file executed directly
  run! if app_file == $0
end



