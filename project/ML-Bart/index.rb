#!/usr/bin/ruby
i = 1
while(i < 31132)
	j = i
	system("ruby ML_Bart.rb " + j.to_s)
	i += 1
end