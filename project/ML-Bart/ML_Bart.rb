#!/usr/bin/ruby

require 'mysql'
require 'stuff-classifier'
require 'csv'
# for the naive bayes implementation
#brandweer = StuffClassifier::Bayes.new("Cats or Dogs")

# for the Tf-Idf based implementation
# brandweer = StuffClassifier::TfIdf.new("Brandweer")

# these classifiers use word stemming by default, but if it has weird
# behavior, then you can disable it on init:
brandweer = StuffClassifier::TfIdf.new("Brandweer", :stemming => false)
politie = StuffClassifier::Bayes.new("Politie", :stemming => false)
ziekenhuis = StuffClassifier::TfIdf.new("Ziekenhuis", :stemming => false)

ziekenhuis.train(:test, " Test ")
ziekenhuis.train(:test, " PROEFALARM ")

ziekenhuis.train(:contact, " Dienst ")
ziekenhuis.train(:contact, "  U bent actief in de functie")
ziekenhuis.train(:contact, "  Indien gereed graag naar")
ziekenhuis.train(:contact, "  graag posten  aub")
ziekenhuis.train(:contact, "  overgenomen")
ziekenhuis.train(:contact, " einde VWS en retour")
ziekenhuis.train(:contact, " contact")
ziekenhuis.train(:contact, " HULPDIENSTEN GEPASSEERD")

ziekenhuis.train(:overige, "Besteld vervoer") # besteld vervoer
ziekenhuis.train(:overige, "Besteld vervoer prio 2") # besteld vervoer
ziekenhuis.train(:overige, "Melding zonder sirenes") # melding zonder sirenes
ziekenhuis.train(:overige, "Ongeval Materieel") # ongeval met alleen materiele schade

ziekenhuis.train(:ongeval, "Spoedgeval ambulance") # melding met sirenes
ziekenhuis.train(:ongeval, " SPOEDAMBULANCE") # melding met sirenes


politie.train(:contact, "bellen")
politie.train(:contact, "graag contact politie meldkamer")
politie.train(:contact, "Bel meldkamer incident")
politie.train(:contact, "gaarne contact")
politie.train(:contact, "meldkamer midden bellen")
politie.train(:contact, "Conference Call")
politie.train(:contact, " Piket contact opnemen met meldkamer")
politie.train(:contact, "s.v.p. inbellen OC Maastricht")

politie.train(:verkeer, "WEGVERVOER")
politie.train(:verkeer, "Ongeval Wegvervoer")
politie.train(:verkeer, "AANRIJDING LETSEL bromfietser / fietser")
politie.train(:verkeer, "Ongeval Wegvervoer Materieel (Aanrijding met wild)")
politie.train(:verkeer, "AANRIJDING motor onderuit")
politie.train(:verkeer, "auto boom")
politie.train(:verkeer, "BOTLEK auto vs auto")
politie.train(:verkeer, " Verkeersongeval letsel")

politie.train(:trein, "spoorvervoer") 
politie.train(:trein, "spoor") 
politie.train(:trein, "station") 
politie.train(:trein, "trein") 

politie.train(:brandweer, "brand")
politie.train(:brandweer, "brandweer")

politie.train(:misdrijf, "inbraak")
politie.train(:misdrijf, "schietpartij")
politie.train(:misdrijf, "steekpartij")
politie.train(:misdrijf, "vechtpartij")
politie.train(:misdrijf, "aggressie")
politie.train(:misdrijf, "woningoverval")
politie.train(:misdrijf, "overval")

politie.train(:overig, "Letsel ")
politie.train(:overig, "PRIO 1 Letsel  ")
politie.train(:overig, "Letsel 1  ")

politie.train(:test, "0XXXXXXXXX")
politie.train(:test, "test na werkzaamheden") 

brandweer.train(:test, "TESTOPROEP GMC BN")
brandweer.train(:test, "Test: Test GBT gemeente Smallingerland, u hoeft geen actie te ondernemen.")
brandweer.train(:test, "Test: Test GBT gemeente Schiermonnikoog, u hoeft geen actie te ondernemen.")
brandweer.train(:test, "Test: PROEFALARM")
brandweer.train(:test, "oefening")
brandweer.train(:test, "(PROEFALARM: OVD)")

brandweer.train(:overig, "Afhijsen")    
brandweer.train(:overig, "schermen plaatsen")
brandweer.train(:overig, "rv afhijsen")
brandweer.train(:overig, "Stormschade (Los dak/Geveldeel)")
brandweer.train(:overig, "Openen Deur")
brandweer.train(:overig, "Buitensluiting")
brandweer.train(:overig, "Beknelling")
brandweer.train(:overig, "Wateroverlast")
brandweer.train(:overig, "Liftopsluiting")
brandweer.train(:overig, "Til assistentie")

brandweer.train(:gas, "Ong.Gev.Stof (gasontsnapping) ")
brandweer.train(:gas, "Ongeval (Aardgas lekkage)")
brandweer.train(:gas, "Stank (Soort lucht: vreemd)")
brandweer.train(:gas, "Onderzoek (gas-/vreemde lucht)")
brandweer.train(:gas, "Stank Lekkage Aardgas lage druk")
brandweer.train(:gas, "Gaslucht/lek (binnen)")
brandweer.train(:gas, "Meting (Aardgas) ")
brandweer.train(:gas, "DV Meting (Soort meting: gas) ")
brandweer.train(:gas, "Ongeval (Aardgas lekkage)  ")

