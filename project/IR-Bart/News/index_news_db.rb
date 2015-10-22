#!/usr/bin/ruby

i = 580
while(i < 631)
	j = i
	system("ruby IR_Bart_news_db.rb " + j.to_s)
	i += 1
end
=begin
i = 727
while(i < 1018)
	j = i
	system("ruby IR_Bart_news_db.rb " + j.to_s)
	i += 1
end

i = 1300
while(i < 1540)
	j = i
	system("ruby IR_Bart_news_db.rb " + j.to_s)
	i += 1
end
i = 2047
while(i < 2126)
	j = i
	system("ruby IR_Bart_news_db.rb " + j.to_s)
	i += 1
end
=end