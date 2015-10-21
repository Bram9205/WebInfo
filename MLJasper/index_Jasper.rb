#!/usr/bin/ruby
i = 1
# Change the boundary to the number of entries in the database.
# 400
while(i < 376)
	j = i
	system("ruby ML_Jasper.rb " + j.to_s)
	i += 1
end
