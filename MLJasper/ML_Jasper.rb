#!/usr/bin/ruby
require 'mysql'
require 'nokogiri'
require 'rest-client' 
require 'json'
require 'multi_json'
require 'stuff-classifier'
require 'csv'

id_input = ARGV[0]
#data = CSV.read("notificiations.csv", { :col_sep => ',' })
#puts data[0][7]

# for the naive bayes implementation
#brandweer = StuffClassifier::Bayes.new("Cats or Dogs")

# for the Tf-Idf based implementation
# brandweer = StuffClassifier::TfIdf.new("Brandweer")

# these classifiers use word stemming by default, but if it has weird
# behavior, then you can disable it on init:
news = StuffClassifier::Bayes.new("News", :stemming => false)
#politie = StuffClassifier::Bayes.new("politie", :stemming => false)
#ziekenhuis = StuffClassifier::Bayes.new("politie", :stemming => false)

news.ignore_words = ['aan', 'afd', 'als', 'bij', 'dat', 'de', 'den', 'der', 'des', 'deze', 'die', 'dit', 'dl', 'door', 'dr', 'ed', 'een', 'en', 'enige', 'enkele',
'enz', 'et', 'etc', 'haar', 'het', 'hierin', 'hoe', 'hun', 'ik', 'in', 'inzake', 'is', 'je', 'met', 'na', 'naar', 'nabij', 'niet', 'no', 'nu', 'of', 'om', 'onder',
'ons', 'onze', 'ook', 'oorspr', 'op', 'over', 'pas', 'pres', 'prof', 'publ', 'sl', 'st', 'te', 'tegen', 'ten', 'ter', 'tot', 'uit', 'uitg', 'vakgr', 'van', 'vanaf',
'vert', 'vol', 'voor', 'voortgez', 'voortz', 'wat', 'wie', 'zijn']

string = "In ,  en  zijn donderdag nog eens drie wietkwekerijen gevonden als gevolg van een onderzoek naar drie hennepcriminelen die maandag en 
dinsdag werden gepakt. Eerder deze week trof de politie in dit onderzoek al achtduizend planten en stekjes aan en een flinke hoeveelheid harddrugs onder meer in 
panden aan de  in  en de  in . In  werden twee  gepakt en in het huis aan de  
nog een derde. De politie trof op de locaties, waaronder ook een loods in , professioneel aangelegde kwekerijen, drogerijen en knipperijen aan waar de 
productie van plantje tot verkoopbare drugs plaatsvond. 'Gezien de hoeveelheid kwekerijen zorgde men voor een continuproces en kon altijd wel ergens in een kwekerij 
geoogst worden', laat de politie weten."
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
news.train(:Politie, tokonized_text)

string = "De inval in hennepkwekerij in een winkelpand aan de  in  leidde maandagavond tot onderzoek in meerdere 
woningen in  en een loods in . Naar aanleiding van informatie die in  werd gevonden, deed de politie onderzoek in verschillende woningen in 
. Daar troffen ze onderdelen aan van een professionele productielijn van hennepplanten. In de kelder van een woning aan de  in 
 werd een stekkerij aangetroffen met honderd moederplanten en 4000 stekken. Een 53-jarige  is aangehouden. In een van de andere woningen trof de 
politie een ruimte aan die werd gebruikt als hennepdrogerij. Hier zijn anderhalve kilo henneptoppen en een geldbedrag van veertienduizend euro gevonden.
Geheime doorgang Dinsdagmiddag om half twee werd in kader van hetzelfde onderzoek in een loods in  op het industrieterrein aan de  ook een 
kwekerij gevonden. In de loods was een wand geplaatst met een geheime doorgang, die werd verborgen door een kast. Die kast was voorzien van op afstand bedienbare 
magneten. Met de modernste apparatuur was de kwekerij nagenoeg zelfvoorzienend, zegt de politie. De invallen en aanhouding waren het resultaat van de inval op 
maandagavond in een  woonwinkelpand aan de . Daar werd een kwekerij gevonden achter een 'geheime wand' achterin de winkel.
In de kwekerij werden twee  van 37 en 44 jaar aangehouden."
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
news.train(:Politie, tokonized_text)

string = "Een kinderarts is aangehouden voor het bezit van kinderporno. De man is arts op de    van het . Dat ziekenhuis heeft hem op non-actief gesteld.
Het  is erg ontdaan van dit nieuws. ,,Wij zijn door de politie op de hoogte gebracht van de situatie. Natuurlijk zijn we ontzettend geschrokken. 
We hebben nooit iets gemerkt, ook de directe collega's niet, zegt  de , woordvoerder van het  waar de telefoon roodgloeiend staat. 
Op dit moment zijn er volgens de politie geen aanwijzingen dat er een relatie is tussen het nu bekende beeldmateriaal en het werk van de arts in het ziekenhuis. 
De politie kan nog niets zeggen over de omvang van de kinderporno en waar het vandaan komt. ,,We zijn het nog aan het onderzoeken'', aldus een woordvoerder.
'Bekwaam en kundig'
De betrokken kinderintensivist is sinds werkzaam in het team van kinderintensivisten en staat bekend als een bekwaam en kundig arts. 
De politie informeerde het op over de verdenking. Gezien de aard en ernst van de verdenking is hij onmiddellijk op non-actief gesteld.
Het heeft alle ouders en verzorgers van de kinderen die vanaf  tot nu op de  hebben gelegen per brief geinformeerd. 
In de brief staat hoe ouders contact kunnen opnemen met het ziekenhuis wanner zij vragen hebben. 
Afhankelijk van het aantal telefoontjes zal het verdere stappen ondernemen door bijvoorbeeld een meeting te organiseren. 
De kinderarts zit vast voor verhoor door rechercheurs van het team Bestrijding Kinderporno ."
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
news.train(:Politie, tokonized_text)

string = "In een huurappartement aan de  in  is vrijdag aan het begin van de middag een dode gevonden. Het slachtoffer, 
een man, is door geweld om het leven gebracht. Er is op een andere locatie een 56-jarige verdachte aangehouden, bevestigt de politie aan  en  . 
Het gaat vermoedelijk om de bewoner van het huis. Voor de politie zijn er vooralsnog geen aanwijzingen dat er een verband bestaat tussen het vele, 
recente (schiet)geweld in de regio.
Het gaat om het derde slachtoffer in  in twee dagen dat door een misdrijf om het leven is gekomen. In  gaat het zeer waarschijnlijk 
om een misdrijf in de relationele sfeer.
Overlast in appartement
Volgens buurtbewoners is het slachtoffer 36 jaar en een vriend van de opgepakte bewoner. Hij verbleef de afgelopen jaren regelmatig in het huis, 
sindsdien is de overlast in het huis toegenomen. Er zou regelmatig sprake zijn van harde muziek, drugsincidenten en vechtpartijen. De bewoner is 
volgens bronnen een drank- en drugsverslaafde die voor veel overlast zorgt in de buurt.
De politie was naar het appartementencomplex gegaan na een melding dat er iemand door een misdrijf was overleden. Op de tweede verdieping werd een voordeur 
geforceerd waarna agenten het levenloze lichaam aantroffen.
Rumoerige week in 
Het is een rumoerige week in . Donderdag werden twee vermoorde mannen gevonden in een vakantiehuisje tussen   en . 
Daarvoor werd  in een dag opgeschrikt door twee schietincidenten.
In  werd een neergeschoten man van vermoedelijk Turkse komaf door onbekenden gedropt in het  Ziekenhuis. Rond hetzelfde tijdstip werd 
een 46-jarige  in het huis van zijn moeder neergeschoten. Opvallend: beide mannen weigeren te vertellen wat er is gebeurd."
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
news.train(:Politie, tokonized_text)

string = "Je verwacht het niet, maar ook bij kringloopwinkels worden regelmatig spullen gestolen.  , eigenaar van kringloopwinkel , wordt 
er gek van.
Gistermiddag was het weer raak. Een wel heel brutale dief kreeg het voor elkaar om een doppendoos onder zijn jas de winkel uit te smokkelen. 
Op de bewakingsbeelden is het duidelijk te zien. Plezier kwijt Die doos gereedschap is nieuw en veel goedkoper hier dan in andere winkels. 
De mensen zijn zo brutaal. Op een gegeven moment raak je gewoon je plezier kwijt, aldus Sluijt.
Volgens hem wordt er dagelijks gestolen. Vooral kleding wordt heel veel gestolen. Trekken ze een mooie broek aan in de kleedkamer en 
hangen ze hun oude gewoon in het rek.
'Niet te controleren'
Theo besloot de beelden van de bewakingscamera op online te plaatsen. We hebben het zelf niet gemerkt toen het gebeurde. 
Er lopen zoveel mensen hier rond. Het is niet te controleren.
Vanmiddag gaat hij aangifte bij de politie doen. Ik wacht nog even een telefoontje van een tipgever af. Die heeft de dief mogelijk herkend.
Herken jij de man in de video? Neem dan contact op met ."
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
news.train(:Politie, tokonized_text)

