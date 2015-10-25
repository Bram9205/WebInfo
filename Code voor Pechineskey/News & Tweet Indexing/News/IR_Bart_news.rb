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
    rs = con.query("SELECT * FROM news WHERE id = " + id.to_s)
    
    rs.each do |row|
			response = RestClient.post "http://localhost:9200/news/news/"+id.to_s , {"tokonized_text:" => row[3],"text:" => row[2], "datum:" => row[4], "locatie:" => row[5] }.to_json, :content_type => :json, :accept => :json
			puts response
	end
	
	rescue Mysql::Error => e
    puts e.errno
    puts e.error
    
ensure
    con.close if con
end