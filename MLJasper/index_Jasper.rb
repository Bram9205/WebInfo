#!/usr/bin/ruby
i = 0
while(i < 291)
	j = i
	system("ruby ML_Jasper.rb " + j.to_s)
	#puts i + ' ' + j.to_s
	#puts ''
	i += 1
end