string = "Eerst een huis binnendringen alsof je de hoofdrol speelt in een Hollywoodfilm en daarna worden opgepakt omdat je zelf de deur opendoet voor de politie. 
Dat overkwam een inbreker in  vannacht.
De politie kreeg om 2.40 uur een melding van een bewoner van de   in  dat hij gestommel hoorde vanuit de woning ernaast. 
Verdacht, vond de politie meteen, omdat dat huis al een tijdje leegstaat. 
Agenten gingen snel naar de woning toe en wilden daar een deur forceren. Maar nog voordat het zover kwam, zwaaide de inbreker (40) ineens zelf de deur open. 
Na controle bleek dat de inbreker uit  een gat onder de woning door had gegraven en via de kruipruimte in het pand was gekomen.
Het is nog niet duidelijk of de man iets uit de woning had meegenomen. De politie vermoedt dat hij zijn zinnen had gezet op bouwmateriaal. 
Het gereedschap dat de man bij zich had, is in beslag genomen."
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
news.train(:Politie, tokonized_text)

string = "In ,  en  zijn donderdag nog eens drie wietkwekerijen gevonden als gevolg van een onderzoek naar drie hennepcriminelen die 
maandag en dinsdag werden gepakt. Eerder deze week trof de politie in dit onderzoek al achtduizend planten en stekjes aan en een flinke hoeveelheid harddrugs 
onder meer in panden aan de  in  en de  in . In  werden twee  gepakt en in het huis 
aan de  nog een derde. De politie trof op de locaties, waaronder ook een loods in , professioneel aangelegde kwekerijen, drogerijen en 
knipperijen aan waar de productie van plantje tot verkoopbare drugs plaatsvond. 'Gezien de hoeveelheid kwekerijen zorgde men voor een continuproces en kon 
altijd wel ergens in een kwekerij geoogst worden', laat de politie weten."
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
news.train(:Criminaliteit, tokonized_text)

string = "Een  (33) krijgt 30 maanden celstraf waarvan tien voorwaardelijk voor een woningoverval.
De man is medeplichtig bevonden aan een overval op kerstnacht van een bejaarde . Deze zou zijn bedacht door de 22-jarige (inmiddels ex-)vriendin van deze gestrafte. 
Doelwit was de oom van de vrouw, die volgens haar zes mille in huis had. Dat bleek niet zo te zijn. De vrouw komt binnenkort voor de rechter, 
volgens haar had de vriend het plan bedacht en haar gedwongen mee te doen.
Het OM vond dat de man meteen een kliniek inmoest, maar de rechtbank wil dat hij eerst zijn celstraf uitzit."
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
news.train(:Criminaliteit, tokonized_text)

string = "De inval in hennepkwekerij in een winkelpand aan de  in  leidde maandagavond tot onderzoek in meerdere 
woningen in  en een loods in . Naar aanleiding van informatie die in  werd gevonden, deed de politie onderzoek in verschillende woningen in 
. Daar troffen ze onderdelen aan van een professionele productielijn van hennepplanten. In de kelder van een woning aan de  in 
 werd een stekkerij aangetroffen met honderd moederplanten en 4000 stekken. Een 53-jarige  is aangehouden. In een van de andere woningen trof de 
politie een ruimte aan die werd gebruikt als hennepdrogerij. Hier zijn anderhalve kilo henneptoppen en een geldbedrag van veertienduizend euro gevonden.
Geheime doorgang Dinsdagmiddag om half twee werd in kader van hetzelfde onderzoek in een loods in  op het industrieterrein aan de  ook een 
kwekerij gevonden. In de loods was een wand geplaatst met een geheime doorgang, die werd verborgen door een kast. Die kast was voorzien van op afstand bedienbare 
magneten. Met de modernste apparatuur was de kwekerij nagenoeg zelfvoorzienend, zegt de politie. De invallen en aanhouding waren het resultaat van de inval op 
maandagavond in een  woonwinkelpand aan de . Daar werd een kwekerij gevonden achter een 'geheime wand' achterin de winkel.
In de kwekerij werden twee  van 37 en 44 jaar aangehouden."
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
news.train(:Criminaliteit, tokonized_text)

string = "In een huurappartement aan de  in  is vrijdag aan het begin van de middag een dode gevonden. Het slachtoffer, 
een man, is door geweld om het leven gebracht. Er is op een andere locatie een 56-jarige verdachte aangehouden, bevestigt de politie aan. 
Het gaat vermoedelijk om de bewoner van het huis. Voor de politie zijn er vooralsnog geen aanwijzingen dat er een verband bestaat tussen het vele, 
recente (schiet)geweld in de regio.
Het gaat om het derde slachtoffer in  in twee dagen dat door een misdrijf om het leven is gekomen. In  gaat het zeer waarschijnlijk 
om een misdrijf in de relationele sfeer.
Overlast in appartement
Volgens buurtbewoners is het slachtoffer 36 jaar en een vriend van de opgepakte bewoner. Hij verbleef de afgelopen jaren regelmatig in het huis, 
sindsdien is de overlast in het huis toegenomen. Er zou regelmatig sprake zijn van harde muziek, drugsincidenten en vechtpartijen. De bewoner is 
volgens bronnen een drank- en drugsverslaafde die voor veel overlast zorgt in de buurt.
De politie was naar het appartementencomplex gegaan na een melding dat er iemand door een misdrijf was overleden. Op de tweede verdieping werd een voordeur 
geforceerd waarna agenten het levenloze lichaam aantroffen.
Rumoerige week in 
Het is een rumoerige week in . Donderdag werden twee vermoorde mannen gevonden in een vakantiehuisje tussen H. 
Daarvoor werd  in een dag opgeschrikt door twee schietincidenten.
In  werd een neergeschoten man van vermoedelijk Turkse komaf door onbekenden gedropt in het  Ziekenhuis. Rond hetzelfde tijdstip werd 
een 46-jarige  in het huis van zijn moeder neergeschoten. Opvallend: beide mannen weigeren te vertellen wat er is gebeurd."
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
news.train(:Criminaliteit, tokonized_text)

string = "Wegens de onderschepping van 800 kilo cocaine in  heeft de politie opnieuw twee verdachten aangehouden. 
Het gaat om twee inwoners van  van 54 en 57 jaar.
Zij werden volgens het Openbaar Ministerie woensdag al opgepakt. Verder zijn in de havenstad vier woningen, een cafe en twee bergingen doorzocht. 
Daarbij zijn onder meer drie vuurwapens, telefoons, administratie en een speedboot in beslag genomen.
De rechter-commissaris in  heeft vandaag besloten dat de 54-jarige verdachte nog twee weken vast blijft zitten. De andere man is in vrijheid gesteld.
De onderschepping van de partij coke met een groothandelswaarde van 28 miljoen euro is al geruime tijd in onderzoek. Half  zijn vier bemanningsleden 
van een kotter, de schipper en diens vrouw in  aangehouden op verdenking van drugshandel."
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
news.train(:Criminaliteit, tokonized_text)

string = "Een 61-jarige man is twee weken geleden in  opgepakt omdat hij in de jaren zeventig betrokken zou zijn geweest bij oorlogsmisdaden in .
De man wordt verdacht van het martelen van en moord op (vermeende) tegenstanders van de toenmalige militaire dictatuur. Dat meldt het Openbaar Minsterie vandaag.
Doodstraf
Het gaat om  . Hij woont al jaren in  en heeft de  nationaliteit. 
In de jaren '90 werd in de media ook al bericht over zijn betrokkenheid bij misdaden tegen . 
In  is de man eerder bij verstek veroordeeld tot de doodstraf.
Een deel van het strafdossier waardoor hij de doodstraf kreeg, is door de  autoriteiten overgedragen aan . 
De  politie heeft inmiddels een aantal getuigen gehoord. Het gaat hier om  die in het buitenland wonen. 
Zij hebben verklaard dat  misdaden zou hebben gepleegd in de  ."
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
news.train(:Criminaliteit, tokonized_text)

string = "Drie  en twee  worden verdacht van valsheid in geschrifte en arbeidsuitbuiting van tientallen werknemers uit .
Het vijftal zou de ,  en  niet het loon hebben uitbetaald waar zij recht op hebben. De verdachten leidden een uitzendorganisatie die 
mensen als schoonmakers en technisch personeel inzette in onder meer keukens van hotels en restaurants.
Vier van hen werden dinsdag opgepakt, een vijfde verdachte meldde zich woensdag zelf op het politiebureau. De politie kwam de mannen op het spoor na een aangifte.
Volgens een woordvoerder van de Inspectie SZW werden veel werknemers ondergebracht op een adres, waar ze weinig vrijheid hadden. 
Naast de rol van de verdachten wordt ook de rol van de opdrachtgevers van het uitzendbureau onderzocht."
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
news.train(:Criminaliteit, tokonized_text)

string = "Het slachtoffer van de schietpartij gistermiddag in  is de in  geboren Haydar Zengin (37). 
Dat bevestigt de politie naar aanleiding van een bericht in Het Parool.
Zengin is een voormalig advocaat die kort geleden ook werkzaam was als tolk en administratief medewerker, schrijft de krant. 
Het is onduidelijk wat het motief is voor de moord.
De man werd doodgeschoten in een bedrijfsruimte aan de  in  . 
Ambulancepersoneel probeerde het slachtoffer nog te reanimeren, maar dat mocht niet meer baten.
Volgens   betrof het een kantoor van een bouwbedrijf, waar Zengin volgens bekenden de administratie deed. 
Over de dader(s) is nog niets bekend. De laatste dodelijke schietpartij in  was een paar maanden geleden."
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
news.train(:Criminaliteit, tokonized_text)

