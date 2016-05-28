# bot.rb
require 'facebook/messenger'

include Facebook::Messenger

$validation_token = 'kkkooo'
$page_access_token = 'EAAETipyTdlMBAAi84aBpTLPTyLfTMTj82mUKro0d6aamlEJMN81WrCq94ricC5daDGgVMJ0K2iL9eZC8sXAxcRP4vZCZCQJ8qolBQGEQ9kMdZCQZAJA9MSNHdTqZBt168QghHXdUiqOTFOnGiblHZBbQbMOie7optWK9I80gGhL2QZDZD'
$sessions = {}


def send_question(recipient_id, question, options)
  Bot.deliver(
    recipient: {
      id: recipient_id
    },
    message: {
      attachment: {
        type: 'template',
        payload: {
          template_type: 'button',
          text: question,
          buttons: options.map { |option| { type: 'postback', title: option[:title], payload: option[:payload] } }
        }
      }
    }
  )
end

def send_message(recipient_id, message)
  Bot.deliver(
    recipient: {
      id: recipient_id
    },
    message: {
      text: message
    }
  )
end

Facebook::Messenger.configure do |config|
  config.access_token = $page_access_token
  config.app_secret = '9f8930ef5e21ac521ddd3bbb0ce731fc'
  config.verify_token = $validation_token
end

Bot.on :message do |message|
  p "GOT MESSAGE: #{message.to_s}"

  message.id          # => 'mid.1457764197618:41d102a3e1ae206a38'
  message.sender      # => { 'id' => '1008372609250235' }
  message.seq         # => 73
  message.sent_at     # => 2016-04-22 21:30:36 +0200
  message.text        # => 'Hello, bot!'
  message.attachments # => [ { 'type' => 'image', 'payload' => { 'url' => 'https://www.example.com/1.jpg' } } ]

  $sessions[message.sender['id']] ||= UserSession.new
  last_message = $sessions[message.sender['id']].messages_received.last
  $sessions[message.sender['id']].messages_received << message.text

  text_reply = last_message.nil? ? 'Hello, human!' : last_message

  send_message(message.sender['id'], text_reply)

#  send_buttons(message.sender['id'], [{ title: 'Yes', payload: 'HARMLESS' }, { title: 'No', payload: 'EXTERMINATE' }])
end


Bot.on :optin do |optin|
  p "GOT OPTIN"
  optin.sender    # => { 'id' => '1008372609250235' }
  optin.recipient # => { 'id' => '2015573629214912' }
  optin.sent_at   # => 2016-04-22 21:30:36 +0200
  optin.ref       # => 'CONTACT_SKYNET'

  # question 1

  Bot.deliver(
    recipient: optin.sender,
    message: {
      text: 'Ah, human!'
    }
  )
end


Bot.on :delivery do |delivery|
  delivery.ids       # => 'mid.1457764197618:41d102a3e1ae206a38'
  delivery.sender    # => { 'id' => '1008372609250235' }
  delivery.recipient # => { 'id' => '2015573629214912' }
  delivery.at        # => 2016-04-22 21:30:36 +0200
  delivery.seq       # => 37

  puts "Human was online at #{delivery.at}"
end

Bot.on :postback do |postback|
  postback.sender    # => { 'id' => '1008372609250235' }
  postback.recipient # => { 'id' => '2015573629214912' }
  postback.sent_at   # => 2016-04-22 21:30:36 +0200
  postback.payload   # => 'EXTERMINATE'

  if postback.payload == 'EXTERMINATE'
    send_message(postback.sender['id'], "Human #{postback.recipient} marked for extermination")
  elsif postback.payload == 'HARMLESS'
    send_message(postback.sender['id'], "Human #{postback.recipient} is friend")
  end
end

class Questioner
  ALL_QUESTIONS = [
    { name: 'q1', payloads: ['homebody', 'butterfly'], question: 'How much does your girl like to go out?', options: [{ title: 'Homebody', payload: 'homebody' }, { title: 'Social Butterfly', payload: 'butterfly' }] }
  ]


  def next_question(user_session)
    available_questions = ALL_QUESTIONS
    available_questions.first
  end
end


class UserSession
  attr_accessor :questions_asked, :messages_received, :tags, :products_recommended

  def initialize
    clear
  end

  def clear
    @questions_asked = @messages_received = @tags = products_recommended = []
  end

  def callback(payload)
    # set tags according to payload
  end
end
