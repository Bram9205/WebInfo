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
string = "Wijk wakker heli bij brand Hoorn HOORN De helikopter van de politie heeft maandagavond de Hoornse wijk Ris httptcoJ7B7WPQF6Z"
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
tweets.train(:Brandweer, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "a1 directe inzet dia ambu 17137 strobloemstraatev rotterdam rottdm bon 90341 "
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
tweets.train(:Ambulance, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "PolZoetermeer Is er al meer bekend over de Overval aan de Bleiswijkseweg in Zoetermeer"
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
tweets.train(:Criminaliteit, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "Brandweer druk met coniferenbrand NEEDE Spuitgasten uit Neede hebben maandagavond een coniferenbrand geblus httptcouXO3scIuG9"
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
tweets.train(:Brandweer, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "Brand Stoelenmatter48 Hoorn brandmeester Oorzaak wordt onderzocht Einde "
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
tweets.train(:Brandweer, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "RT UBIDATA1 verkeer Ongeval A67 Eindhoven richting Venlo Nederland "
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
tweets.train(:Ongeluk, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "PRIO 1 6891 3471 3440 3242 A59 R MAASROUTE 941 Terheijden Letsel Beknelling "
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
tweets.train(:Ongeluk, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "Het referendum van Freeke is olie op het vuur httptcoMjWMSQokcp via "
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
tweets.train(:Overig, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "En weer leeg in Dinteloord hophopgas dr op gaat als de brandweer vannacht"
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
tweets.train(:Overig, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "Update Inzetvideos van de politie op YouTube en andere media httptcolAlemwtzIX "
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
tweets.train(:Overig, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "CHEVRONLEGGINGSWANDERLUSTLIFESTYLEBRANDhttptcoJA8tUcI1xo"
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
tweets.train(:Overig, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "GEOMETRICLEGGINGSWANDERLUSTLIFESTYLEBRANDhttptcoa6o8MQmJXv"
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
tweets.train(:Overig, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "Ze leren het ook nooit he httpstcoCR2fjVDo5b Achteraf natuurlijk weer sorry maar "
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
tweets.train(:Overig, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "Politie zoekt getuigen zware mishandeling httptcooCVTnQFKpU"
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
tweets.train(:Criminaliteit, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "Automatiseringgids Politie doet nieuwe aanbesteding portofoons De Nationale Politie doet een nieuwe aanbeste httptcoBbXLEt0Enj"
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
tweets.train(:Overig, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "Overval op restaurant aan Bleiswijkseweg update fotos httptcoiEajaYUREh"
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
tweets.train(:Criminaliteit, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "Aanrijding Kennedyweg met twee slachtoffers httptcoQw3ynOxcOn"
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
tweets.train(:Ongeluk, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "a2 oude klarendalseweg a arnhem 1 a 72198 Ambulance met gepaste spoed naar Klarendalseweg in Arnhem"
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
tweets.train(:Ambulance, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "Octrooibureau Vriesendorp httptcorhLXh3kVoP OctrooibureauVriesendorp Netherlands Brand Recognition Loyalty Equity Brand"
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
tweets.train(:Overig, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "Btg Americas httptcoFsdbMz9tRU BtgAmericas UnitedStates Brand Recognition Loyalty Equity Differentiation Recall Brand"
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
tweets.train(:Overig, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "EUNU Politie Kosovo jaagt demonstranten uiteen PRISTINA ANPRTR De politie in Kosovo heeft maandagavond httptco6sQXtUdPkc"
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
tweets.train(:Overig, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "RT BrandweerHaaren Vanavond tijdens onze wekelijkse oefenavond de procedure ongeval gevaarlijke stoffen geoefend"
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
tweets.train(:Overig, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "RT Burgernet_ZH Actie De politie in Sliedrecht heeft na de inbraak aan de Lelystraat de jongeman donker gekleed met pet n httpt"
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
tweets.train(:Criminaliteit, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "Vuurwerk ongeluk in hoorn httptcoffpk01Wb8D"
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
tweets.train(:Ongeluk, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "Woningbrand op Marktweg in sGravenhage brandweer met spoed voor middelbrand ter plaatse"
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
tweets.train(:Brandweer, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "Auto te water aan de JM den Uyllaan Tiel SO was al uit het voertuig Behoudens natpak en de schrik niet gewond httptco5OMvaxjFZ9"
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
tweets.train(:Ongeluk, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "Ongeval Bunschotenstraat auto vliegt in brand httptcobtDnzBHJZh"
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
tweets.train(:Brandweer, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "Brandweer helpt bij bevalling van koe Video httptcocEF1C9xdGJ"
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
tweets.train(:Overig, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "PRIO 1 6735 Hart van Brabantlaan 18 Tilburg Brand kantoor INC 04 mbr"
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
tweets.train(:Brandweer, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "RT poldrenthe Slachtoffer ongeluk Zuidlaarderweg Tynaarlo 75jarige inwoner van die plaats Stak op fiets rijbaan over zag vrachtwagen"
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
tweets.train(:Ongeluk, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "RT Cop Spotter alarm P1 Schuttersveld LDN Wegvervoer ongeval letsel personenauto Ballonpad 1 2312 NC Le httptcob3VMKlT8pL"
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
tweets.train(:Ongeluk, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "DenBosch Vluchtende vrouw in badjas opgepakt na brand bij Rembrandtlaan Rijen httptcoopqAuu5bO4 borrelnieuws httptco81PHIXm910"
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


#Roep eerst de string aan (de tweet). 
string = "RT RaboZaanstreek Wij wensen onze leden vanavond veel plezier toe bij de ledenvoorstelling van Op Sterk Water in het Zaantheater"
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
tweets.train(:Overig, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "RT ollylovesocean Water is wet httpstcotykyHHlbaK"
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
tweets.train(:Overig, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "Presentator Jan Versteegh raakt gewond aan hand httptcoP460CS7r9P"
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
tweets.train(:Overig, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "RT httptcoAnc6jmgR9p NHN HOORNNH brandweer Prio 1 dib Stoelenmatter __ Hoorn NH Brandgerucht 5151 httptcoWH1mwclcp8"
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
tweets.train(:Brandweer, tokonized_text)


#Roep eerst de string aan (de tweet). 
string = "RT ElinevdVorm Een gemeentehuis afgezet met hekken bewaakt door politie om burgers buiten te houden tijdens een vergadering van hun ver"
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



##############################################################
#Haal de juiste tweet af van elasticsearch
response = RestClient.get 'http://localhost:9200/news/tweets/'+id_input.to_s
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
	 con.query("INSERT INTO `test`.`labels_tweets` (`id`, `id_tweet`, `label_tweet`) VALUES (NULL, '" + id_input.to_s + "', '" + label.to_s + "')")
rescue Mysql::Error => e
     puts e.errno
     puts e.error
ensure
     con.close if con
end

end