string = "Een vrachtwagen is vrijdagochtend rond 6.50 uur geschaard op de A2 bij  ter hoogte van knooppunt De Hogt. 
De weg richting  was daardoor dicht en moest het verkeer bij knooppunt Batadorp de N2 op. Rond 8.40 uur was de weg weer vrij en de vrachtwagen geborgen.
De wagen stond dwars op de weg en lekte koelvloeistof. Daardoor stonden er files op de A2 en op de A58. 
Rond 11.00 uur is een spoedreparatie begonnen op de plek van het ongeval. Daarom was de rechterrijstrook dicht. 
De reparatie is om 12.30 uur afgerond. Alle rijstroken zijn weer vrij. "
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
news.train(:Ongeluk, tokonized_text)

string = "Een automobilist raakte vanmorgen met zijn auto in het water, toen hij over de N377 reed, tussen De  en .
Mensen die het ongeluk zagen gebeuren, hebben de bestuurder uit de auto gehaald. Hij is naar het ziekenhuis gebracht. Het is onbekend hoe het met hem gaat.
Geen andere inzittenden
Duikers van de brandweer zochten nog naar eventuele andere inzittenden, maar vonden niemand in het water. De brandweer heeft de auto uit het water gehaald. 
Een bergingsbedrijf heeft de wagen vervolgens meegenomen.
Afgesloten
De N377 tussen en  was enige tijd afgesloten na het ongeluk."
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
news.train(:Ongeluk, tokonized_text)

string = "Een automobiliste is vrijdagochtend rond 09.00 uur gewond geraakt bij een botsing met een bestelbusje op de kruising  en de . 
Ze is met een ambulance naar het ziekenhuis gebracht. Het busje wilde de weg oversteken en botste daarbij met de personenwagen van de vrouw. 
De chauffeur van het busje kwam met de schrik vrij. De politie onderzoekt de oorzaak van het ongeluk."
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
news.train(:Ongeluk, tokonized_text)

string = "Dan maar omrijden via het gras, zo moet de buschauffeur hebben gedacht. Het kwam de chauffeur woensdagmiddag duur te staan. 
De Phileas-bus strandde voor de flats aan de , naast de .
De bus zou door een bergingsbedrijf uit het gras zijn getrokken. De gemeente  laat weten dat busmaatschappij Hermes op de hoogte is gebracht van de 
omleidingen in . Zo is de straat  afgesloten en zijn er twee tijdelijke bushaltes aan de .Blijkbaar was dat niet bekend bij de chauffeur, 
aldus een gemeentewoordvoerder. Volgens de gemeente gaat het om een incident en is er geen sprake van een structureel probleem.
Hoe de chauffeur zich precies heeft vastgereden in het grasveld, is nog onbekend."
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
news.train(:Ongeluk, tokonized_text)

string = "Een dronken automobilist is donderdagnacht in de  in  op twee auto's gebotst. 
De 52-jarige vrouw had ruim 4,5 keer de toegestane hoeveelheid alcohol op. De politie heeft haar rijbewijs afgenomen.
Wegrijden
De vrouw probeerde na de botsing weg te rijden. Omstanders verhinderden dat en pakten haar autosleutels af. 
Agenten namen de vrouw mee naar het politiebureau. Tegen haar is proces-verbaal opgemaakt. "
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
news.train(:Ongeluk, tokonized_text)

string = "De politie is op zoek naar een onbekende automobilist die woensdag een fietsster aanreed en gewond achterliet.
Het ongeluk gebeurde op  in . Het slachtoffer, een 67-jarige vrouw uit , meldde zich woensdagavond bij de politie.
Volgens haar was ze rond 20.30 uur aangereden door een achteropkomende auto. Ze was lelijk ten val gekomen tegen een boom. 
De vrouw wist op eigen kracht thuis te komen maar had hoofdletsel en moest voor behandeling naar het ziekenhuis."
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
news.train(:Ongeluk, tokonized_text)

string = "Het is nog een raadsel wat er is gebeurd met de zwaargewonde man die donderdag werd aangetroffen in . 
Op de  in  zagen getuigen dat een auto tegen een paaltje reed en dat er daarna een zwaargewonde man uitstapte. 
Vervolgens ging de nog altijd onbekende automobilist ervandoor.
Toen de politie kort nadat ze gebeld was op de plaats van het incident kwam, was het slachtoffer, een man van 21 uit  al weg. 
Hij bleek door een man van 23 uit  naar een cafetaria in  te zijn gebracht. Daar vroeg de gewonde man om hulp.
Hij is daarna met een ambulance naar het ziekenhuis gebracht. De 23-jarige man uit  is aangehouden. 
Hij wordt ervan verdacht dat hij betrokken is bij het incident waarbij de man gewond raakte.
De politie heeft nog geen idee hoe de man uit  gewond is geraakt. 
Ook wordt er nog altijd gezocht naar de bestuurder van de auto, die is doorgereden."
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
news.train(:Ongeluk, tokonized_text)

string = "Er is donderdagavond rond 23:00 uur een grote brand uitgebroken in een grote loods aan de  in . In de loods stonden 
landbouwmachines opgeslagen. Een daarvan is in brand gevlogen. De loods is compleet afgebrand.
De brandweer had door de inzet van groot materieel de brand snel onder controle. Rond 1:00 uur was de brand onder controle.
Grote rookpluimen trokken over het gebied bij de loods.
Op ongeveer 100 meter afstand bevindt zich een pluimveebedrijf, zover bekend is het bedrijf ongeschonden gebleven."
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
news.train(:Brandweer, tokonized_text)

string = "Er is donderdagavond rond 23:00 uur een grote brand uitgebroken in een grote loods aan de  in . In de loods stonden 
landbouwmachines opgeslagen. Een daarvan is in brand gevlogen. De loods is compleet afgebrand.
De brandweer had door de inzet van groot materieel de brand snel onder controle. Rond 1:00 uur was de brand onder controle.
Grote rookpluimen trokken over het gebied bij de loods.
Op ongeveer 100 meter afstand bevindt zich een pluimveebedrijf, zover bekend is het bedrijf ongeschonden gebleven."
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
news.train(:Brandweer, tokonized_text)

string = "Bij een brand in een garagebox aan de  in ,  rond  , is asbest vrijgekomen. Dat heeft de brandweer bevestigd.
De asbest heeft zich niet verder verspreid dan het terrein van de eigenaar van de garagebox. 
Die is volgens de brandweer dan ook verantwoordelijk voor de verwijdering van de asbest. 
De brandweer heeft de gemeente in kennis gesteld van de besmetting, zodat deze kan toezien op correcte verwijdering. 
Bij de brand werd ook de personenauto die in de garagebox stond, beschadigd."
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
news.train(:Brandweer, tokonized_text)

string = "Tijdens graafwerkzaamheden in de  in  is maandagochtend rond 10 uur een gaslek ontstaan in de aansluiting van een woning.
De monteurs van Endinet repareren het lek. De mensen in de woning hebben maandag weer gewoon gas, volgens een woordvoerder van Endinet."
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
news.train(:Brandweer, tokonized_text)

string = "In de  aan de  in  is vrijdagochtend een korte brand geweest. Het pand wordt bewoond via een antikraak regeling. 
De bewoners zijn ongedeerd. De brand is geblust en de brandweer is bezig met ventileren van de kerk. Ook wordt onderzocht of het gebouw veilig is voor bewoning. 
De oorzaak van de brand is nog niet bekend. "
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
news.train(:Brandweer, tokonized_text)

string = "Bij een bedrijfsongeval op een terrein aan de  in  is een 51-jarige man uit  om het leven gekomen. 
De brandweer werd rond half elf opgeroepen omdat de man bekneld was komen te zitten.
Onderzoek
Wat er precies is gebeurd is nog niet duidelijk, de arbeidsinspectie en de technische recherche doen onderzoek."
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
news.train(:Brandweer, tokonized_text)

string = "De brandweer is vanmiddag te hulp geroepen bij het onderzoek naar een vreemde lucht die rondhangt in een bedrijfspand van   aan de  in . 
Het bedrijfspand is uit voorzorg ontruimd. De medewerkers staan buiten, terwijl de brandweer het gebouw ventileert. 
Het is nog niet duidelijk wat de oorzaak is van de scherpe stank in het bedrijf."
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
news.train(:Brandweer, tokonized_text)

string = "De hulpdiensten hebben de doorgaande  in de  wijk  donderdagavond tijdelijk afgesloten vanwege een brand in een  restaurant.
De brand was rond 21.50 uur in de afzuiginstallatie van het restaurant ontstaan. Bewoners van de bovenliggende woningen moesten hun huizen uit. 
De brandweer had de brand snel onder controle. Nadat de brand was geblust en de panden geventileerd, mocht iedereen weer hun woning in en werd de weg weer opengesteld."
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
news.train(:Brandweer, tokonized_text)

