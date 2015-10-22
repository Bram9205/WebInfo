require 'nokogiri'
require 'open-uri'
require 'rest-client'
require 'csv'

data = CSV.read("nieuw.csv", { :col_sep => ';' })

string = "httpeindhoven"
if( string == "httpeindhoven")
	string = File.open("rtvnh.html")
	doc = Nokogiri::HTML(string)
	#woop = doc.css('.text')
	#dibs = woop.css(".sandbox")
	#diks = dibs.css(".alt").text.strip
	#dips = doc.css(".introduction").text.strip
	diks = doc.css('.content-text').text.strip
	dips = doc.css(".content_short").text.strip
	c = diks.downcase.split()
	i = 0 
	while  i < data.length 
			d1 = data[i][0]
			if(d1 != nil)
				d1 = d1.downcase.gsub(/[^a-z0-9\s\-\']/i, '')
				if(d1 != nil)
					if( d1 == c[0] or d1 == c[0] + ' ' + c[1])
						puts d1
					end
				end
			end
			i +=1
	end
=begin
	if( diks.length > 2)
	#	puts diks
		string = dips + diks
		puts string
		x = string.downcase
		c = x.match(/([\w ]+)/)
		c = c[0].gsub!(/\W/,'')
		i = 0 
		while  i < data.length 
			d1 = data[i][0]
			if(d1 != nil)
				d1 = d1.downcase.gsub(/[^a-z0-9\s\-\']/i, '')
				if(d1 != nil)
					if( d1 == c)
						puts d1
					end
				end
			end
			i +=1
		end
		string.gsub!(' ', 'xbartiscoolx')
		string.gsub!(/\W/,'')
		string.gsub!('xbartiscoolx', '%20')
	end

#		response = RestClient.get 'http://178.62.156.148:9200/web/_analyze?analyzer=web&text=' + string
=begin
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
end

=begin
string = dips + diks
array = string.gsub(/\s+/m, ' ').strip.split(" ")
array2 = ["Eindhoven","Helmond"]
i = 0
j = 0
while  i < array.length 
	while  j < array2.length 
		puts array[i]
		j+= 1
	end
	i += 1
end
=end