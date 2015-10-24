#!/usr/bin/ruby
i = 19914
while(i < 24918)
	j = i
	system("ruby IR_Bart_Tweets.rb " + j.to_s)
	i += 1
end