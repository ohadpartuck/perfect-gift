require 'bundler'
Bundler.require
require 'net/http'


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
    puts @request.params.inspect
    puts @request.params.class.inspect
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



