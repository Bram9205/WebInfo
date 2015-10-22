#!/usr/bin/ruby
i = 200
while(i < 230)
	j = i
	system("ruby ML_Jasper.rb " + j.to_s)
	#puts i + ' ' + j.to_s
	#puts ''
	i += 1
end
