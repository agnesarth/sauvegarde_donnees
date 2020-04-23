require 'bundler'
Bundler.require


class Townhall
  attr_accessor :city_name, :townhall_email
  @@final_array = []
  @@all_town = []
  @@all_email = []

  def url 
    Nokogiri::HTML(open("https://www.annuaire-des-mairies.com/val-d-oise.html"))   
  end

  def get_townhall_urls
    townhall_urls = url.xpath('//tr//a[@class="lientxt"]/@href').collect(&:text)
    urls = []
    townhall_urls.map do |url|
      townhall_url_dotless = "https://www.annuaire-des-mairies.com/" + url.gsub("./", "")
      urls << townhall_url_dotless
   end
  return urls
  end

  def get_townhall_information 
    get_townhall_urls.each do |x|
    doc =  Nokogiri::HTML(open(x)) 
    townhall_email = doc.xpath('//section[2]/div/table/tbody/tr[4]/td[2]').text
    @@all_email << townhall_email
    city_name = doc.xpath('//a[@class="lientxt4"]').text.capitalize.gsub("val d'oise", '')
    @@all_town << city_name
    hash_town = {city_name => townhall_email}
    @@final_array << hash_town
    end
    puts @@final_array
   return @@final_array
  end

  def save_as_json
    #new_townhall = Townhall.new.perform
    File.open("db/emails.json","w") do |f|
    f.write(@@final_array.to_json)
    end
  end

  def save_as_spreadsheet
    session = GoogleDrive::Session.from_config("config.json")
    ws = session.spreadsheet_by_key("1TigtDcmQZQuAGi1VgTXUMsmTAU52nGc1saQwQApz0FQ").worksheets[0]
    
    #value_range_object = Google::Apis::SheetsV4::ValueRange.new(range:  B2, values: @@final_array)
    #result = service.update_spreadsheet_value(spreadsheet_id, range_name, value_range_object, value_input_option: value_input_option)
    
    #ws = Google::Apis::SheetsV4::ValueRange.new(values: @@final_array)

    #value_range_object = Google::Apis::SheetsV4::ValueRange.new(range:  range_name,
    #values: values)
#result = service.update_spreadsheet_value(spreadsheet_id,
#range_name,
#value_range_object,
#value_input_option: value_input_option)
#puts "#{result.updated_cells} cells updated."
    #new_array = @@final_array.to_a
    #ws.insert_rows(ws.num_rows + 1, new_array)
    
    # Avec ça, bug de la gem :
    n = 1
    ws[n, 2] = "Villes"
    ws[n, 3] = "Emails"
    @@all_town.length.times do
      n += 1
      ws[n, 3] = @@all_email[n - 2]
      ws[n, 2] = @@all_town[n - 2]
      
    end
    ws.save

    # ! celui ci dessous marche casi !
    #ws.update_cells(2, 3, @@final_array)
    #ws.save


    #@@final_array.each do |hash|
    #  hash.push
    #  ws.save
    #end
   # ws.insert_rows(ws.num_rows + 1, [["This", "is", "a", "test"],["Other", "test", "we'll", "see"]])
   # ws.save  
  end
  

  def self.get_final_array
    @@final_array
  end

  def perform
    get_townhall_urls
    get_townhall_information
    #save_as_json
    save_as_spreadsheet
  end

  #perform
end # class Townhall

townhall = Townhall.new
townhall.perform
#puts Townhall.get_final_array
#Townhall.final_array

#csv_export_url   => pour csv
