# bot.rb
require 'facebook/messenger'
require 'mongo'
include Facebook::Messenger

$validation_token = 'kkkooo'
$page_access_token = 'EAAETipyTdlMBAAi84aBpTLPTyLfTMTj82mUKro0d6aamlEJMN81WrCq94ricC5daDGgVMJ0K2iL9eZC8sXAxcRP4vZCZCQJ8qolBQGEQ9kMdZCQZAJA9MSNHdTqZBt168QghHXdUiqOTFOnGiblHZBbQbMOie7optWK9I80gGhL2QZDZD'
$sessions = {}

TAGS = {
    'low_p' => {'description' => 'price range 0-50$'},
    'medium_p' => {'description' => 'price range 50-100$'},
    'high_p' => {'description' => 'price range 100-300$'},
    'art' => {'description' => 'person like art'},
    'gadget' => {'description' => 'person like gadgets'},
    'jewelry' => {'description' => 'person like jewelry'},
    'practical' => {'description' => 'person like practical gifts'},
}

# TODO add tracking on products sells

Facebook::Messenger.configure do |config|
  config.access_token = $page_access_token
  config.verify_token = $validation_token
end

Facebook::Messenger::Subscriptions.subscribe

Bot.on :message do |message|
  p "GOT MESSAGE: #{message.to_s}"
  session = UserSessionManager.get(message.sender['id'])
  session.converse(message.text)
  UserSessionManager.store(session)

  # $sessions[message.sender['id']] ||= UserSession.new(message.sender['id'])
  # $sessions[message.sender['id']].converse(message.text)
end


Bot.on :optin do |optin|
  Facebook::Messenger::Subscriptions.subscribe

  Bot.deliver(
    recipient: optin.sender,
    message: {
      text: 'Ah, human!'
    }
  )
end


Bot.on :delivery do |delivery|
  puts "Human was online at #{delivery.at}"
end

Bot.on :postback do |postback|
  session = UserSessionManager.get(postback.sender['id'])
  session.callback(postback.payload)
  UserSessionManager.store(session)
end

class UserSessionManager
  def self.get(human_id, context = 'bot')
    data = Persister.get(human_id)
    if data
      session = UserSession.from_json(data)
      session.context = context
      session
    else
      UserSession.new(human_id, context)
    end
  end

  def self.store(session)
    Persister.store(session.human_id, session.to_json)
  end
end

class Persister
  MONGO_CONFIG = {
    'host' => 'ds023593.mlab.com:23593',
    'database' => 'heroku_djzvn5q4',
    'user' => 'perfectgift',
    'password' => 'perfectgift123'
  }

  def self.connection
    $mongo ||= Mongo::Client.new([ MONGO_CONFIG['host'] ], :database => MONGO_CONFIG['database'], :user => MONGO_CONFIG['user'], :password => MONGO_CONFIG['password'], :connect => :direct )
  end

  def self.col
    connection.database[:sessions]
  end

  def self.get(human_id)
    col.find({ 'human_id' => human_id}).first
  end

  def self.store(human_id, session)
    col.update_one({'human_id' => human_id }, session, { upsert: true })
  end
end


