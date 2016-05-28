require 'bundler'
Bundler.require
# require 'net/http'
require 'json'


$validation_token = 'kkkooo'
$page_access_token = 'EAAETipyTdlMBAAi84aBpTLPTyLfTMTj82mUKro0d6aamlEJMN81WrCq94ricC5daDGgVMJ0K2iL9eZC8sXAxcRP4vZCZCQJ8qolBQGEQ9kMdZCQZAJA9MSNHdTqZBt168QghHXdUiqOTFOnGiblHZBbQbMOie7optWK9I80gGhL2QZDZD'


def send_text_message(sender, text)
  message_data = {
      text:text
  }
  post_data = HTTParty.post("https://graph.facebook.com/v2.6/me/messages?access_token=#{$page_access_token}",
                body: {
                    recipient: {id:sender},
                    message: message_data,
                }).body
  # post_data = Net::HTTP.post_form(
  #     URI.parse('https://graph.facebook.com/v2.6/me/messages?access_token='+$page_access_token),
  #     {
  #         recipient: {id:sender},
  #         message: message_data,
  #     }
  # )

  puts post_data


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

  post '/webhook-perfect-gift/' do
    content_type :json
    params = JSON.parse(request.body.read)

    messaging_events = params['entry'][0]['messaging']

    for i in 0..(messaging_events.length - 1)
        event = messaging_events[i]
        sender = event['sender']['id']
        if event['message'] && event['message']['text']
          text = event['message']['text']
          send_text_message(sender, "Text received, echo: "+ text)
          # // Handle a text message from this sender
        end
    end
  end


  # start the server if ruby file executed directly
  run! if app_file == $0
end