string = "Een automobiliste is vrijdagochtend rond 09.00 uur gewond geraakt bij een botsing met een bestelbusje op de kruising  en de . 
Ze is met een ambulance naar het ziekenhuis gebracht. Het busje wilde de weg oversteken en botste daarbij met de personenwagen van de vrouw. 
De chauffeur van het busje kwam met de schrik vrij. De politie onderzoekt de oorzaak van het ongeluk."
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
news.train(:Ambulance, tokonized_text)

string = "Het slachtoffer van de schietpartij gistermiddag in  is de in  geboren Haydar Zengin (37). 
Dat bevestigt de politie naar aanleiding van een bericht in  .
Zengin is een voormalig advocaat die kort geleden ook werkzaam was als tolk en administratief medewerker, schrijft de krant. 
Het is onduidelijk wat het motief is voor de moord.
De man werd doodgeschoten in een bedrijfsruimte aan de  in  . 
Ambulancepersoneel probeerde het slachtoffer nog te reanimeren, maar dat mocht niet meer baten.
Volgens  betrof het een kantoor van een bouwbedrijf, waar Zengin volgens bekenden de administratie deed. 
Over de dader(s) is nog niets bekend. De laatste dodelijke schietpartij in  was een paar maanden geleden.
"
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
news.train(:Ambulance, tokonized_text)

string = "Aan de  in   is maandag iemand gewond geraakt bij sloopwerkzaamheden wegens asbest.
De persoon viel waarschijnlijk door het dak. Het is nog onduidelijk wat er precies is gebeurd.
Ontsmet
De brandweer heeft de kleding van de gewonde persoon uit voorzorg ontsmet. De gewonde is met een ambulance naar  gebracht."
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
news.train(:Ambulance, tokonized_text)

string = "De politie is op zoek naar een onbekende automobilist die woensdag een fietsster aanreed en gewond achterliet.
Het ongeluk gebeurde op  in . Het slachtoffer, een 67-jarige vrouw uit , meldde zich woensdagavond bij de politie.
Volgens haar was ze rond 20.30 uur aangereden door een achteropkomende auto. Ze was lelijk ten val gekomen tegen een boom. 
De vrouw wist op eigen kracht thuis te komen maar had hoofdletsel en moest voor behandeling naar het ziekenhuis."
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
news.train(:Ambulance, tokonized_text)

string = "Bij een bedrijfsongeval op een terrein aan de  in  is een 51-jarige man uit  om het leven gekomen. 
De brandweer werd rond half elf opgeroepen omdat de man bekneld was komen te zitten.
Onderzoek
Wat er precies is gebeurd is nog niet duidelijk, de arbeidsinspectie en de technische recherche doen onderzoek."
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
news.train(:Overlijden, tokonized_text)

string = " heeft met grote verslagenheid kennis genomen van het overlijden van  . De moeder van   stierf afgelopen weekeinde zeer plotseling, 
Het overlijden van  kwam  onverwacht snel. Zij stierf na een kort ziekbed.
, die  de gewonnen topper tegen miste, en krijgen van alle ruimte en steun om de ingrijpende gebeurtenissen met hun te verwerken. ,,
We zijn natuurlijk erg geschokt door deze treurige berichten, zegt trainer  . ,,We leven met  en  mee en proberen hen waar mogelijk te helpen en te steunen."
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
news.train(:Overlijden, tokonized_text)

string = "Het slachtoffer van de schietpartij gistermiddag in  is de in  geboren Haydar Zengin (37). 
Dat bevestigt de politie naar aanleiding van een bericht in  .
Zengin is een voormalig advocaat die kort geleden ook werkzaam was als tolk en administratief medewerker, schrijft de krant. 
Het is onduidelijk wat het motief is voor de moord.
De man werd doodgeschoten in een bedrijfsruimte aan de  in  . 
Ambulancepersoneel probeerde het slachtoffer nog te reanimeren, maar dat mocht niet meer baten.
Volgens   betrof het een kantoor van een bouwbedrijf, waar Zengin volgens bekenden de administratie deed. 
Over de dader(s) is nog niets bekend. De laatste dodelijke schietpartij in  was een paar maanden geleden."
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
news.train(:Overlijden, tokonized_text)

string = "Een grote groep jongeren dreigt de stille tocht voor de dood gevonden baby in  te verstoren met een vechtpartij. 
De burgemeester heeft een noodbevel afgekondigd.
Precies een jaar geleden was er een grote vechtpartij tussen jongeren in . 
De gemeente laat weten via sociale media signalen te hebben ontvangen dat er vanavond, precies tijdens de stille tocht, een 'reunie' van de vechtpartij 
zou gaan plaatsvinden. 
Volgens de gemeente bestaat er een 'reele mogelijkheid' dat de jongeren de stille tocht gaan verstoren. Vorige week werd er in de 
  een dode baby in een schuur gevonden. 
Een noodbevel is een vergaande maatregel die door een burgemeester kan worden ingezet bij ernstige wanordelijkheden. Het geeft de 
burgemeester het recht om alle maatregelen te nemen om problemen te voorkomen.  
Burgemeester   van  is vanavond bij de stille tocht aanwezig.   zendt de stille tocht vanavond vanaf 19.00 uur live uit."
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
news.train(:Overlijden, tokonized_text)

string = "De vrouw die dinsdag dood werd aangetroffen in Hotel  in , was een moeder van drie kinderen uit het  . 
De 27-jarige   overleed aan een combinatie van speed en alcohol. Dat meldt   was moeder van een zoontje van acht en een tweeling 
van tweeenhalf jaar oud. Haar omgeving heeft volgens het blad met ongeloof gereageerd op haar dood. Ik heb  nooit overmatig zien drinken en ik heb ook 
geen weet van drugs, aldus haar vriendin in de  van .   was een lieve vriendin, die altijd klaarstond voor alles en iedereen. 
Ze was heel sociaal, had veel vrienden en vriendinnen, vertelt de vriendin verder. Ik heb ook vele keren op de tweeling opgepast, ik kan je 
verzekeren dat ze een goede moeder was.
 arriveerde tussen 04.00 uur en 05.00 uur met twee vriendinnen bij het hotel en ging naar bed. Bij controle van de kamers door een hotel-medewerker 
de volgende ochtend, werd het stoffelijk overschot gevonden. De recherche heeft de zaak onderzocht. Er is geen sprake van een misdrijf."
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
news.train(:Overlijden, tokonized_text)

string = "In een huurappartement aan de  in  is vrijdag aan het begin van de middag een dode gevonden. Het slachtoffer, 
een man, is door geweld om het leven gebracht. Er is op een andere locatie een 56-jarige verdachte aangehouden, bevestigt de politie aan . 
Het gaat vermoedelijk om de bewoner van het huis. Voor de politie zijn er vooralsnog geen aanwijzingen dat er een verband bestaat tussen het vele, 
recente (schiet)geweld in de regio.
Het gaat om het derde slachtoffer in  in twee dagen dat door een misdrijf om het leven is gekomen. In  gaat het zeer waarschijnlijk 
om een misdrijf in de relationele sfeer.
Overlast in appartement
Volgens buurtbewoners is het slachtoffer 36 jaar en een vriend van de opgepakte bewoner. Hij verbleef de afgelopen jaren regelmatig in het huis, 
sindsdien is de overlast in het huis toegenomen. Er zou regelmatig sprake zijn van harde muziek, drugsincidenten en vechtpartijen. De bewoner is 
volgens bronnen een drank- en drugsverslaafde die voor veel overlast zorgt in de buurt.
De politie was naar het appartementencomplex gegaan na een melding dat er iemand door een misdrijf was overleden. Op de tweede verdieping werd een voordeur 
geforceerd waarna agenten het levenloze lichaam aantroffen.
Rumoerige week in 
Het is een rumoerige week in . Donderdag werden twee vermoorde mannen gevonden in een vakantiehuisje tussen . 
Daarvoor werd  in een dag opgeschrikt door twee schietincidenten.
In  werd een neergeschoten man van vermoedelijk  komaf door onbekenden gedropt in het  Ziekenhuis. Rond hetzelfde tijdstip werd 
een 46-jarige  in het huis van zijn moeder neergeschoten. Opvallend: beide mannen weigeren te vertellen wat er is gebeurd."
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
news.train(:Overlijden, tokonized_text)

string = "De 400-meterbaan en de krabbelbaan van de  IJsbaan in  zijn tot en met vrijdag 23 oktober gesloten door een probleem met de 
ijsinstallatie.
Nadat de installatie is gerepareerd, moet er opnieuw ijs worden aangemaakt. Tot die tijd gaan alle activiteiten zoals trainingen, 
lessen en wedstrijden niet door, meldt de schaatsbaan op de website.
De IJsbaan, die net een paar dagen open was, zegt de storing te betreuren."
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
news.train(:Sport, tokonized_text)

