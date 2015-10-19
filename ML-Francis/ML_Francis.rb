#!/usr/bin/ruby
require 'mysql'
require 'nokogiri'
require 'rest-client' 
require 'json'
require 'multi_json'
require 'stuff-classifier'
require 'csv'

# Makes you able to execute it on a single ID, given as input. A call to this is made by the file index_Francis.rb for every tweet.
id_input = ARGV[0]

# Voor Francis, er zijn 2 versies die je kunt gebruiken. Naive bayes en TF-IDF. Probeer zelf even welke het beste werkt. Hieronder in commentaar staan voorbeeldjes.
# Je kunt per classifier nog kijken of je stemming wil gebruiken.
# for the naive bayes implementation
#brandweer = StuffClassifier::Bayes.new("Cats or Dogs")

# for the Tf-Idf based implementation
# brandweer = StuffClassifier::TfIdf.new("Brandweer")

# these classifiers use word stemming by default, but if it has weird
# behavior, then you can disable it on init:
tweets = StuffClassifier::Bayes.new("Tweets", :stemming => false)
#politie = StuffClassifier::Bayes.new("politie", :stemming => false)
#ziekenhuis = StuffClassifier::Bayes.new("politie", :stemming => false)

#Stopwoorden, deze woorden uit de tweets gefilters.
tweets.ignore_words = ['aan', 'afd', 'als', 'bij', 'dat', 'de', 'den', 'der', 'des', 'deze', 'die', 'dit', 'dl', 'door', 'dr', 'ed', 'een', 'en', 'enige', 'enkele',
'enz', 'et', 'etc', 'haar', 'het', 'hierin', 'hoe', 'hun', 'ik', 'in', 'inzake', 'is', 'je', 'met', 'na', 'naar', 'nabij', 'niet', 'no', 'nu', 'of', 'om', 'onder',
'ons', 'onze', 'ook', 'oorspr', 'op', 'over', 'pas', 'pres', 'prof', 'publ', 'sl', 'st', 'te', 'tegen', 'ten', 'ter', 'tot', 'uit', 'uitg', 'vakgr', 'van', 'vanaf',
'vert', 'vol', 'voor', 'voortgez', 'voortz', 'wat', 'wie', 'zijn']

#Roep eerst de string aan (de tweet). 
string = "In ,  en  zijn donderdag nog eens drie wietkwekerijen gevonden als gevolg van een onderzoek naar drie hennepcriminelen die maandag en 
dinsdag werden gepakt. Eerder deze week trof de politie in dit onderzoek al achtduizend planten en stekjes aan en een flinke hoeveelheid harddrugs onder meer in 
panden aan de  in  en de  in . In  werden twee  gepakt en in het huis aan de  
nog een derde. De politie trof op de locaties, waaronder ook een loods in , professioneel aangelegde kwekerijen, drogerijen en knipperijen aan waar de 
productie van plantje tot verkoopbare drugs plaatsvond. 'Gezien de hoeveelheid kwekerijen zorgde men voor een continuproces en kon altijd wel ergens in een kwekerij 
geoogst worden', laat de politie weten."
# Het stuk hieronder roept de analyzer die wij ook voor het indexeren gebruiken aan. Deze tokenized en stemt je input van de string hierboven.
string.gsub!(' ', 'somethingthatneveroccurs')
string.gsub!(/\W/,'')
string.gsub!('somethingthatneveroccurs', '%20')
response = RestClient.get 'http://localhost:9200/snowball/_analyze?analyzer=snowball&text=' + string
json = response
parsed = MultiJson.load(json)
i = 0
tokonized_text = ""
while  i < parsed["tokens"].length 
	tokonized_text += parsed["tokens"][i]["token"] + " "
	i +=1
end
#Train je nieuwe classifier met de getokenizede tekst. Het label voor deze string is Politie.
tweets.train(:Politie, tokonized_text)

#Haal de juiste tweet af van elasticsearch
response = RestClient.get 'http://localhost:9200/news/tweet/'+id_input.to_s
json = response
parsed = MultiJson.load(json)
if( parsed["exists"])
	#noteer het id, het label voeg het nieuwe label toe aan label
	puts id_input
	puts tweets.classify(parsed["_source"]["tokonized_text:"])
	label = tweets.classify(parsed["_source"]["tokonized_text:"])
begin
	# Dit is om het label in de database op te slaan.
	# Dit moet nog wel even aangepast worden wanneer de tweets in de database staan.
    con = Mysql.new '95.85.50.60', 'admin', 't249DJK8', 'test'
	con.query("INSERT INTO `test`.`labels_tweets` (`id`, `tweet_id`, `label_tweet`) VALUES (NULL, '" + id_input.to_s + "', '" + label.to_s + "')")
	rescue Mysql::Error => e
    puts e.errno
    puts e.error
ensure
    con.close if con
end	
end

