#!/usr/bin/ruby
i = 11891
while(i < 44158)
	j = i
	system("ruby ML_Bart.rb " + j.to_s)
	i += 1
end