string = "De openingstijdrit van de Ronde van start in sportcomplex  in. Van daaruit moeten de renners kilometer tegen de klok rijden, zo maakte de organisatie maandag bekend.
De organisatie doet in het parcours uit de doeken, al was er al veel bekend. Zo was al duidelijk dat er in het begin drie etappes zijn in. 
Op vrijdag is de tijdrit, daarna volgen twee ritten door de  provincie: van  naar  op en een dag later in omgekeerde richting.
In de tweede etappe van kilometer kunnen de renners een gooi doen naar de eerste bergpunten. 
Een klimmetje naar is gecategoriseerd als een helling. De dag erna is de de enige klim in het parcours van  kilometer. 
Beide etappes lijken een prooi voor de sprinters.
Na de eerste drie dagen op bodem vliegen de renners op naar . Daar gaat de wedstrijd op verder. De eerste echte bergetappe volgt op donderdag, met finish in . 
Daarna volgt een hele reeks heuvelachtige ritten, een tijdrit in van ruim kilometer en nog een kans voor de sprinters in de twaalfde etappe.
Etappe veertien van naar geldt als de koninginnenrit van de Giro, met liefst zes beklimmingen met toppen boven de meter. Alsof dat niet zwaar genoeg is, 
krijgen de renners in etappe  een bijna kilometer lange klimtijdrit naar  voorgeschoteld.
Het klassement wordt pas bepaald in de laatste dagen van de Ronde van. Etappe voert van naar het   en bevat onder meer het dak van de ronde: 
de meter hoge . Ook rit twintig, met drie zware beklimmingen in slechts kilometer en met een kort klimmetje naar de finish is voer voor de grote klassementsmannen.
Op   eindigt de ronde met een vlakke rit naar ."
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
news.train(:Sport, tokonized_text)

string = "De mannen uit staan nu op de tweede plek in de eerste klasse F. 
'Laat maar, dit wordt niks'
Na een halfuur spelen keken de mannen van trainer  tegen een 2-0 achterstand aan. Vlak voor rust scoorde   waardoor de ploeg uit   met een 2-1 de rust in ging. 
In de eerste minuut na de rust scoorde de tegenstander direct de 3-1. Ik had zes momenten in de wedstrijd dat ik dacht: 
'laat maar, dit wordt niks', maar even later scoorden we de 3-2, zegt. Het tweede doelpunt van  werd door   binnen geschoten. 
In de slotfase van de wedstrijd scoorde  nog drie keer.   wist nogmaals het net te vinden en de andere twee doelpunten werden door   gemaakt. 
'Zo'n wedstrijd heb ik nog nooit meegemaakt'
Ik loop al zeven jaar mee als trainer, zegt trainer  . Maar zo'n wedstrijd heb ik nog nooit meegemaakt. 
We hadden de eerste elf minuten vijf kansen gehad, maar niet gescoord. Voor de vijf gemaakte doelpunten hadden we vijftien kansen nodig. 
 heeft zes kansen gehad, en scoorden daaruit drie keer. Hun rendement lag veel hoger."
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
news.train(:Sport, tokonized_text)

string = "VELDRIJDEN - De organisatie van de Superprestige veldrit van  noemt het flauw en jammer, de diskwalificatie van veldrijder  van .
Notobene z'n eigen sponsor , die verantwoordelijk is voor de tv-registratie van de Superprestige, had op de fiets Van  een camera gemonteerd voor beelden 
tijdens de live-uitzending. 
UCI
Maar omdat dit vooraf niet gemeld was bij de internationale wielrenunie UCI werd Van  gediskwalificeerd.
Jammer
Volgens de letter van de wet kon de man van de UCI niks anders doen. Maar we laten ons als organisatie toch horen, want het is zo jammer. 
Bij het mountainbiken zie je ook al volop camera's. Van wordt nu de dupe van de regeltjes van de UCI, aldus voorzitter   van de  organisatie.
Van  finishte als twaalfde. De overwinning ging naar  van ."
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
news.train(:Sport, tokonized_text)

string = "is een van de favorieten voor de overwinning tijdens de  DLL Marathon Eindhoven.
 werd in  derde in de prestigieuze  Marathon en scherpte daar zijn persoonlijke record aan tot uur.
Daarmee heeft  de snelste tijd van de toplopers in  achter zijn naam staan. Hij gaat zondag de strijd aan met sterke  als."
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
news.train(:Sport, tokonized_text)

string = "verzorgt op  een openbare spiritualiteitavond in de Yogastudio op in. De bijeenkomst duurt van"
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
news.train(:Overig, tokonized_text)

string = "Wielrenner Johnny Hoogerland kan het zich niet voorstellen:  zonder profkoers. 
De toekomst van de Ronde van , de enige  wedstrijd voor professionals, hangt aan een zijden draadje. 
De wedstrijd heeft voor mij historische waarde, aldus de renner van  Oranje Peloton.
'Erg zonde'
Ik ken de wedstrijd nog als Ronde van . Als klein jongetje in  stopte ik altijd met voetballen als de wedstrijd langskwam. 
Het zou heel erg zonde zijn als de ronde verdwijnt, vertelt Hoogerland.
Schitterende koers
Dat de Ronde van  onder druk staat, komt voor Hoogerland niet als een verrassing. Vroeger was de Ronde van 
 een van de grootste wedstrijden van . Ze zijn wel minder belangrijk geworden. Hoe dat precies komt, 
weet ik niet. Misschien door de World Tour..Toch blijft het een schitterende koers."
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
news.train(:Sport, tokonized_text)

string = "  volgt   op als coach van . De 46-jarige  was de coach van de rookies en assistent van . 
Dat meldt het  .
Het bestuur van  heeft  de doelstelling meegegeven om in  de playoffs te halen. 
 speelde ruim vijfhonderd wedstrijden in de honkbal hoofdklasse. Ook kwam hij enige tijd uit voor de Philladelphia Phillies in de  . "
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
news.train(:Sport, tokonized_text)

string = "Het duurt nog wel even voordat Alireza Jahanbakhsh honderd procent fit is en volledig inzetbaar. 
Dat zegt AZ trainer John van den Brom voorafgaand aan het duel zaterdag met Cambuur Leeuwarden.
We hebben elke week dezelfde discussie en we moeten het maar even laten. Hij is aan het terugkomen, zegt de trainer die  elke dag 
ziet meetrainen met de eerste selectie. Hij traint goed mee maar heeft steeds last van een terugslag na wedstrijdbelasting. 
Hij doet ook aan extra individuele training. We komen uiteindelijk wel met hem daar waar we willen.
Voor het duel met Cambuur is naast  ook Jan Wuytens er niet bij. In het oefenduel in  viel hij uit. Hij traint apart.
Overigens speelt AZ met dezelfde elf tegen Cambuur als twee weken geleden tegen FC Twente: Never change a winning team."
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
news.train(:Sport, tokonized_text)

string = "In de Jupiler League speelt Telstar in Venlo tegen VVV. De hockeymannen van  ontvangen Oranje Zwart.  Sport is er live bij!
De Witte Leeuwen beginnen om acht uur aan hun uitwedstrijd tegen VVV. De ploeg uit  staat er beter voor op de ranglijst dan Telstar: 
tien plaatsen hoger en acht punten meer na negen wedstrijden. Maar dat is scorebordjournalistiek. Hoe de verhoudingen op het veld liggen, 
hoor je van verslaggever .
Lees verder: Telstar-speler Ajnane start in tegen VVV-Venlo
FC Volendam komt zondag in actie in de uitwedstrijd tegen MVV. Jong Ajax speelt maandag thuis tegen Almere City FC.
In de hoofdklasse hockey een inhaalduel op topniveau:  speelt thuis tegen Oranje Zwart. De winnaar van het duel klimt naar 
de koppositie van de hoofdklasse. Het duel begint om half negen en het wedstrijdcommentaar krijg je van  . "
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
news.train(:Sport, tokonized_text)

string = "PSV hoopt dat het herstel van Luuk de Jong zo snel gaat dat hij tijdens het volgende duel van de club, volgende week zaterdag, 
weer van de partij is. PSV speelt over twaalf dagen tegen Excelsior.
Cocu rekent niet op Luuk de Jong in duel PSV tegen CSKA Moskou
Mogelijk kan De Jong dan weer een aantal minuten maken, maar dat is wel afhankelijk van de manier waarop zijn revalidatie verloopt. 
Jetro Willems en Florian Jozefzoon hebben nog wat meer tijd nodig voordat ze voor PSV 1 beschikbaar zijn. 
Zij zullen allebei vermoedelijk eerst bij Jong PSV beginnen."
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
news.train(:Sport, tokonized_text)

string = "De aanklager van de KNVB gaat een vooronderzoek instellen naar de duw in het gezicht van 
Feyenoord-spits   bij  van de , zondag tijdens het duel met De Graafschap.
De actie van  werd bij  Sports duidelijk in beeld werd gebracht, maar arbiter   had het voorval niet gezien en liet de actie onbestraft. 
 kan op basis van de tv-beelden in staat van beschuldiging worden gesteld. Dat kan hem mogelijk een schorsing opleveren.
 mocht na afloop van Feyenoord niet met de pers praten. Verdediger  de  van De  wel. ,,
  had een rode kaart moeten krijgen. Hij raakte mij in mijn gezicht en volgens mij moet je daar vanaf blijven.''
De clubs, betrokken spelers, aanvoerders en officials zijn om een verklaring gevraagd. Die moeten voor  binnen zijn. 
Als  voor drie duels of meer wordt geschorst, mist hij het bekerduel met Ajax. De Klassieker wordt op in De Kuip afgewerkt.
Ook  te  moet een schorsing vrezen. De Heerenveen-spits zou net als  een slaande beweging hebben gemaakt richting tegenstander  van Heracles Almelo."
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
news.train(:Sport, tokonized_text)