class Producter
  ALL_PRODUCTS = [
    { id: 1, tags: ['low_p', 'art'], description: 'awakening artful colouring for adults', link: 'https://www.etsy.com/listing/246354546/awakening-artful-colouring-adult', image: 'https://img1.etsystatic.com/113/2/8635824/il_570xN.914519225_por2.jpg'},
    { id: 2, tags: ['low_p', 'jewelry', 'art'], description: 'A Beautiful Crystal Beaded Statement Collar Necklace', link: 'https://www.etsy.com/listing/236970467/blue-necklace-crystal-beaded-statement', image: 'https://img0.etsystatic.com/068/0/10014761/il_570xN.787372174_889g.jpg'},
    { id: 3, tags: ['low_p', 'practical'], description: 'Rust colored leather strap', link: 'https://www.etsy.com/listing/172710108/oil-tanned-leather-guitar-strap-w-pick', image: 'https://img1.etsystatic.com/113/2/8635824/il_570xN.914519225_por2.jpg'},
    { id: 4, tags: ['low_p', 'practical'], description: 'Friendship journal, winnie the pooh', link: 'https://www.etsy.com/listing/220072790/friendship-journal-winnie-the-pooh', image: 'https://img1.etsystatic.com/113/2/8635824/il_570xN.914519225_por2.jpg'  },
    { id: 4, :tags => ['low_p', 'art'], :description => 'Advanced Flower Mandalas Adult Coloring Book', :link => 'https://www.etsy.com/listing/239157920/advanced-flower-mandalas-adult-coloring', image: 'https://img1.etsystatic.com/062/1/10505241/il_570xN.796024547_pso1.jpg' },
    { id: 5,  :tags => ['low_p', 'art'], :description => 'Calligraphy Starter Kit', :link => 'https://www.etsy.com/listing/230194941/calligraphy-starter-kit-printable-wisdom', image: 'https://img0.etsystatic.com/125/1/6922855/il_570xN.887407408_h3zs.jpg' },
    { id: 6, :tags => ['low_p', 'book'], :description => 'Batman v Superman Bookends', :link => 'https://www.etsy.com/listing/274461578/batman-v-superman-bookends', image: 'https://img0.etsystatic.com/117/0/12767035/il_570xN.949635312_hbg1.jpg' },
    { id: 7, :tags => ['low_p', 'book'], :description => 'Wonder Woman bookend', :link => 'https://www.etsy.com/listing/273034668/wonder-woman-bookend-designed-bookends', image: 'https://img0.etsystatic.com/122/0/8914111/il_570xN.943233242_qm9i.jpg' },
    { id: 8, :tags => ['low_p', 'book'], :description => 'Snow Capped Mountain Bookend', :link => 'https://www.etsy.com/listing/287018637/snow-capped-mountain-wooden-bookends', image: 'https://img0.etsystatic.com/137/0/9977556/il_570xN.945309672_hoe5.jpg' },
    { id: 9, :tags => ['low_p', 'book'], :description => 'Iron Pipe Book Ends', :link => 'https://www.etsy.com/listing/277433728/iron-pipe-book-ends-industrial-bookends', image: 'https://img0.etsystatic.com/128/0/6915934/il_570xN.962669174_awaa.jpg' },
    { id: 10, :tags => ['low_p', 'book'], :description => 'Midori Travelers Notebook Cover', :link => 'https://www.etsy.com/listing/287374975/midori-travelers-notebook-cover-leather', image: 'https://img1.etsystatic.com/110/0/10341513/il_570xN.993483619_8090.jpg' },
    { id: 11, :tags => ['low_p', 'baking'], :description => 'A Personalized Recipe Box', :link => 'https://www.etsy.com/listing/182177426/personalized-recipe-box-custom-recipe', image: 'https://img0.etsystatic.com/103/1/5240828/il_570xN.843845872_tgie.jpg' },

  ]

  def self.next_product(products_already_rejected = [])
    available_products = ALL_PRODUCTS.select { |qq| !products_already_rejected.include?(qq[:id]) }
    available_products.first
  end

  def self.filtered_products(products_already_rejected)
    p "@products_rejected #{products_already_rejected.inspect}, full list length #{ALL_PRODUCTS.size}"
    filtered_list  = ALL_PRODUCTS.select { |qq| !products_already_rejected.include?(qq[:id]) }
    p "@filtered_list #{filtered_list.size}"
    filtered_list
  end

  def self.recommend(tags, rejected_products, number_of_recommendations = 1)
    # match tags passed in with tags for product. find best match and return Product
    # how to format the response back to the user still needs to be resolved.
    # tags = ['low_p', 'gadget']
    matching_products = []
    # products_by_similar_tags = []
    results = []
    filtered_products = self.filtered_products(rejected_products)
    filtered_products.each do |product|
      similar_tags = tags & product[:tags]
      matching_products.push({'product' => product, 'similar_count' => similar_tags.size})
    end

    matching_products.sort! { |a,b| a['similar_count'] <=> b['similar_count']}
    # popping out the last number_of_recommendations
    for i in 1..number_of_recommendations
      results.push(matching_products.pop)
    end

    results[0]
  end
