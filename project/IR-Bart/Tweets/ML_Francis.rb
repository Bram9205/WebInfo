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


tweets.train(:Brand, "brandweer wijk wakker heli bij brand de helikopt van de  heeft")
tweets.train(:Brand, "brandweer druk met coniferenbrand een coniferenbrand geblus httptcouxo3sciug9")
tweets.train(:Brand, "brand brandmeest oorzaak wordt onderzocht eind")
tweets.train(:Brand, "woningbrand op brandweer met spo voor middelbrand ter plaats")
tweets.train(:Brand, "brandweer prio 1 dib httptcowh1mwclcp8")
tweets.train(:Brand, "ongev auto vliegt brand httptcobtdnzbhjzh")
tweets.train(:Brand, "brandweer prio 1 brand kantoor inc 04 mbr")
tweets.train(:Brand, "brandweer omdat de lood naast het water ligt waternood niet aan de ord middelbrand")
tweets.train(:Brand, " auto verwoest door brand politi autobranden")
tweets.train(:Brand, "brandweer naar voor een voertuigbrand")
tweets.train(:Brand, " staat een gebouw de brand")
tweets.train(:Brand, "de bestrijd van de brand de  zal nog enig tijd beslag neme")
tweets.train(:Brand, " ontruimd na uitbreken brand de politi en brandweer zijn ")
tweets.train(:Brand, " twee honden en katten overleden en bewon gewond na uitslaand woningbrand ")

tweets.train(:Brandweer, "al gevolg van de brand  komt er veel rook vrij melden dat er asbest vrijgekome")
tweets.train(:Brandweer, "  meld mogelijk persoon te water brandweer heeft het water afgezocht maar niet gevonden")
tweets.train(:Brandweer, " brandweer met gepast spo naar")
tweets.train(:Brandweer, " duikinzet brandweer aan kostverloren te duiker hebben volledig vijver doorzocht geen persoon aangetroffenhulpdiensten huiswaart")


tweets.train(:Ambulance, "a2 ambul met gepast spo naar")
tweets.train(:Ambulance, "a1 direct inzet dia ambu")

tweets.train(:Criminaliteit, "er al meer bekend over de overv aan de")
tweets.train(:Criminaliteit, "auto verwoest door brand politi autobranden")
tweets.train(:Criminaliteit, "politi zoekt getuigen zware mishandel httptcoocvtnqfkpu")
tweets.train(:Criminaliteit, "overv op restaur aan updat foto httptcoieajayureh")
tweets.train(:Criminaliteit, "acti de politieheeft na de inbraak aan de lelystraat de jongeman donker gekle met pet n")
tweets.train(:Criminaliteit, "doden na overv op juweli deurn en terecht")
tweets.train(:Criminaliteit, "we horen inbraak heterdaad we rijden snel mee we horen verdachten rennen weg we balen want we zitten ver weg we horen aangehouden")
tweets.train(:Criminaliteit, " poge inbraak op de waaloord en een daadwerkelijk inbraak op de")
tweets.train(:Criminaliteit, " politi linkt jeep aan dubbel moord")
tweets.train(:Criminaliteit, " veroorzak dodelijk ongev met fietser langer vast")
tweets.train(:Criminaliteit, " dode man appart waarschijnlijk slachtoff misdrijf")

tweets.train(:Ongeluk, "auto te water aan de al uit het voertuig behouden natpak en de schrik niet gewond")
tweets.train(:Ongeluk, "vuurwerk ongeluk httptcoffpk01wb8d")
tweets.train(:Ongeluk, "veroorzak dodelijk ongev met fietser langer vast")
tweets.train(:Ongeluk, "dode bij ongev op")
tweets.train(:Ongeluk, "verkeer ongev")
tweets.train(:Ongeluk, "prio 1 6891 3471 3440 3242 letsel beknel")
tweets.train(:Ongeluk, "ernstig ongev galder twee kindj en vrouw uit auto gehaald")
tweets.train(:Ongeluk, "vanavond al motorrijderaanrijdingselecteur tp bij een kettingbots met letsel doet onderzoek")
tweets.train(:Ongeluk, "slachtoff ongeluk inwon van die plaat stak op fiet rijbaan over zag vrachtwagen")
tweets.train(:Ongeluk, " cop spotter alarm p1 ldn wegvervo ongev letsel personenauto le httptcob3vmklt8pl")
tweets.train(:Ongeluk, "automobilist laat fietsster gewond achter na aanrijdingalarmeringennld politi lochem op zoek naar ")

