require 'jumpstart_auth'
require 'bitly'

Bitly.use_api_version_3

class MicroBlogger
	attr_reader :client, :followers

  def initialize
    puts "Initializing..."
    @client = JumpstartAuth.twitter
    @followers = @client.followers.collect { |follower| follower.screen_name }
  end

  def tweet(message)
  	if message.length <= 140
  		client.update(message)
  		puts "Tweet successful!"
  	else
  		puts "Tweet is too long! Must be 140 characters or less."
  	end
  end

  def dm(target, message)
  	puts "Trying to send #{target} this direct message:"
  	if followers.include?(target)
	  	puts message
	  	message = "d @#{target} #{message}"
	  	tweet(message)
	  else
	  	puts "@#{target} does not follow you.  You can't DM people who do not follow you!"
	  end
  end

  def spam_my_followers(message)
  	followers.each { |follower| dm(follower, message) }
  end

  def everyones_last_tweet
  	friends = client.friends
  	friend_tweets = []
  	friends.each do |friend|
  		friend_tweets << [friend.screen_name, friend.status.text, friend.status.created_at]
  	end
  	friend_tweets.sort_by { |t| t[0].downcase }.each do |t|
  		puts "#{t[0]} said this on #{t[2].strftime("%A, %b %d")}..."
  		puts "#{t[1]}"
  	end
  end

  def shorten(original_url)
  	bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
  	bitly.shorten(original_url).short_url
  end

  def run
  	puts "Welcome to the JSL Twitter Client!"
  	command = ""
  	while command != "q"
  		printf "enter command:"
  		input = gets.chomp
  		parts = input.split(" ")
  		command = parts[0]
  		case command
  		when 'q' then puts "Goodbye!"
  		when 't' then tweet(parts[1..-1].join(" "))
  		when 'dm' then dm(parts[1], parts[2..-1].join(" "))
  		when 'spam' then spam_my_followers(parts[1..-1].join(" "))
  		when 'elt' then everyones_last_tweet
  		when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
  		else puts "Sorry, I don't know how to #{command}"
  		end
  	end
  end
end

blogger = MicroBlogger.new
blogger.run