string = "De aangekondigde kortingen op de Bibliotheek  en Keramiekcentrum  zijn zo goed als zeker van de baan. 
De  gemeenteraad geeft aan die bezuiniging niet te accepteren.
 wil de  oplopend naar 2017 korten met 50.000 euro. 
Bibliotheek  krijgt te maken met een eerder uitgestelde bezuiniging van 100.000 euro. 
Beide instanties gaven al aan die kortingen niet op te kunnen vangen.
Niet straffen
De  doet het goed en groeit uit het jasje. Daar moeten we het museum niet voor straffen, 
zegt VVD-fractievoorzitter . GroenLinks-fractievoorzitter   wijst op de toezegging van het  
college dat er de komende jaren niet meer op cultuur gekort zou worden.
Over de vraag op welke manier de kortingen teruggedraaid moeten worden, verschillen de verschillen de verschillende partijen nog van mening."
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
news.train(:Politiek, tokonized_text)

string = "De NAVO heeft tijdens een bijeenkomst in gemaand te stoppen met het schenden van het luchtruim van .  meldde eerder op de dag dat een  gevechtsvliegtuig, 
een Sukhoi SU-30, zijn luchtruim boven de provincie  was binnengevlogen. Het toestel had even daarvoor een dorp net over de grens in  gebombardeerd. 
Het vliegtuig is maar een paar seconden in  geweest, zegt .
De  minister van Buitenlandse Zaken heeft verscheidene NAVO-collega's gebeld na de schending van het luchtruim door een  gevechtsvliegtuig. 
Dat was  in de  provincie  ten noorden van de  haven , meldden de  autoriteiten . De minister,  , heeft ook zijn  collega   gebeld om te protesteren.
 heeft  NAVO-chef   ontmoet. Die noemde de schending onacceptabel en beklemtoonde dat de veiligheid van  een taak van de NAVO is.  
 roept de NAVO-raad deze week snel bijeen. Volgens  diplomaten komen ze   al bij elkaar.  hebben de ministers van Defensie van het bondgenootschap een 
 vergadering in , maar die werd niet vanwege dit incident gepland. 
Navigatiefout 
Een  vliegtuig van het type Sukhoi Su-30 schond het  luchtruim toen het een dorp aan de  grens bombardeerde. 
 heeft maandag bekendgemaakt dat er twee F-16's op af zijn gestuurd. De  ambassadeur in ,  , is op het matje geroepen. 
  heeft hem laten weten dat dit niet nog een keer mag gebeuren.
Het ging volgens  om een vliegtuig dat door een navigatiefout  minuten boven  grondgebied vloog. 
Het toestel vloog heel dicht bij de  grens, aldus de . Dat was circa  kilometer ten noorden van . Volgens  meldingen vloog het  toestel boven de provincie  
op een gegeven moment meer dan  kilometer van de grens.
Het gevechtsvliegtuig vloog slechts enkele seconden in het  luchtruim, zegt het  ministerie van Defensie in  .
Luchtafweer 
 is sinds  lid van het drie jaar daarvoor opgerichte NAVO-bondgenootschap. Dat stelt zich ten doel het gezamenlijke grondgebied samen te verdedigen wanneer 
 dat waar dan ook word bedreigd of aangevallen.  had in het kader van de NAVO van begin  tot begin  in de  provincie , circa  kilometer ten noorden van , 
 Patriot-luchtafweer gestationeerd.  wilde extra bescherming uit vrees voor raketten uit het strijdgewoel in .
 is afgelopen week begonnen met luchtaanvallen in  om de uitgeputte troepen van de  regering van president  te helpen."
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
news.train(:Politiek, tokonized_text)

string = "  is door commissaris van de Koning   aangesteld als waarnemend burgemeester van . 
VVD'er   was gedeputeerde voor de provincie . Daarvoor was hij vier jaar burgemeester van . 
Op dit moment is hij lid van de Provinciale Staten in . De 41-jarige  was toen Nederlands jongste burgemeester. 
Opvolger van   
 volgt oud-burgemeester op. Hij legde op 22 september zijn functie neer, omdat hij verdacht werd van het stelen van geld. 
Hij heeft daar inmiddels al een boete voor betaald. 
Aankomende dinsdag begint  met zijn werkzaamheden in . In overleg met de gemeenteraad heeft de Commissaris van de 
Koning besloten dat het om een waarnemend burgemeesterschap voor langere tijd gaat."
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
news.train(:Politiek, tokonized_text)

string = "Het kan nog wel een jaar duren voordat het bedrijf de whisstone, een vinding van de  onderneming, op grote schaal kan toepassen. 
Tenminste, dat is de verwachting. Het duurt allemaal langer door regelgeving in . Misschien dat Kamervragen van het CDA over de vinding het 
proces kunnen versnellen. Directeur  de  hoopt het. 
De whisstone is een methode om verkeerslawaai te beperken door een betonnen strook met diepe groeven langs de weg. 
Uitleggen hoe het precies werkt, is nog niet zo eenvoudig maar in grote lijnen is het dan weer vrij simpel. Het geluid weerkaatst in de groeven heen 
en dan ontstaat een weerstand waardoor het lawaai omhoog wordt geduwd, vertelt De . Over huizen heen bijvoorbeeld waardoor de lawaaioverlast een stuk minder is.
 De whisstone zou een mooi alternatief kunnen zijn voor geluidsschermen die vaak als lelijk worden ervaren. 
Lobbyen
Maar het mooie is dat ons systeem ook in combinatie met andere maatregelen kan worden toegepast, vertel De . 
Een geluidsreductie door een geluidswal, normaal goed voor , kan met het systeem van  met  extra worden opgekrikt. 
Klinkt allemaal heel mooi maar het systeem kan door allerlei regels nog niet worden toegepast. Voor alles is goedgekeurd, 
zijn we al weer een jaar verder verwacht De . Op allerlei manieren is hij aan het lobbyen om daar verandering te krijgen. 
Kamervragen
Kamerlid  van  van het CDA hoorde zijn verhaal tijdens het door de provincie georganiseerde Prinsjesfestival in Den Haag. 
Hij stelt er nu Kamervragen over. Het Kamerlid wil graag van de minister van Infrastructuur en Milieu weten waarom regelgeving de toepassing van de 
de whisstone in de weg staat, terwijl uit pilots is gebleken dat het een efficiente oplossing is tegen geluidsoverlast. 
De  is uiteraard blij met de aandacht voor zijn vinding in de Tweede Kamer. Innovatie is de toekomst, hoor je telkens, maar zorg dan ook dat je de regels 
daar op aanpast."
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
news.train(:Politiek, tokonized_text)

string = "Minister Plasterk vindt het afschuwelijk dat politici bedreigd worden vanwege de komst van asielzoekerscentra. Dat zei hij tegen de NOS vandaag. 
Hij reageert daarmee op verschillende incidenten in het land, waaronder in .
Naar aanleiding van de opvang van vluchtelingen in een sporthal van de gemeente  is burgemeester   per brief met de dood bedreigd. 
Ook wordt in de brief, die gisteren bezorgd werd bij  , gewaarschuwd voor een aanslag op het gemeentehuis. Maar ook in de  gemeente 
 werden politici bedreigd vanwege de opvang van vluchtelingen.
Volgens Plasterk worden de bedreigingen als maar meer en heftiger. Hij vindt dat onacceptabel. 'Blijf met je tengels van onze politici en hou ze in ere', 
aldus de minister. In alle gevallen is er volgens Plasterk aangifte gedaan. Ook benadrukt hij dat het Openbaar Ministerie bij dit soort bedreigingen een 
hogere straf eist."
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
news.train(:Politiek, tokonized_text)

string = "De gemeente  wil een groot aantal vluchtelingen opvangen in een tentenkamp in . Het gaat om noodopvang voor maximaal 
400 vluchtelingen. Het tentenkamp komt op het voormalige , iets ten zuiden van de hal waar eerder al vluchtelingen werden opgevangen. 
Het tentenkamp gaat mogelijk nog voor kerst open en blijft minstens een half jaar staan. 
De gemeente wil voordat er een definitief besluit wordt genomen over de opvang eerst in gesprek met omwonenden. 
De inwoners van  mogen dan hun mening geven over de veiligheid van de noodopvang, bereikbaarheid, onderwijs, zorg en dagbesteding. 
 zal de tweede  plaats worden met een tentenkamp voor vluchtelingen. In  worden sinds begin deze maand ongeveer 
500 vluchtelingen opgevangen. "
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
news.train(:Politiek, tokonized_text)

