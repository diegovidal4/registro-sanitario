require 'mechanize'
require 'fileutils'

class Scrapper
    def initialize(url,search_string)
        @filename="Productos"
        @url=url
        @code_url=url+"/Ficha.aspx"
        @m=Mechanize.new
        @payload=''
        @search_string=search_string
        @viewstate=""
        @event_validation=""
        @header={
            "User-Agent"=>"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:39.0) Gecko/20100101 Firefox/39.0",
            "Accept-Language"=>"es-CL,es;q=0.8,en-US;q=0.5,en;q=0.3",
            "Accept-Encoding"=>"gzip, deflate"
        }
    end
    def set_payload
        {
                "ctl00_ContentPlaceHolder1_ScriptManager1_HiddenField"=>"",
                "__EVENTTARGET" => "ctl00$ContentPlaceHolder1$chkTipoBusqueda$1",
                "__EVENTARGUMENT" => "",
                "__LASTFOCUS" => "",
                "__VIEWSTATE" => @viewstate,
                "__VIEWSTATEENCRYPTED" => "",
                "__EVENTVALIDATION" => @event_validation,
                "ctl00$ContentPlaceHolder1$chkTipoBusqueda$1"=>"on",
                #"ctl00$ContentPlaceHolder1$txtPrincipio"=>search_string,
                "ctl00$ContentPlaceHolder1$ddlEstado" => "Sí",
                #"ctl00$ContentPlaceHolder1$btnBuscar"=>"Buscar"
        }
    end
    def run
        @m.get @url do |page|
            page.form_with :name => "aspnetForm" do |search_form|
                @viewstate = search_form.field_with(:name => "__VIEWSTATE").value
                @event_validation = search_form.field_with(:name => "__EVENTVALIDATION").value
                @payload=set_payload
                @m.post(@url,@payload).form_with :name => "aspnetForm" do |search_form_2|
                    search_form_2.field_with(:name => "ctl00$ContentPlaceHolder1$txtPrincipio").value = @search_string
                    submit_button = search_form_2.button_with(:name=>"ctl00$ContentPlaceHolder1$btnBuscar")
                    download_list(search_form_2.submit(submit_button))
                    return get_codes
                end
            end
        end
    end

    def download_list(page)
        #Remove last download
        FileUtils.rm_rf(Dir.glob(@filename+"*"))
        #Download bad formated excel
        @m.pluggable_parser.default = Mechanize::Download
        excel_form=page.form_with :name => "aspnetForm"
        submit_button=excel_form.button_with(:name => "ctl00$ContentPlaceHolder1$ImgBntExcel")
        excel_form.submit(submit_button).save('Productos')
    end

    def get_codes
        data=Nokogiri::XML(File.open('Productos'))
        code_list=[]
        data.xpath("//span[@id='lblProducto']//text()").each{|f| code_list<<f.text}
        return code_list
    end

    def get_code_info(code)
        @m.get(@code_url) do
    end
end
