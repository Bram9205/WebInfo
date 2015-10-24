require 'mysql'
require 'nokogiri'
require 'rest-client' 
require 'json'
require 'multi_json'
require 'csv'

data = CSV.read("nieuw.csv", { :col_sep => ';' })
v1 = ARGV[0]
file = open(v1)
json = file.read
tweets = MultiJson.load(json)
i = 0 
while i < tweets.length
	locatie = tweets[i]["user"]["location"]
	text = tweets[i]["text"] 
	datum = tweets[i]["created_at"]
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
	ia = 0
	x = ' '
	locatie_new = locatie.downcase.gsub(/[^a-z0-9\s\-\']/i, '')
	#puts locatie_new
		while  ia < data.length 
			d1 = data[ia][0]
			if(d1 != nil)
				d1 = d1.downcase.gsub(/[^a-z0-9\s\-\']/i, '')
				if(locatie_new.include? d1 or locatie_new == d1 )
					if(d1.length > x.length)
						locatie = d1
						x = d1
						puts locatie
					end
				end
			end
			ia +=1
		end
#	puts i.to_s + ' ' + text 
	begin
    	con = Mysql.new '95.85.50.60', 'admin', 't249DJK8', 'test'
		con.query("INSERT INTO `test`.`tweets` (`id`, `text`, `tokonized_text`, `datum`, `locatie`) VALUES (NULL, '" + text.to_s + "',  '" + tokonized_text + "',  '" + datum.to_s + "',  '" + locatie.to_s +  "')")
		
	rescue Mysql::Error => e
    	puts e.errno
    	puts e.error
	ensure
    	con.close if con
	end

#	puts datum
	i += 1
end