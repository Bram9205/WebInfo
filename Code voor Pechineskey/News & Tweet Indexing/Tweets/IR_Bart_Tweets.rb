#!/usr/bin/ruby

require 'mysql'
require 'nokogiri'
require 'rest-client' 
require 'json'
require 'multi_json'
require 'csv'

id = ARGV[0]
begin
    con = Mysql.new '95.85.50.60', 'admin', 't249DJK8', 'test'
    rs = con.query("SELECT * FROM tweets WHERE id = " + id.to_s)
    
    rs.each do |row|
			response = RestClient.post "http://localhost:9200/news/tweets/"+id.to_s , {"tokonized_text:" => row[2],"text:" => row[1], "datum:" => row[3], "locatie:" => row[4] }.to_json, :content_type => :json, :accept => :json
			puts response
	end
	
	rescue Mysql::Error => e
    puts e.errno
    puts e.error
    
ensure
    con.close if con
end