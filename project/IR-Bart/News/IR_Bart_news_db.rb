#!/usr/bin/ruby

require 'mysql'
require 'nokogiri'
require 'rest-client' 
require 'json'
require 'multi_json'
require 'csv'

data = CSV.read("nieuw.csv", { :col_sep => ';' })
id = ARGV[0]
puts id
begin
    con = Mysql.new '95.85.50.60', 'admin', 't249DJK8', 'test'
    rs = con.query("SELECT * FROM news_retriever_page WHERE id = " + id.to_s)
    
    rs.each do |row|
		string = row[5]
		doc = Nokogiri::HTML(string)
		case row[3]
		when 'http://www.omroepbrabant.nl'
			dips = doc.css('.article-content').text.strip
		when 'http://www.omroepgelderland.nl'
			diks = doc.css('[itemprop="articleBody"]').text.strip
			dips = doc.css(".intro").text.strip
			dips = dips + diks
		when 'http://www.rtvnh.nl/'
			 dips = doc.css('.content-text').text.strip
		else
			diks = ''
			dips = ''
		end
		string = dips
		if( string.length > 4)
			x = string.downcase
			if( row[3] == 'http://www.rtvnh.nl/')
				c = string.downcase.split()
				i = 0 
				while  i < data.length 
						d1 = data[i][0]
						if(d1 != nil)
							d1 = d1.downcase.gsub(/[^a-z0-9\s\-\']/i, '')
							if(d1 != nil)
								if( d1 == c[0] or d1 == c[0] + ' ' + c[1])
									locatie = d1
								end
							end
						end
						i +=1
				end
			else
				c = x.match(/([\w ']+)/)
				c = c[0].gsub!(/\W/,'')
				i = 0 
				while  i < data.length 
					d1 = data[i][0]
					if(d1 != nil)
						d1 = d1.downcase.gsub(/[^a-z0-9\s\-\']/i, '')
						if(d1 != nil)
							if( d1 == c)
								locatie = d1
							end
						end
					end
					i +=1
				end
			end
			string.gsub!(' ', 'xbartiscoolx')
			string.gsub!(/\W/,'')
			string.gsub!('xbartiscoolx', '%20')

			response = RestClient.get 'http://localhost:9200/snowball/_analyze?analyzer=snowball&text=' + string
			json = response
			parsed = MultiJson.load(json)
			i = 0
			tokonized_text = ""
			while  i < parsed["tokens"].length 
				tokonized_text += parsed["tokens"][i]["token"] + " "
				i +=1
			end
			string.gsub!('%20', ' ')
			if( locatie != 0) 
				begin
					con = Mysql.new '95.85.50.60', 'admin', 't249DJK8', 'test'
					puts locatie
					con.query("INSERT INTO `test`.`news` (`id`,`news_id` , `text`, `tokonized_text`, `datum`,`locatie`) VALUES (NULL, '" + id.to_s + "',  '"  +  string.to_s + "',  '"  + tokonized_text + "',  '" + row[1]  + "',  '" + locatie.to_s +  "')")

				rescue Mysql::Error => e
					puts e.errno
					puts e.error
				ensure
					con.close if con
				end
			end
		end
	end
	
	rescue Mysql::Error => e
    puts e.errno
    puts e.error
    
ensure
    con.close if con
end