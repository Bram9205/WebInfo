#!/usr/bin/ruby
i = 0
while(i < 600)
	j = i
	system("ruby IR_Bart_Tweets_DB.rb " + j.to_s)
	i += 1
end