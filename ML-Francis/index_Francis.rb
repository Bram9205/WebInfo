#!/usr/bin/ruby
i = 1
# Change the boundary to the number of entries in the database.
while(i < 601)
	j = i
	system("ruby ML_Francis.rb " + j.to_s)
	i += 1
end
