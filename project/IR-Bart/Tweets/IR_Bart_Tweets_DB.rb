require 'mysql'
require 'nokogiri'
require 'rest-client' 
require 'json'
require 'multi_json'
require 'csv'

v1 = '18102015.json'
file = open(v1)
json = file.read
tweets = MultiJson.load(json)
i = 0 
while i < tweets["statuses"].length
	locatie = tweets["statuses"][i]["user"]["location"]
	text = tweets["statuses"][i]["text"] 
	datum = tweets["statuses"][i]["created_at"]
	text.gsub!(' ', 'xbartiscoolx')
	text.gsub!(/\W/,'')
	text.gsub!('xbartiscoolx', '%20')
	response = RestClient.get 'http://localhost:9200/snowball/_analyze?analyzer=snowball&text=' + text
			json = response
			parsed = MultiJson.load(json)
			j = 0
			tokonized_text = ""
			while  j < parsed["tokens"].length 
				tokonized_text += parsed["tokens"][j]["token"] + " "
				j +=1
			end
	text.gsub!('%20', ' ')
	puts i.to_s + ' ' + text 
	begin
    	con = Mysql.new '95.85.50.60', 'admin', 't249DJK8', 'test'
		con.query("INSERT INTO `test`.`tweets` (`id`, `text`, `tokonized_text`, `datum`, `locatie`) VALUES (NULL, '" + text.to_s + "',  '" + tokonized_text + "',  '" + datum.to_s + "',  '" + locatie.to_s +  "')")
		
	rescue Mysql::Error => e
    	puts e.errno
    	puts e.error
	ensure
    	con.close if con
	end

	i += 1
end
=begin
string = parsed["text"]
string.gsub!(' ', '%20')
dibs = parsed["place"]["name"]
datum = parsed["created_at"]
puts dibs
puts string
=end
=begin
response = RestClient.get 'http://178.62.156.148:9200/web/_analyze?analyzer=web&text=' + string
json = response
parsed = MultiJson.load(json)
i = 0
aap = ""
while  i < parsed["tokens"].length 
	aap += parsed["tokens"][i]["token"] + " "
	i +=1
end
puts aap
RestClient.post "http://178.62.156.148:9200/movies/movie/1", {"text:" => aap }.to_json, :content_type => :json, :accept => :json
=end