# http://www.nokogiri.org/tutorials/searching_a_xml_html_document.html
require 'nokogiri'
puts "Runny jira xml reader."
@doc = Nokogiri::XML(File.open("entities.xml"))
puts @doc.xpath("//AuditChangedValue")