tweets.train(:Overig, "het referendum van oli op het vuur")
tweets.train(:Overig, " klein geluk bij een")
tweets.train(:Overig, "en weer leeg hophopga dr op gaat al de brandweer vannacht")
tweets.train(:Overig, "updat inzetvideo van de politi op youtub en ander media httptcolalemwtzix")
tweets.train(:Overig, "ze leren het ook nooit he httpstcocr2fjvdo5b achteraf natuurlijk weer sorri maar")
tweets.train(:Overig, "politi doet nieuw aanbested portofoon de national politi doet een nieuw aanbest ")
tweets.train(:Overig, "octrooibureau vriesendorp  octrooibureauvriesendorp netherland brand recognit loyalti equiti brand")
tweets.train(:Overig, "btg america btgamerica unitedst brand recognit loyalti equiti differenti recal brand")
tweets.train(:Overig, "politi kosovo jaagt demonstranten uiteen de politi kosovo heeft httptco6sqxtudpkc")
tweets.train(:Overig, " tijden onz wekelijks oefenavond de procedur ongev gevaarlijk stoffen geoefend ")
tweets.train(:Overig, "brandweer helpt bij beval van koe httptcocef1c9xdgj")
tweets.train(:Overig, "googl straft bedrijven zonder mobiel vriendelijk websitewij helpen u graag uit de brand")
tweets.train(:Overig, "wij wensen onz leden vanavond veel plezier toe bij de ledenvoorstel van op sterk water het zaantheat")
tweets.train(:Overig, "liev wendi van dijk bekijk mijn tweet ik had brand riverzz mijn papa werkt met willi alberti mij gebeurt het zelfd
")

tweets.train(:Overig, "present raakt gewond aan hand httptcop460cs7r9p")
tweets.train(:Overig, "persinfo")
tweets.train(:Overig, "mij uitlachten maar het quantum interferenti effect niet kennen gt wel met de auto rijden ltgt gevaar")

tweets.train(:Overig_Water, "water wet httpstcotykyhhlbak")
tweets.train(:Overig_Water, "grootwatertransport weer opgeruimd en wij gaan weer retour kazern")
tweets.train(:Overig_Water, " wel een creepi freak en ik moet zeggen heerlijk flesj koud water op plekken momenten dat er geen stromend water")

tweets.train(:Overig_Bier, "brand_bier deze krat zitten een paar smerig smakend bieren en 1 flesj bevatt zelf water gaarn reacti ")

tweets.train(:Overig_Buitenland, "nederlands gewond bij aanslag jeruzalem bij een aanslag van een palestijn jeruzalem deze week een ")
tweets.train(:Overig_Buitenland, "turkij schiet drone neer bij syrisch gren turks straaljag hebben een nog ongedentificeerd drone neer ")

tweets.train(:Politie,  "een gemeentehui afgezet met hekken bewaakt door politi om burger buiten te houden tijden een vergad van hun ver")
tweets.train(:Politie, "drie aanhoudingen onderzoek naar drug dealen httptcotjd2dvrs2w politi")
tweets.train(:Politie, "jongeren gooiden stenen naar de politi  azc opmerkelijk verschil met")
tweets.train(:Politie, "politi vindt 20 ton hasj romp van schip")
tweets.train(:Politie, " weer incid op middelbar school horn politi doet onderzoek ")
tweets.train(:Politie, "een overzicht van hoe politi on insloot het werden er steed meer en steed een stapj dichterbij ")
tweets.train(:Politie, "grote politi control op ")
tweets.train(:Politie, "veel politi op de been na meld verdacht situati  ")


##############################################################
#Haal de juiste tweet af van elasticsearch
response = RestClient.get 'http://localhost:9200/news/tweets/'+id_input.to_s
json = response
parsed = MultiJson.load(json)
if( parsed["exists"])
	#noteer het id, het label voeg het nieuwe label toe aan label
	puts parsed["_source"]["tokonized_text:"]
    puts parsed["_source"]["text:"]
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

