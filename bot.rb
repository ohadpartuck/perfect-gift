# bot.rb
require 'facebook/messenger'

include Facebook::Messenger

$validation_token = 'kkkooo'
$page_access_token = 'EAAETipyTdlMBAAi84aBpTLPTyLfTMTj82mUKro0d6aamlEJMN81WrCq94ricC5daDGgVMJ0K2iL9eZC8sXAxcRP4vZCZCQJ8qolBQGEQ9kMdZCQZAJA9MSNHdTqZBt168QghHXdUiqOTFOnGiblHZBbQbMOie7optWK9I80gGhL2QZDZD'
$sessions = {}

Facebook::Messenger.configure do |config|
  config.access_token = $page_access_token
#  config.app_secret = '9f8930ef5e21ac521ddd3bbb0ce731fc'
  config.verify_token = $validation_token
end

Facebook::Messenger::Subscriptions.subscribe

Bot.on :message do |message|
  p "GOT MESSAGE: #{message.to_s}"

  message.id          # => 'mid.1457764197618:41d102a3e1ae206a38'
  message.sender      # => { 'id' => '1008372609250235' }
  message.seq         # => 73
  message.sent_at     # => 2016-04-22 21:30:36 +0200
  message.text        # => 'Hello, bot!'
  message.attachments # => [ { 'type' => 'image', 'payload' => { 'url' => 'https://www.example.com/1.jpg' } } ]

  $sessions[message.sender['id']] ||= UserSession.new(message.sender['id'])
  $sessions[message.sender['id']].messages_received << message.text
  $sessions[message.sender['id']].converse

  # text_reply = last_message.nil? ? 'Hello, human!' : last_message
  #
  # send_message(message.sender['id'], text_reply)

#  send_buttons(message.sender['id'], [{ title: 'Yes', payload: 'HARMLESS' }, { title: 'No', payload: 'EXTERMINATE' }])
end


Bot.on :optin do |optin|
  Facebook::Messenger::Subscriptions.subscribe

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

  # if postback.payload == 'EXTERMINATE'
  #   send_message(postback.sender['id'], "Human #{postback.recipient} marked for extermination")
  # elsif postback.payload == 'HARMLESS'
  #   send_message(postback.sender['id'], "Human #{postback.recipient} is friend")
  # end

# get user session, process postback
  user_session = $sessions[postback.sender['id']]  || UserSession.new(postback.sender['id'])
  user_session.callback(postback.payload)
end

class Producter
  ALL_PRODUCTS = [
    { :tags => [], :description => 'desc', :link => 'http://www.amazon.com/some_product'}
  ]

  def self.recommend(tags)
    # match tags passed in with tags for product. find best match and return Product
    # how to format the response back to the user still needs to be resolved.

  end
end

class Questioner
  ALL_QUESTIONS = [
    { name: 'q1', payloads: ['homebody', 'butterfly'], text: 'How much does your girl like to go out?', options: [{ title: 'Homebody', payload: 'homebody' }, { title: 'Social Butterfly', payload: 'butterfly' }] }
  ]

  def self.next_question(questions_already_answered = [])
    available_questions = ALL_QUESTIONS.select { |qq| !questions_already_answered.include?(qq[:name]) }
    available_questions.first
  end
end


class UserSession
  attr_accessor :questions_answered, :messages_received, :tags, :products_recommended, :human_id

  def initialize(human_id)
    clear
    @human_id = human_id
  end

  def send_question(question)
    Bot.deliver(
      recipient: {
        id: @human_id
      },
      message: {
        attachment: {
          type: 'template',
          payload: {
            template_type: 'button',
            text: question[:text],
            buttons: question[:options].map { |option| { type: 'postback', title: option[:title], payload: option[:payload] } }
          }
        }
      }
    )
  end

  def send_message(message)
    Bot.deliver(
      recipient: {
        id: @human_id
      },
      message: {
        text: message
      }
    )
  end

  def clear
    @questions_answered = []
    @messages_received = []
    @tags = []
    @products_recommended = []
  end

  def converse
    next_question = Questioner.next_question(@questions_answered)

    if next_question
      send_question(next_question)
    else
      recommend_product
    end
  end

  def recommend_product
    send_message("No recommendations yet.. tags: #{@tags.to_s}")
  end

  def callback(payload)
    # find question answered, mark as asked
    question_answered = Questioner::ALL_QUESTIONS.find { |qq| qq[:payloads].include?(payload) }
    @questions_answered << question_answered[:name] unless @questions_answered.include?(question_answered[:name])
    p "tags: #{@tags.to_s} #{__LINE__}"

    # in case question is already answered, remove other values
    @tags = @tags - question_answered[:payloads]

    p "tags: #{@tags.to_s} #{__LINE__}"

    # add tags, for now it is just the payload. this can get more complex.
    @tags << payload

    p "tags: #{@tags.to_s} #{__LINE__}"

    converse
  end
end