end

class Questioner
  ALL_QUESTIONS = [
    { name: 'q1', payloads: ['homebody', 'traveler'],
      text: 'How much does your girl like to go out?',
      image: 'homebody-traveler.jpg',
      options: [{ title: 'Homebody', payload: 'homebody'},
                { title: 'Traveler', payload: 'traveler'}]
    },
    { name: 'q2', payloads: ['read_book', 'gadget'],
      text: 'What would she prefer more?',
      image: 'reading-book.jpeg',
      options: [{ title: 'Reading A Book', payload: 'read_book'},
                { title: 'Playing Gadgets', payload: 'gadget'}]
    },
    { name: 'q3', payloads: ['play', 'listen'],
      text: 'What would she prefer more?',
      image: 'player.jpeg',
      options: [{ title: 'Play', payload: 'play'},
                { title: 'Listen', payload: 'listen'}]
    },
    { name: 'q4', payloads: ['cute_stuff', 'baking'],
      text: 'What would she prefer more?',
      image: 'cute-stuff.png',
      options: [{ title: 'Cute Stuff', payload: 'cute_stuff'},
                { title: 'Baking', payload: 'baking'}]
    },
    { name: 'q5', payloads: ['low_p', 'medium_p', 'high_p'],
      text: "What's your budget?",
      image: 'maine_coon_kitten.jpg',
      options: [{ title: '0-50$', payload: 'low_p'},
                { title: '50-100$', payload: 'medium_p'},
                { title: '100-200$', payload: 'high_p' },
      ]
    },
  ]

  def self.next_question(questions_already_answered = [])
    available_questions = ALL_QUESTIONS.select { |qq| !questions_already_answered.include?(qq[:name]) }
    available_questions.first
  end
end

