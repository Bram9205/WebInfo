#!/usr/bin/ruby
i = 16
while(i < 21)
	j = i
	system("ruby IR_Bart_Tweets_DB.rb " + j.to_s + ".json")
	i += 1
end