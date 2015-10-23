require 'json'
require 'multi_json'

v1 = 'newfile.json'
file = open(v1)
json = file.read
tweets = MultiJson.load(json)
i =0
while i< tweets.length
	if(i>100)
		puts tweets[i][0]["created_at"]
	end
	i+=1 
end