string = "We gooien in  per jaar 2470 ton aan bloembollen weg. Dat is ruim 82 vrachtwagens vol. Doodzonde, vindt   uit . 
Hij gaat er wat aan doen. Zijn missie: een 'bloemenstorm' die over  raast.
De logistiek manager, zoon van een bollenkweker, kwam op het idee toen hij las over , een initiatief om voedselverspilling tegen te gaan. 
Zoiets kan ik ook, dacht  en hij richtte met zijn vrouw  het bedrijf  op.
Het idee is simpel.  koopt overschotten bloembollen op en plant deze in bloembakken van duurzaam steigerhout. 
Die bieden we aan aan het bedrijfsleven. Tegen betaling zetten we die bakken bij hun voor de deur. Zo hebben ze het hele jaar rond kleur voor de deur, 
legt  uit aan  . 
Omdat het aanbod afhangt van het overschot, krijgen klanten telkens andere bloemen. Vier keer per jaar worden de bloembakken omgeruild voor bakken met 
een andere bloem. Krokussen, sneeuwklokjes, narcissen, tulpen, dahlia's, begonia's: alles komt een keer langs. 
Lees ook:  boycot  bloemen nekslag kwekers: Het zou desastreus zijn
De ondernemer heeft zijn eerste klanten inmiddels binnen. Hoewel de eerste bakken pas begin volgend jaar bij hun voor de deur worden geplaatst, 
staat  al volop in de picture. Het bedrijf is genomineerd voor de Wereldprijs van  , een prijs voor duurzame initiatieven. 
Op 19 november wordt bekendgemaakt wie de winnaar is.  lachend: We hopen dat wij uiteindelijk met de bloemen in onze handen staan."
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
news.train(:Economie, tokonized_text)

string = "De Belastingdienst heeft het faillissement aangevraagd van . legde de fiscus in , , beslag op de inventaris omdat het  nog een schuld heeft van  euro. 
Het  had tot de tijd gekregen om de schuld te betalen.
 kwamen er vrachtwagens naar het terrein waar het circus zijn tenten had opgeslagen om de spullen weg te halen. 
 Alleen de woonverblijven van de medewerkers bleven staan. Directeur had weinig begrip voor de actie. 
 Er wordt ons de nek omgedraaid. Ik weet wel dat er belasting betaald moet worden, maar dan moeten ze ons ook wel de tijd geven. 
 Maar nu zijn we ten dode opgeschreven.
Het heeft een plan ingediend om de schuld weg te kunnen werken, maar dat was niet voldoende. We zijn daarom tot beslaglegging overgegaan, 
aldus een woordvoerder van de Belastingdienst. Het circus had al een maand uitstel gekregen. 
Via een werd 15.000 euro opgehaald, maar daarmee kon niet de hele schuld worden afgelost.
De rechter moet nog wel het faillissement uitspreken, maar met het verdwijnen van het  zullen 65 mensen hun baan verliezen.
Dit is volledig tegen de afspraken in. We hebben steeds medewerking gekregen van de Belastingdienst in, 
maar nu stonden ze ineens vanochtend hier op de stoep om alles in beslag te nemen.
We worden ook gezien als vluchtgevaarlijk. Ik voel me als een kip met een bacterie die geruimd moet worden. Dit is alles wat ik heb. 
Ik kan alleen nog maar hopen op een wonde, aldus.
De financiele problemen zijn ontstaan door tegenvallende bezoekersaantallen en een verhoogde lastendruk. 
Het circus moet bijvoorbeeld extra premie betalen omdat het werkt met seizoenskrachten. 
Daarbij zijn door de overheid beperkingen gesteld aan het gebruik van goedkope rode diesel,
waardoor het voor zijn generatoren meer geld aan brandstof kwijt is."
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
news.train(:Economie, tokonized_text)

string = "gaat , tot nog toe bestuursvoorzitter van het Universitair Medisch Centrum, benoemen tot medisch directeur.
Dat maakte het concern maandag bekend. De nieuwe manager gaat mede de strategische focus bepalen op de medische markten die Philips wil bedienen.
De  stopt per bij het Utrechtse ziekenhuis en treedt per in dienst van Philips. Hij zal rechtstreeks aan topman  van  rapporteren, zo deelde het bedrijf mee.
Philips werkt in veel projecten samen met het internationaal bekende en innovatieve ziekenhuis. Volgens Van  kan  helpen bij de transformatie die 
de zorgindustrie momenteel doormaakt naar betere uitkomsten voor patienten tegen lagere kosten."
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
news.train(:Economie, tokonized_text)

string = "in is failliet. De had drie vestigingen. Naast die in de  in , waren er winkels in  en .
Op het raam van de winkel in  hangt een briefje dat deze 'wegens omstandigheden' gesloten is.
 is niet de eerste   die afgelopen tijd in de problemen kwam. In augustus ging   failliet. 
 De  had vestigingen in , ,  en  en een  op bedrijfsterrein  in . 
De  van   maakte een doorstart."
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
news.train(:Economie, tokonized_text)

string = "Hotel in  wordt een zorgresidentie. Het hotel gaat daarvoor een samenwerking aan met zorggroep .
van de  kamers in het hotel worden omgebouwd tot appartementen voor ouderen. We willen dat de ouderen hier kunnen blijven leven zoals ze gewend waren, 
zegt eigenares   van Hotel . Wij verzorgen ontbijt, lunch en diner, doen de was en organiseren activiteiten.
Witte vlekken
Zorggroep  levert zorg aan de bewoners van de residentie. Volgens  is dit is een uniek concept in . In  is een accommodatie die dit aanbiedt, 
 en  zijn nog witte vlekken.
Vijf kamers over
Er blijven nog vijf hotelkamers in  beschikbaar voor andere gasten. Ook de horeca blijft voor iedereen toegankelijk. Het is niet zo dat het slecht met het hotel ging,
zegt . Ik ben gewoon altijd geinteresseerd geweest in zorg.
Appartementen in  zijn beschikbaar vanaf  euro per maand, afhankelijk van de faciliteiten die mensen willen. Op  en  houdt het hotel inloopmiddagen, 
waar belangstellenden meer informatie kunnen krijgen."
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
news.train(:Economie, tokonized_text)

string = "In 2020 heeft de gemeente  6000 meer vacatures te vullen dan nu. Om die opdracht tot een goed einde te brengen komt de gemeente met een banenplan. 
Dat het een hele klus wordt, daar zijn ze zich in  van bewust. Doel is geen talent onbenut te laten. 
Meer banen voor meer mensen, heet het plan. We moeten uit gaan van de kracht van mensen, legt wethouder De  hoe de gemeente mensen die nu om 
welke reden dan ook werkloos zijn, weer aan het werk te krijgen. Wat je kunt is belangrijker dan wat je niet kunt.
Jobcoaching
De  denkt aan intensieve begeleiding van mensen in de vorm van bijvoorbeeld jobcoaching, maar de gemeente zal ook in gesprek moeten met werkgevers. 
Wij hebben intussen al zo'n 100 tot 150 bedrijven gesproken.
De  merkte in die gesprekken dat bedrijven voldoende flexibel zijn om mee te denken met de gemeente. Ik zeg niet dat het gemakkelijk gaat worden. 
Dat heeft onder meer te maken met het beschikbare geld om die begeleiding aan mensen te bieden. We moeten het doen met de middelen die we hebben en ik 
kan zeggen: dat is niet veel. Het beste zou zijn dat we mensen aan het werk krijgen. Dan zorgen ze voor zichzelf.
Nu investeren
Het is in ieder geval een voordeel dat  de wind economisch weer mee heeft.  is altijd wel een sterke economische regio geweest, 
maar er komt nog wel een boel op ons af. En daarom is het belangrijk dat we nu investeren, zodat we zometeen niet een boel banen beschikbaar hebben, 
maar geen mensen.
Wethouder De  zal zelf ook actief bijdragen aan het begeleiden van mensen naar een andere baan. Mijn collega  van arbeidsmarkt en 
ik worden ook beiden buddy van een aantal werkzoekenden. Op die manier kunnen de wethouders die werkzoekenden helpen met bijvoorbeeld het een aanboren van een netwerk."
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
news.train(:Economie, tokonized_text)

string = "Bedrijven in de regio  krijgen met een grote strop te maken als Rijkswaterstaat in 2017 groot onderhoud pleegt aan de sluizen van het  
bij  en .
Door het onderhoud is het  naar verwachting 35 dagen onbruikbaar. Het is de enige route voor bedrijven die producten via het water aan- en afvoeren 
in ,  en . Verladersorganisatie EVO en Port of  vrezen een schadepost van 6 miljoen euro als Rijkswaterstaat er niet in slaagt om 
de stremming van het kanaal zo kort mogelijk te houden.
Het onderhoud aan de sluizen is noodzakelijk. Rijkswaterstaat wil de werkzaamheden beperken tot 16 uur per dag. De organisaties pleiten voor een 24-uurs werkdag.
 een binnenvaartknooppunt voor het achterland. De    slaat containers over voor tientallen bedrijven in het oosten van  en .
Omdat ook deze bedrijven hun productieproces hierop moeten aanpassen, loopt de totale schade bij langer onderhoud snel hoog op."
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
news.train(:Economie, tokonized_text)