brandweer.train(:dier, "Dier te water")
brandweer.train(:dier, "Dier in problemen")

brandweer.train(:melding, "OMS-ALARM")
brandweer.train(:melding, "PAC Melding")
brandweer.train(:melding, "PAC Melding")
brandweer.train(:melding, "OMS Brandmelding")
brandweer.train(:melding, "OMS-Melding")
brandweer.train(:melding, "OMS Alarm ")
brandweer.train(:melding, "Autom. brandalarm ")
brandweer.train(:melding, "Rookmelder ")
brandweer.train(:melding, "OMS Sprinklermelding ")
brandweer.train(:melding, "AM HANDMELDING")
brandweer.train(:melding, "Sprinkler OMS")
brandweer.train(:melding, "Rookdetectie")
brandweer.train(:melding, "Meetverzoek CO Melding")
brandweer.train(:melding, "Automatische brandmelder")

brandweer.train(:brand, "Woningbrand")
brandweer.train(:brand, "Brand bedrijf")
brandweer.train(:brand, "Buitenbrand")
brandweer.train(:brand, "Voertuigbrand")
brandweer.train(:brand, "BR WEGVERVOER (PERSONENAUTO) ")
brandweer.train(:brand, "BR BUITEN")
brandweer.train(:brand, "BR BUITEN")
brandweer.train(:brand, "BRAND WEGVERVOER (Soort voertuig: motor)")
brandweer.train(:brand, "Gebouwbrand")
brandweer.train(:brand, "Containerbrand")

brandweer.train(:verkeer, "Wegverkeer verkeersstremming")
brandweer.train(:verkeer, "Ongeval wegvervoer letsel")
brandweer.train(:verkeer, "Vervuild wegdek (Inzet brw: reinigen wegdek) ")
brandweer.train(:verkeer, "Bijzondere verkeerszaken ")


brandweer.train(:trein, "SPOOR LETSEL")
brandweer.train(:trein, "NS Station (klein) (Trein)")
brandweer.train(:trein, "Ongeval Spoorvervoer (klein) (Trein)")
brandweer.train(:trein, "Treinstilstand tunnel")
brandweer.train(:trein, "Aanrijding spoor (Trein-Persoon)")

brandweer.train(:contact, "GOEDEMIDDAG CONTACT MKB AUB")

brandweer.train(:ambulance, "SPOEDAMBULANCE")
brandweer.train(:ambulance, "SPOED AMBU")
brandweer.train(:ambulance, "SPOEDAMBU")
brandweer.train(:ambulance, "AMBU IS BRUGGEN GEPASSEERD")
brandweer.train(:ambulance, "Reanimatie")

id = ARGV[0]
puts id
begin
    con = Mysql.new '95.85.50.60', 'admin', 't249DJK8', 'test'
    rs = con.query("SELECT * FROM notifications WHERE id = " + id.to_s)
	
	rs.each do |row|
		string = row[7]
		case row[3]
		when 'Ambulance'
			string.gsub!('A2', 'Melding zonder sirenes')
			string.gsub!('A1', 'Spoedgeval ambulance')
			string.gsub!('B1', 'Besteld vervoer')
			string.gsub!('B2', 'Besteld vervoer prio 2')
			x =  ziekenhuis.classify(string) 
		when 'Brandweer'
			x =  brandweer.classify(string) 
		when 'Politie'
			x =  politie.classify(string) 
		else
			x = ''
		end
		if( x != nil)
			if(x.length > 2)
				rs = con.query("INSERT INTO `test`.`labels` (`id`, `notification`, `label`,`sublabel`) VALUES (NULL, '" + id.to_s + "', '"+ row[3] + "', '"+ x.to_s + "')")
			end
		else 
				rs = con.query("INSERT INTO `test`.`labels` (`id`, `notification`, `label`,`sublabel`) VALUES (NULL, '" + id.to_s + "', '"+ row[3] + "', '-')")		end
				
	end
	
#	rs = con.query("INSERT INTO `test`.`labels` (`id`, `notification`, `label`) VALUES (NULL, '" + id.to_s + "', 'Ambulance')")
	
	rescue Mysql::Error => e
    puts e.errno
    puts e.error
    
ensure
    con.close if con
end
=begin
data = CSV.read("notifications.csv", { :col_sep => ',' })
puts data[0][7]



i=10
while i < 250

	string = data[i][7] + ' '
	string.gsub!('A2', 'Melding zonder sirenes')
	string.gsub!('A1', 'Spoedgeval ambulance')
	string.gsub!('B1', 'Besteld vervoer')
	string.gsub!('B2', 'Besteld vervoer prio 2')

	x =  brandweer.classify(data[i][7]) 
		puts x.to_s + "  " + i.to_s + ": " + data[i][7] 
		puts ''
	i += 1
end
=end