class UserSession
  attr_accessor :questions_answered, :messages_received, :tags, :first_contact
  attr_accessor :products_rejected, :human_id, :user_done_with_questions
  attr_accessor :last_contact, :context

  def initialize(human_id, context='bot')
    clear
    @human_id = human_id
    @context = context
  end

  def clear
    @questions_answered = []
    @messages_received = []
    @tags = []
    @products_rejected = []
    @user_done_with_questions = false
    @first_contact = true
    @last_contact = Time.now
  end

  def to_json
    {
      'questions_answered' => @questions_answered, 
      'messages_received' => @messages_received,
      'tags' => @tags,
      'first_contact' => @first_contact,
      'products_rejected' => @products_rejected,
      'human_id' => @human_id,
      'user_done_with_questions' => @user_done_with_questions,
      'last_contact' => @last_contact,
      'context' => @context
    }
  end

  def self.from_json(str)
    data = str
    foo = self.new(data['human_id'], data['context'])
    foo.questions_answered = data['questions_answered']
    foo.messages_received = data['messages_received']
    foo.tags = data['tags']
    foo.first_contact = data['first_contact']
    foo.products_rejected = data['products_rejected']
    foo.user_done_with_questions = data['user_done_with_questions']
    foo.last_contact = data['last_contact']
    foo
  end

  def bot_mode?
    @context == 'bot'
  end

  def keep_asking?
    !@user_done_with_questions
  end

  def image_path(image)
    'https://perfect-gift.herokuapp.com/img/questions/' + image
  end

  def send_question(question)
    payload = {
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
    }

    bot_mode? ? Bot.deliver(payload) : (p payload.to_s)
  end

  def send_choices_deprecated(question)
    send_message(question[:text])

    payload = {
      recipient: {
        id: @human_id
      },
      message: {
        attachment: {
          type: 'template',
          payload: {
            template_type: 'generic',
            elements:
              question[:options].map do |option|
                {
                  title: option[:title],
                  image_url: image_path(option[:image]),
                  buttons: [{
                      type: "postback",
                      title: option[:title],
                      payload: option[:payload],
                  }],
                }
              end
          }
        }
      }
    }

    bot_mode? ? Bot.deliver(payload) : (p payload.to_s)
  end

  def send_product(product, first = true)
    if first
      send_message('Great! We are now ready to start recommending you products. Take a look at what we suggest and if you are not happy with it feel free to ask for another suggestion.')
    else
      send_message('OK, we have lots of other ideas. How about this one?')
    end

    payload = {
      recipient: {
        id: @human_id
      },
      message: {
        attachment: {
          type: 'template',
          payload: {
            template_type: 'generic',
            elements: [{
              title: product[:description],
              image_url: product[:image],
              buttons: [
                  {
                    type: "web_url",
                    title: 'Get this one for her',
                    url: product[:link],
                  },
                  {
                    type: "postback",
                    title: 'Get another suggestion',
                    payload: "another_#{product[:id]}",
                  }
              ]
            }]
          }
        }
      }
    }

    bot_mode? ? Bot.deliver(payload) : (p payload.to_s)
  end


  def send_choices(question)
    payload = {
      recipient: {
        id: @human_id
      },
      message: {
        attachment: {
          type: 'template',
          payload: {
            template_type: 'generic',
            elements: [{
              title: question[:text],
              image_url: image_path(question[:image]),
              buttons: question[:options].map do |option|
                  {
                    type: "postback",
                    title: option[:title],
                    payload: option[:payload],
                  }
              end
            }]
          }
        }
      }
    }

    bot_mode? ? Bot.deliver(payload) : (p payload.to_s)
  end

  def send_message(message)
    payload = {
      recipient: {
        id: @human_id
      },
      message: {
        text: message
      }
    }

    bot_mode? ? Bot.deliver(payload) : (p payload.to_s)
  end

  def converse(message_text = nil)
    @messages_received << message_text if message_text

    if @last_contact + (30*60) < Time.now
      clear
    end

    if message_text == 'reset'
      clear
    elsif message_text == 'done'
      @user_done_with_questions = true
    end

    if @first_contact
      @first_contact = false

      send_message("Hey human! I am going to ask you some questions and then give you some ideas for gifts for your woman.")
      send_message(" ")
    end


    next_question = Questioner.next_question(@questions_answered)

    if next_question && keep_asking?
      send_choices(next_question)
    else
      # next_product = Producter.next_product(@products_rejected)
      next_product = Producter.recommend(@tags, @products_rejected)
      next_product = next_product['product']
      p "next product is #{next_product.inspect}"
      if next_product
        send_product(next_product, @products_rejected.empty?)
      else
        no_product_left_to_recommend
      end
    end
  end

  def no_product_left_to_recommend
    send_message("No recommendations left.. tags: #{@tags.to_s}")
  end

  def recommend_product
    send_message("No recommendations yet.. tags: #{@tags.to_s}")
  end

  def response(message_text)
    @messages_received << message_text
    if message_text == 'reset'
      clear
    end
  end

  def callback(payload)
    # find question answered, mark as asked
    if payload.start_with?('another')
      payload =~ /.*_(\d*)/
      product_id = $1
      @products_rejected << product_id.to_i
    else
      question_answered = Questioner::ALL_QUESTIONS.find { |qq| qq[:payloads].include?(payload) }

      if question_answered
        @questions_answered << question_answered[:name] unless @questions_answered.include?(question_answered[:name])
        # in case question is already answered, remove other values
        @tags = @tags - question_answered[:payloads]
        # add tags, for now it is just the payload. this can get more complex.
        @tags << payload
      end
    end

    converse
  end
end