string = "Voor de tweede dag op rij gaat  fors onderuit op de beurs in .
Het aandeel van het winkelbedrijf uit  stond vrijdag om 16:00 uur op 1,06. 
Dat is een verlies van ruim 41 procent. Gisteren gingen de aandelen ruim 18 procent omlaag.
Schuld
Beleggers maken zich grote zorgen om de financiele situatie van het bedrijf. 
Het heeft een schuld van 70 miljoen euro en gistermorgen werd bekend dat de  tak van de merken  en   40 tot 50 miljoen euro 
minder gaan opleveren dan gedacht. Met de opbrengst van de verkoop moet een groot deel van de schuld van  worden afgelost.
Grote reorganisatie
 is het moederbedrijf van kleding- en schoenenwinkelketens als ,  en . Het bedrijf is bezig met een grote reorganisatie. 
 wil zich uitsluitend gaan richten op de verkoop van schoenen via internet en winkels in  en . 
 Daarom staat ook woonwinkel  in de etalage. De beleggers vrezen dat ook de verkoop van dit onderdeel zal tegenvallen. 
In het afgelopen half jaar gingen de aandelen van  achteruit van ruim 5 euro naar net boven de 1 euro nu."
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
news.train(:Economie, tokonized_text)

string = "Als het  een beetje meezit, heeft het dorp volgend jaar een wereldprimeur: een drijvend, 
met de zon meedraaiend zonnepanelenpark. Wanneer de gemeente  de vergunning afgeeft, is het park half 2016 een feit. Dat schrijft De .
Het zonnepanelenpark is een rond veld dat bestaat uit meerdere units van 20 zonnepanelen. 
De in totaal 5040 zonnepanelen staan op anderhalve hectare en draaien in twaalf uur tijd met de zon mee. 
Het park moet komen in de  op bedrijventerrein De Aam.
De gemeente  zegt dat het plan past in haar klimaatbeleid en juicht het dan ook toe. 
'We helpen de initiatiefnemer bij het voldoen aan alle juridische verplichtingen zodat we uiteindelijk de vergunning kunnen afgeven', 
zegt een woordvoerder. Ze benadrukt dat de gemeente geen partij is in het project, maar slechts 'voorwaardescheppend'.
Energie voor lokale bedrijven
De jaarlijkse opbrengst wordt geschat op 1,8 megawatt, wat gelijk staat aan het verbruik van zo'n 600 huishoudens. 
Door het slimme ontwerp van het park en de koeling van het water wordt bovendien 30 tot 35 procent energie bespaard. 
De bedoeling is dat de opgewekte stroom rechtstreeks naar ondernemers op het bedrijventerrein gaat.
Volgens het dagblad moet initiatiefnemer   uiterlijk half november toestemming hebben. 
Zonnecollectief  werkt samen met Liander. Het terrein is gratis beschikbaar gesteld door eigenaar ."
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
news.train(:Economie, tokonized_text)

string = "vastgoedbelegger Greystar heeft de campus met studentenwoningen in  gekocht. De campus was van miljardair  , eigenaar van de High Tech Campus in Eindhoven.
Een aankoopprijs is niet bekendgemaakt, maar volgens vastgoedadviseur  is het de grootste beleggingstransactie in studentenhuisvesting in . 
De Campus, die bestaat uit  gebouwen met  appartementen en verschillende winkels, werd ontwikkeld door ontwikkelaar , bouwbedrijf   en  , 
het investeringsbedrijf van . Het complex werd voor miljoen euro gekocht. Bij elkaar investeerden zij naar eigen zeggen zo'n  miljoen euro, 
deels gefinancierd door vastgoedbank "
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
news.train(:Economie, tokonized_text)

string = "Koor in  geeft om  uur een gratis toegankelijk concert in de in . Dirigent  , die het koor jaar geleden mee oprichtte en het al die jaren leidde, 
draagt na afloop het stokje over aan  van . Het koor bereidt de gedreven De  die dag een warm afscheid en hoopt op veel publieke belangstelling."
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
news.train(:Overig, tokonized_text)

string = "Burgers en boeren dichter bij elkaar brengen. Dat is het doel van het . Akkerbouwer   uit  mag het een week lang gaan proberen. 
Het leek mij een goed initiatief om te laten zien wat er op een boerenbedrijf gebeurt.
 is de eerste  boer die in  tekens over zijn werk en leven mag vertellen via . Op de bijbehorende Facebook-pagina krijgt hij iets meer ruimte. 
 Ik was hiervoor benaderd. Er zijn zo veel aanmeldingen, tot  volgend jaar is er voor elke week wel een ander.
Dialoog
De afstand tussen boer en burger wordt steeds groter, zegt . Vroeger had iedereen wel een oom, tante of opa die boer was. 
Dat is niet meer zo. Daarnaast vindt Emmens dat er over boeren veel onwaarheden bestaan.
De boeren willen graag een transparante dialoog met de burger en burgers via sociale media uitnodigen om zelf op een boerenbedrijf te komen kijken, 
legt initiatiefneemster  van der  uit.
Begonnen
Het  bestaat nu acht weken en heeft inmiddels meer dan  volgers. Van  kunnen de volgers deze week tweets verwachten over onder meer aardappels rooien."
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
news.train(:Overig, tokonized_text)

string = " Meer dan honderd foto's en selfies kreeg de redactie van  binnen op  en .
Maar er kan er maar een de winnaar zijn!   en haar baasje  hebben op  en  de meeste likes gekregen voor hun selfie. 
 en haar baasje winnen de selfie op canvasdoek en een  verrassingspakket. 
  organiseerde in het kader van dierendag een speciale fotoactie, waarbij mensen een selfie met hun huisdier konden insturen.
Eervolle vermelding
  krijgt van de redactie een eervolle vermelding. Zij en haar hondje  vormen een bijzonder duo. Nano is sinds  de geleidehond van . 
  Ze schrijft op :  geeft mij zoveel vrijheid en zelfstandigheid en naast het werk zoveel liefde, vriendschap en vreugde. 
  en  kregen op  de meeste likes maar grepen net naast de eerste plek. 
Biggetje
Een andere bijzondere vermelding is de inzending van  en haar acht weken oude biggetje . Omdat mijn acht weken lieve  gewoon het liefste en leukste huisdiertje is.
  stuurde haar selfie met haar hond  in via  en kreeg daar ontzettend veel likes. "
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
news.train(:Overig, tokonized_text)

string = " De treinen tussen en rijden weer.
Eerder vandaag was er een sein- en wisselstoring op het traject. Arriva zette bussen in.
Vanmorgen vroeg was er ook een storing. Rond  uur reden ongeveer een uur lang geen treinen door een sein- en overwegstoring op hetzelfde traject."
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
news.train(:Overig, tokonized_text)

string = "Mam, heb je het nieuwste lied van  al gehoord vraagt mijn dochter, de moeder van mijn kleinzoontjes. Nee, antwoord ik. Hoezo Het is mooi mam, zegt ze, en zo waar. 
Het gaat over zijn twee zoontjes. Wacht. Ik zoek het voor je op.
Ze doet wat met haar telefoontje en even later zitten we er samen naar te luisteren. 
Nou ja, luisteren?! Het is goed dat de songtekst eronder staat, want al bij de tweede zin hoor ik hem niet meer zo goed door ons gesnotter. 
Moeder en dochter. Moeder en moeder.
In mijn gedachten komt een rits beelden voorbij. Van vroeger toen mijn kinderen nog ukkepukken waren die ik altijd om me heen had en met wie ik kon 
knuffelen zoveel ik maar wilde. Ik voel de warmte weer die dat opriep en die ik toen heel gewoon vond en waarvan ik tegen beter weten in dacht dat ik 
die de rest van mijn leven elke dag zou blijven ervaren.
Ik zie de pyjama van mijn dochter weer die bij de was lag, toen ze al uit huis aan het gaan was en ik voel weer de paniek, 
terwijl ik dacht: nu zie ik haar misschien nooit meer in haar pyjama rondlopen. Ik zie me lang geleden weer afscheid nemen van mijn zeventienjarige zoon 
die voor een jaar naar  ging en ik denk aan toen ik kort geleden zo dicht naast hem in het vliegtuig zat, dat ik na jaren weer eens echt zijn lichaamswarmte voelde. 
Ik vond dat zo fijn! Ik denk aan nog zoveel meer, maar ik bedenk ook wat een groot geschenk het is dat ik nu samen met mijn volwassen dochter kan janken om dit lied."
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
news.train(:Overig, tokonized_text)

response = RestClient.get 'http://localhost:9200/news/article/'+id_input.to_s
json = response
parsed = MultiJson.load(json)
if( parsed["exists"])
	puts id_input
	puts news.classify(parsed["_source"]["tokonized_text:"])
	
	label = news.classify(parsed["_source"]["tokonized_text:"])
	RestClient.post "http://localhost:9200/news/article/"+id_input.to_s , {"tokonized_text:" => parsed["_source"]["tokonized_text:"],"text:" => parsed["_source"]["text:"], "datum:" => parsed["_source"]["datum:"], "title:" => parsed["_source"]["title:"],  "locatie:" => parsed["_source"]["locatie:"], "label:" => label }.to_json, :content_type => :json, :accept => :json
end


=begin
i=0

while i < 300
	#id = 98
	response = RestClient.get 'http://localhost:9200/news/article/'+i.to_s
	json = response
	parsed = MultiJson.load(json)
	if( parsed["exists"])
		puts parsed["_source"]["title:"]
		puts parsed["_source"]["tokonized_text:"]
	end
	x =  news.classifiy(parsed["_source"]["tokonized_text:"])
	i += 1
end

=end
