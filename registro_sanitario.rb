require 'mechanize'
require './scrapper'

search_string=ARGV[0]
payload={}
code_list=[]
url= "http://registrosanitario.ispch.gob.cl"
scrapper = Scrapper.new(url,search_string)

#Run the scrapper and get the code list
scrapper.run.each do |code|
    scrapper.get_code_info code
end

#pp code_list
