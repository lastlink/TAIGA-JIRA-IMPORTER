# functions used
# this removes invalid xml characters, e.g. emoticons so that xpath works properluy
def only_valid_chars(text)
  return "" unless text
  xmltext=""
  File.open(text) do |f|
  #  this removes bad control characters
  xmltext = Iconv.conv('UTF-8//IGNORE', 'UTF-8', f.read.gsub(/[\u0001-\u001A]/ , ''))
  
  end

  xmltext.encode('UTF-8', 'UTF-8', {:invalid => :replace, :undef => :replace, :replace => ""})
  
  return xmltext
end
# this generates taiga slug by making lowercase and adding dash - to spaces
def generateSlug(text)
    text=text.to_s
    return text.downcase.tr!(" ", "-").to_s
end
# returns true if 1 integer passed
def boolean(boolI)
    if boolI==1 then
        return true
    end
    return false
end

def removeColon(text)
  text=text.to_s
  text=text.gsub(":", "") 
  return text.to_s
end
#used to do manual xpath to remove integer
def removeInteger(text)
  return 0 unless text
  text=text.to_s
  text=text.gsub("<integer>", "")
  text=text.gsub("</integer>", "")
  
  return text.to_i
end
#used to do manual xpath to remove tag given
def removeTag(text,tag)
  return 0 unless text
  text=text.to_s
  text=text.gsub("<"+tag+">", "")
  text=text.gsub("</"+tag+">", "")
  
  return text.to_s
end
#this is used to get boardid, has the one section that may need to be changed
def getBoardId(id,jira_entities,jira_active)
    @doctemp = Nokogiri::XML(only_valid_chars(jira_entities))
    @activeObjectstemp=Nokogiri::XML(File.open(jira_active))
    @activeObjectstemp.remove_namespaces!
    searchrequestid= @doctemp.xpath("//SharePermissions[@param1='" + id.to_s + "']/@entityId")[0]
    sprintboardname= @doctemp.xpath("//SearchRequest [@id='"+searchrequestid+"']/@name")[0].to_s.gsub("Filter for ","")
    #this is hardcoded may need to be changed if it changes for each jira database
    sprintobject = @activeObjectstemp.xpath("//data[@tableName='AO_60DB71_RAPIDVIEW']/row[string='"+sprintboardname+"']")
    sprintobject=removeInteger(sprintobject[0].search('integer')[0])
    return sprintobject.to_s
end