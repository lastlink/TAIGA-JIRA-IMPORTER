# http://www.nokogiri.org/tutorials/searching_a_xml_html_document.html
require 'nokogiri' # provides support for xpath queries
require 'iconv' # used for cleaning bad control characters
require 'json' # used to export to json
#gem install each

puts "Running jira xml reader."


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

def removeInteger(text)
  return 0 unless text
  text=text.to_s
  text=text.gsub("<integer>", "")
  text=text.gsub("</integer>", "")
  
  return text.to_i
end
def removeTag(text,tag)
  return 0 unless text
  text=text.to_s
  text=text.gsub("<"+tag+">", "")
  text=text.gsub("</"+tag+">", "")
  
  return text.to_i
end

def getBoardId(id,jira_entities,jira_active)
    @doctemp = Nokogiri::XML(only_valid_chars(jira_entities))
    @activeObjectstemp=Nokogiri::XML(File.open(jira_active))
    @activeObjectstemp.remove_namespaces!
    searchrequestid= @doctemp.xpath("//SharePermissions[@param1='" + id.to_s + "']/@entityId")[0]
    sprintboardname= @doctemp.xpath("//SearchRequest [@id='"+searchrequestid+"']/@name")[0].to_s.gsub("Filter for ","")
    sprintobject = @activeObjectstemp.xpath("//data[@tableName='AO_60DB71_RAPIDVIEW']/row[string='"+sprintboardname+"']")
    sprintobject=removeInteger(sprintobject[0].search('integer')[0])
    return sprintobject.to_s
end



jira_entities = "entities.xml"
jira_active = "activeobjects.xml"
@doc = Nokogiri::XML(only_valid_chars(jira_entities))
@activeObjects=Nokogiri::XML(File.open(jira_active))
#run this to check that whole document reads
# puts @doc.xpath("*")
# puts "testing new xml:"
# xpath doesnt work w/ nokogiri activeobjects.xml
# puts @activeObjects.xpath("//table")
# puts @activeObjects.css('row').to_s
@activeObjects.remove_namespaces! # need to do this to actually use
#name spaces are confusing
# puts @activeObjects.xpath("//data[@tableName='AO_60DB71_RAPIDVIEW']/row")

# /@integer='10120'
# data tableName="AO_60DB71_RAPIDVIEW
# /*[name()='backup']/*[name()='data']
#valid query
# puts @activeobjects.xpath("/")

# puts @activeObjects.at('//data[@tableName="AO_60DB71_RAPIDVIEW"]/row')
# .at('//Relationship[@Id="rId3"]')
# puts @doc.xpath('//*')
# @doc2 = Nokogiri::XML(@activeObjects.css('row').to_s)
# puts @doc2
# puts @activeObjects.xpath('//boolean')
# puts "end testing..."
#list project names
puts "Available Projects:"
projectlist= @doc.xpath("//Project/@name")
# //Project/@name
# # type: Nokogiri::XML::NodeSet
# for item in projectlist
#     puts item
# end
# Fall216
# Software Startup Initiative
# Gym Counter
# Dirt
# Youtube Filtering
# Dibs
# Mobile Mentoring Application
# Sports
# Workout
# Nimbus
# Lure
# David Vogt's Project
# Parkor
# Referrals and Commissions
# Blaine Hamilton IS590R
# Michael's Project
# Stop Texting and Driving
# stackDj
# PaperGames
# TAIGA JIRA IMPORTER

# projectlist.xpath("/@nam").each do |node|
#   # some instruction
# end

# gets class of object
# puts projectlist.class.name.to_s
# puts projectlist[0].to_s

# projectlist1="sup"
# print projectlist1
# puts @doc.css("Project name")
# //Project[@name]
# @name
#select project or do all projects w/ 4 loop
# <Project id="10119" name="TAIGA JIRA IMPORTER" url="https://tree.taiga.io/project/last_link-taiga-jira-importer/backlog" lead="username[0]" description="build a parser to convert jira xml to taiga and taiga json to jira xml." key="TJI" counter="10" assigneetype="3" avatar="10510" originalkey="TJI" projecttype="software"/>

projectname="TAIGA JIRA IMPORTER"
# puts  "project info: id:"
# get specific project
currentproject= @doc.xpath("//Project[@name='"+projectname+"']")
# currentproject[0]['name']
# use id to get other info
puts currentproject[0]['id']#.to_i.class.name
# [@lang='en']
sprintboard="TJI board"
puts "searching object xml:"
# sprintobject = @activeObjects.xpath("//data[@tableName='AO_60DB71_RAPIDVIEW']/row[string='"+sprintboard+"']")
# sprintobject= removeInteger(sprintobject[0].search('integer')[0])
# board it
sprintboard="TJI board"
sprintobject = @activeObjects.xpath("//data[@tableName='AO_60DB71_RAPIDVIEW']/row[string='"+sprintboard+"']")
sprintobject= removeInteger(sprintobject[0].search('integer')[0])
puts sprintobject
# puts sprintid.xpath('/*')
 # id
# puts sprintstrings[0].s

puts "end search"






puts "selected project: "+projectname

# puts "epic link ids:"
# puts @doc.xpath("//AuditItem[@objectName='"+ currentproject[0]['name']+"']/@logId")


# <AuditItem id="10276" logId="10500" objectType="PROJECT" objectId="10119" objectName="TAIGA JIRA IMPORTER"/>
#     <AuditItem id="10277" logId="10501" objectType="PROJECT" objectId="10119" objectName="TAIGA JIRA IMPORTER"/>
#     <AuditItem id="10278" logId="10501" objectType="USER" objectId="username[0]" objectName="username[0]" objectParentId="1" objectParentName="JIRA Internal Directory"/>
#     <AuditItem id="10279" logId="10502" objectType="PROJECT" objectId="10119" objectName="TAIGA JIRA IMPORTER"/>
#     <AuditItem id="10280" logId="10503" objectType="PROJECT" objectId="10119" objectName="TAIGA JIRA IMPORTER"/>
#     <AuditItem id="10281" logId="10504" objectType="PROJECT" objectId="10119" objectName="TAIGA JIRA IMPORTER"/>


# needs to be an email on taiga
#my user email taiga: 7cce31b2@opayq.com
#initialize varialbes

# give user option to add for each project
# taiga email, username[0], userid
username=["","",nil]

# epics rather confusing since jira has multiple epics in audit log
epiclist=
[
{"attachments": [], "assigned_to": nil, "version": 1, "tags": [], "client_requirement": false, "description": "test epic", "related_user_stories": [{"user_story": 2, "order": 1477950018264}, {"user_story": 1, "order": 1477950012880}], "owner": "", "epics_order": 1477948242204, "ref": 10, "watchers": [], "history": [{"comment": "", "delete_comment_user": [], "values": {}, "diff": {}, "is_snapshot": true, "type": 2, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": {"blocked_note_html": "", "assigned_to": nil, "tags": [], "custom_attributes": [], "blocked_note": "", "epics_order": 1477948242204, "owner": 164863, "client_requirement": false, "ref": 10, "is_blocked": false, "status": 654412, "description_html": "<p>test epic</p>", "subject": "Jira Epic", "team_requirement": false, "color": "#d3d7cf", "attachments": [], "description": "test epic"}, "comment_versions": nil, "user": ["", "Alympian Spectator"], "created_at": "2016-10-31T21:10:42+0000", "is_hidden": false}], "blocked_note": "", "custom_attributes_values": {}, "created_date": "2016-10-31T21:10:42+0000", "subject": "Jira Epic", "status": "New", "is_blocked": false, "color": "#d3d7cf", "modified_date": "2016-10-31T21:10:42+0000", "team_requirement": false}]

#ignore epics for now, pull ids from custom list
epiclist=[] 

# default wiki pages giving credit to self, really these could only come from confluence jira doesn't have a wiki'
wikipages=[{"watchers": [], "history": [{"comment": "", "delete_comment_user": [], "values": {}, "diff": {}, "is_snapshot": true, "type": 2, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": {"content": "", "content_html": "", "attachments": [], "owner": 164863, "slug": "credits"}, "comment_versions": nil, "user": [username[0], username[1]], "created_at": "2016-11-11T08:05:30+0000", "is_hidden": false}, {"comment": "", "delete_comment_user": [], "values": {}, "diff": {"content": ["", "This project has been converted from jira using lastlink's parser. \n\nGithub [source](https://github.com/lastlink/TAIGA-JIRA-IMPORTER \"source\")."], "content_html": ["", "<p>This project has been converted from jira using lastlink's parser. </p>\n<p>Github <a href=\"https://github.com/lastlink/TAIGA-JIRA-IMPORTER\" target=\"_blank\" title=\"source\">source</a>.</p>"]}, "is_snapshot": false, "type": 1, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": nil, "comment_versions": nil, "user": [username[0], username[1]], "created_at": "2016-11-11T08:07:06+0000", "is_hidden": false}, {"comment": "", "delete_comment_user": [], "values": {}, "diff": {"content": ["This project has been converted from jira using lastlink's parser. \n\nGithub [source](https://github.com/lastlink/TAIGA-JIRA-IMPORTER \"source\").", "This project has been converted from JIRA using [lastlink](https://github.com/lastlink \"lastlink\")'s parser. \n\nGithub [source](https://github.com/lastlink/TAIGA-JIRA-IMPORTER \"source\")."], "content_html": ["<p>This project has been converted from jira using lastlink's parser. </p>\n<p>Github <a href=\"https://github.com/lastlink/TAIGA-JIRA-IMPORTER\" target=\"_blank\" title=\"source\">source</a>.</p>", "<p>This project has been converted from JIRA using <a href=\"https://github.com/lastlink\" target=\"_blank\" title=\"lastlink\">lastlink</a>'s parser. </p>\n<p>Github <a href=\"https://github.com/lastlink/TAIGA-JIRA-IMPORTER\" target=\"_blank\" title=\"source\">source</a>.</p>"]}, "is_snapshot": false, "type": 1, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": nil, "comment_versions": nil, "user": [username[0], username[1]], "created_at": "2016-11-11T08:07:49+0000", "is_hidden": false}], "last_modifier": username[0], "created_date": "2016-11-11T08:05:30+0000", "slug": "credits", "content": "This project has been converted from JIRA using [lastlink](https://github.com/lastlink \"lastlink\")'s parser. \n\nGithub [source](https://github.com/lastlink/TAIGA-JIRA-IMPORTER \"source\").", "version": 3, "modified_date": "2016-11-11T08:07:48+0000", "owner": username[0], "attachments": []}]

# do issues
issues=[
{"votes": [], "created_date": "2016-10-31T21:21:16+0000", "type": "Bug", "ref": 11, "watchers": [], "custom_attributes_values": {}, "subject": "taiga issue test", "status": "New", "severity": "Minor", "assigned_to": nil, "modified_date": "2016-10-31T21:32:33+0000", "milestone": nil, "owner": username[0], "is_blocked": false, "priority": "Low", "history": [{"comment": "", "delete_comment_user": [], "values": {}, "diff": {}, "is_snapshot": true, "type": 2, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": {"severity": 795218, "assigned_to": nil, "tags": [], "custom_attributes": [], "blocked_note": "", "milestone": nil, "owner": 164863, "blocked_note_html": "", "ref": 11, "is_blocked": false, "status": 1116113, "priority": 478781, "description_html": "", "subject": "taiga issue test", "type": 481276, "attachments": [], "description": ""}, "comment_versions": nil, "user": [username[0], "Alympian Spectator"], "created_at": "2016-10-31T21:21:17+0000", "is_hidden": false}, {"comment": "", "delete_comment_user": [], "values": {"severity": {"795217": "Minor", "795218": "Normal"}}, "diff": {"severity": [795218, 795217]}, "is_snapshot": false, "type": 1, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": nil, "comment_versions": nil, "user": [username[0], "Alympian Spectator"], "created_at": "2016-10-31T21:32:30+0000", "is_hidden": false}, {"comment": "", "delete_comment_user": [], "values": {"priority": {"478780": "Low", "478781": "Normal"}}, "diff": {"priority": [478781, 478780]}, "is_snapshot": false, "type": 1, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": nil, "comment_versions": nil, "user": [username[0], "Alympian Spectator"], "created_at": "2016-10-31T21:32:33+0000", "is_hidden": false}], "blocked_note": "", "finished_date": nil, "tags": [], "version": 3, "attachments": [], "external_reference": nil, "description": ""}]
issues=[]

#default setup
points=[{"order": 1, "name": "?", "value": nil}, {"order": 2, "name": "0", "value": 0.0}, {"order": 3, "name": "1/2", "value": 0.5}, {"order": 4, "name": "1", "value": 1.0}, {"order": 5, "name": "2", "value": 2.0}, {"order": 6, "name": "3", "value": 3.0}, {"order": 7, "name": "5", "value": 5.0}, {"order": 8, "name": "8", "value": 8.0}, {"order": 9, "name": "10", "value": 10.0}, {"order": 10, "name": "13", "value": 13.0}, {"order": 11, "name": "20", "value": 20.0}, {"order": 12, "name": "40", "value": 40.0}]

# power is how to feel
tasks=[]

total_story_points=nil # used to create graph

isprivate=false #this will change after testing is done

memberships=[{"user_order": 1477923215395, "role": "Product Owner", "invited_by": nil, "user": username[0], "email": "", "is_admin": true, "created_at": "2016-10-31T14:13:35+0000", "invitation_extra_text": nil}]
#only do top if user email provided
memberships=[]

description="build a parser to convert jira xml to taiga and taiga json to jira xml."
#in herit from project
tags_colors=[["jira", nil], ["xml", nil]]

sprint="TJI Sprint 1" # can be null





#get user stories use .push to add to array
storylist=@doc.xpath("//Issue[@project='"+ currentproject[0]['id']+"']")
# <IssueLinkType id="10100" linkname="jira_subtask_link" inward="jira_subtask_inward" outward="jira_subtask_outward" style="jira_subtask"/>
puts "story list type" +storylist.class.name
#create issue list
issuelist=
    {
        "Sub-task":nil,
        "Story":nil

    }

puts "generating issue type list"
for item in @doc.xpath("//IssueType")
    case item['name']
    when "Sub-task"
        issuelist['Sub-task']=item
    when "Epic"
        issuelist['Epic']=item
    when "Story"
        issuelist['Story']=item
    when "Task"
        issuelist['Task']=item
    when "Bug"
        issuelist['Bug']=item
    else
        puts "issue of: "+item['name']+" is missing"
    end 
end

customfieldlist={

}
puts "get custom field ids"
for item in @doc.xpath("//CustomField")
    case item['name']
    when "Story Points"
        customfieldlist["Story Points"]=item
    else
        customfieldlist[item['name']]=item
    end

end
# Sprint, Epics, Story Points
#find points from here
# <CustomField id="10006" customfieldtypekey="com.atlassian.jira.plugin.system.customfieldtypes:float" customfieldsearcherkey="com.atlassian.jira.plugin.system.customfieldtypes:exactnumber" name="Story Points" description="Measurement of complexity and/or size of a requirement."/>
puts "customfield value:"
# puts @doc.xpath("//CustomFieldValue[@customfield='10006' and @issue='10383']/@numbervalue")
# puts customfieldlist['Story Points']['id']
puts @doc.xpath("//CustomFieldValue[@customfield='"+customfieldlist['Story Points']['id']+"' and @issue='"+10383.to_s+"']/@numbervalue")
puts "check if has attr."
puts numberExists= @doc.xpath("//CustomFieldValue[@customfield='10000' and @issue='10385']/@numbervalue")
puts numberExists.size
puts numberExists.class.name
puts numberExists
# puts numberExists.class.column_names.include? "numbervalue"
# <CustomFieldValue id="10500" issue="10385" customfield="10000" stringvalue="48"/>

# puts @doc.xpath("//CustomFieldValue[@customfield='"+customfieldlist['Story Points']+"' and issue='"+10383.to_s+"']/@numbervalue") # should be 5.0
puts "end custom field value...."
# <CustomFieldValue id="10505" issue="10383" customfield="10006" numbervalue="5.0"/>
    # <CustomFieldValue id="10507" issue="10385" customfield="10006" numbervalue="8.0"/>
    # <CustomFieldValue id="10508" issue="10386" customfield="10006" numbervalue="5.0"/>
    # <CustomFieldValue id="10509" issue="10384" customfield="10006" numbervalue="0.5"/>
# <FieldConfiguration id="10106" name="Default Configuration for Story Points" description="Default configuration generated by JIRA" fieldid="customfield_10006"/>

# <FieldConfiguration id="10106" name="Default Configuration for Story Points" description="Default configuration generated by JIRA" fieldid="customfield_10006"/>

user_stories=[]
   

puts "get assigned sprint:"
sprintid=@doc.xpath("//CustomFieldValue [@issue='10385' and @customfield='10000']/@stringvalue")



# puts @doc.xpath("//UserHistoryItem[@entityId='48']")
# <CustomFieldValue id="10500" issue="10385" customfield="10000" stringvalue="48"/>
#sprints 
# basically if custom field is sprint, then userhistory entityid
# <UserHistoryItem id="10846" type="Sprint" entityId="47" username="theefunk" lastViewed="1477949037766" data="TJI Sprint 1"/>
#     <UserHistoryItem id="10847" type="Sprint" entityId="48" username="theefunk" lastViewed="1477949037766" data="TJI Sprint 2"/>
#would it be best to go backwards w/ sprints? or I could generate a list and count updated
# puts @doc.xpath("//UserHistoryItem[@type='Sprint']")
    # <row>  
    # <boolean>false</boolean>
    #   <integer nil="true"/>
    #   <integer>1479136680000</integer>
    #   <string nil="true"/>
    #   <integer>47</integer>
    #   <string>TJI Sprint 1</string>
    #   <integer>24</integer>
    #   <integer nil="true"/>
    #   <boolean>true</boolean>
    #   <integer>1477923500196</integer>
    # </row>

# getsprint board name
puts "board id function"
# projectid=currentproject[0]['id'].to_s
puts currentproject[0]['id'] +" entity:"+jira_entities+" active:"+jira_active
tjiboardid= getBoardId(currentproject[0]['id'],jira_entities,jira_active)
puts "get sprints"
# puts @activeObjectstemp.xpath("//data[@tableName='AO_60DB71_SPRINT']/row[integer='"+tjiboardid+"'][position()=2]")
sprintlist= @activeObjectstemp.xpath("//data[@tableName='AO_60DB71_SPRINT']/row[normalize-space(integer[4])='"+tjiboardid+"']")[0]
# get start date if bool true
startdate= removeInteger(sprintlist.search('integer')[1])
# timems = datetime.datetime.fromtimestamp(float(item['TimeMs']['$numberLong']) / 1e3)
puts datetime.datetime.fromtimestamp(float(startdate) / 1e3)
# dates are a timestamp, need to convert, if bool true otherwise should auto generate w/ 2 week interverals

puts "end get sprints"
# sprintobject=removeInteger(sprintobject[0].search('integer')[0])
# now need to get active sprints ids
# sprintArray=[]
# <data tableName="AO_60DB71_SPRINT">

puts sprintobject
exit
    # <SearchRequest id="10120" name="Filter for TJI board" author="theefunk" user="theefunk" request="project = TJI ORDER BY Rank ASC" favCount="0" nameLower="filter for tji board"/>
    # <SharePermissions id="10220" entityId="10120" entityType="SearchRequest" type="project" param1="10119"/>
# taiga requires start and end dates for all sprints while jira does not
milestones=[]
newmilestone={"estimated_start": "2016-10-31", "watchers": [], "estimated_finish": "2016-11-14", "created_date": "2016-10-31T21:16:30+0000", "slug": "tji-sprint-1", "order": 1, "disponibility": 0.0, "name": "TJI Sprint 1", "closed": false, "owner": "", "modified_date": "2016-10-31T21:16:30+0000"}
milestones.push(newmilestone)
# {"estimated_start": "2016-10-31", "watchers": [], "estimated_finish": "2016-11-14", "created_date": "2016-10-31T21:16:30+0000", "slug": "tji-sprint-1", "order": 1, "disponibility": 0.0, "name": "TJI Sprint 1", "closed": false, "owner": "", "modified_date": "2016-10-31T21:16:30+0000"}, {"estimated_start": "2016-11-14", "watchers": [], "estimated_finish": "2016-11-28", "created_date": "2016-10-31T21:16:37+0000", "slug": "tji-sprint-2", "order": 1, "disponibility": 0.0, "name": "TJI Sprint 2", "closed": false, "owner": "", "modified_date": "2016-10-31T21:16:37+0000"}, {"estimated_start": "2016-11-28", "watchers": [], "estimated_finish": "2016-12-12", "created_date": "2016-10-31T21:16:51+0000", "slug": "tji-sprint-3", "order": 1, "disponibility": 0.0, "name": "TJI Sprint 3", "closed": false, "owner": "", "modified_date": "2016-10-31T21:16:51+0000"}]

for item in storylist
    if item['type']==issuelist["Story"]['id']
        # puts item 
        #place summary in subject line
        #generate user story list
        #need to do points and sprint linked to, sprint order
        #need to figure out order
        points=@doc.xpath("//CustomFieldValue[@customfield='"+customfieldlist['Story Points']['id']+"' and @issue='"+item['id']+"']/@numbervalue")
        # sprints/milestones
    #     <CustomFieldValue id="10495" issue="10383" customfield="10000" stringvalue="47"/>
    # <CustomFieldValue id="10497" issue="10384" customfield="10000" stringvalue="47"/>
    # <CustomFieldValue id="10499" issue="10391" customfield="10000" stringvalue="48"/>
    # <CustomFieldValue id="10500" issue="10385" customfield="10000" stringvalue="48"/>
        if points.size==0
            points="?"
        else
            points=points[0].to_s
        end
        puts "points are:" +points
        newstory={"attachments": [], "sprint_order": 1, "tribe_gig": nil, "team_requirement": false, "tags": [], "ref": 2, "watchers": [], "generated_from_issue": nil, "custom_attributes_values": {}, "subject": item['summary'], "status": "New", "assigned_to": nil, "version": 4, "finish_date": nil, "is_closed": false, "modified_date": item["updated"], "backlog_order": 0, "milestone": "TJI Sprint 1", "kanban_order": 1477944450673, "owner": username[0], "is_blocked": false, "history": [{"comment": "", "delete_comment_user": [], "values": {}, "diff": {}, "is_snapshot": true, "type": 2, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": {"attachments": [], "tribe_gig": nil, "ref": 2, "owner": 164863, "description_html": "<p>"+item['description'].to_s+"</p>", "subject": currentproject[0]['name'], "status": 939936, "is_blocked": false, "sprint_order": 1477944450673, "assigned_to": nil, "finish_date": "None", "is_closed": false, "backlog_order": 1477944450673, "custom_attributes": [], "milestone": nil, "kanban_order": 1477944450673, "points": {"970045": 1915738, "970044": 1915738, "970043": 1915738, "970046": 1915740}, "blocked_note_html": "", "from_issue": nil, "blocked_note": "", "tags": [], "description": item['description'].to_s, "client_requirement": false, "team_requirement": false}, "comment_versions": nil, "user": [username[0], username[1]], "created_at": item["created"], "is_hidden": false}, {"comment": "", "delete_comment_user": [], "values": {}, "diff": {"subject": [currentproject[0]['name'], item['summary']]}, "is_snapshot": false, "type": 1, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": nil, "comment_versions": nil, "user": [username[0], username[1]], "created_at": item["created"], "is_hidden": false}, {"comment": "", "delete_comment_user": [], "values": {"milestone": {"103261": "TJI Sprint 1"}}, "diff": {"milestone": [nil, 103261], "sprint_order": [1477944450673, 1]}, "is_snapshot": false, "type": 1, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": nil, "comment_versions": nil, "user": ["", "Alympian Spectator"], "created_at": item["created"], "is_hidden": false}], "blocked_note": "", "created_date": item["created"], "description": item['description'].to_s, "client_requirement": false, "external_reference": nil, "role_points": [{"points": "?", "role": "UX"}, {"points": "?", "role": "Design"}, {"points": "?", "role": "Front"}, {"points": points, "role": "Back"}]}
        user_stories.push(newstory)
    end #2016-10-31 08:21:43.651"
        #2016-10-31T20:07:30+0000
    #if subtask then....
    
end


tasklist=@doc.xpath("//Issue")




# sub task has type 10000, main story has type 10000
   # <Issue id="10383" key="TJI-1" number="1" project="10119" reporter="theefunk" assignee="theefunk" creator="theefunk" type="10002" summary="Generate data files" description="jira and taiga projects need to be generated mirroring the other and then exported" priority="4" status="10000" created="2016-10-31 08:16:17.589" updated="2016-10-31 14:42:49.856" votes="0" watches="1" workflowId="10383"/>
# come from public.jiraissue table
# get type 
# <IssueType id="10000" sequence="0" name="Sub-task" style="jira_subtask" description="The sub-task of the issue" iconurl="/images/icons/issuetypes/subtask_alternate.png"/>
#     <IssueType id="10001" name="Epic" description="gh.issue.epic.desc" iconurl="/images/icons/issuetypes/epic.svg"/>
#     <IssueType id="10002" name="Story" description="gh.issue.story.desc" iconurl="/images/icons/issuetypes/story.svg"/>
#     <IssueType id="10003" name="Task" style="" description="A task that needs to be done." avatar="10318"/>
#     <IssueType id="10004" name="Bug" style="" description="A problem which impairs or prevents the functions of the product." 



# <IssueLink id="10098" linktype="10100" source="10383" destination="10387" sequence="0"/>
#     <IssueLink id="10099" linktype="10100" source="10383" destination="10388" sequence="1"/>
#     <IssueLink id="10100" linktype="10100" source="10383" destination="10389" sequence="2"/>
#     <IssueLink id="10101" linktype="10100" source="10383" destination="10390" sequence="3"/>
#  <IssueLink id="10104" linktype="10200" source="10392" destination="10384"/>

#get task list for each
#    <Issue id="10387" key="TJI-5" number="5" project="10119" reporter="theefunk" assignee="theefunk" creator="theefunk" type="10000" summary="generate project on jira" description="sub task description" priority="3" status="3" created="2016-10-31 08:21:43.651" updated="2016-10-31 09:05:34.24" votes="0" watches="1" workflowId="10387"/>
    # <Issue id="10388" key="TJI-6" number="6" project="10119" reporter="theefunk" creator="theefunk" type="10000" summary="export jira xml" priority="3" status="10000" created="2016-10-31 08:21:58.772" updated="2016-10-31 08:21:58.772" votes="0" watches="1" workflowId="10388"/>
    # <Issue id="10389" key="TJI-7" number="7" project="10119" reporter="theefunk" creator="theefunk" type="10000" summary="generate project on taiga" priority="3" status="10000" created="2016-10-31 08:22:08.497" updated="2016-10-31 08:22:08.497" votes="0" watches="1" workflowId="10389"/>
    # <Issue id="10390" key="TJI-8" number="8" project="10119" reporter="theefunk" creator="theefunk" type="10000" summary="export taiga json" priority="3" status="10000" created="2016-10-31 08:22:17.426" updated="2016-10-31 08:22:17.426" votes="0" watches="1" workflowId="10390"/> 



storysubject="Download data files"
 


# singleuserstory={"attachments": [], "sprint_order": 1, "tribe_gig": nil, "team_requirement": false, "tags": [], "ref": 2, "watchers": [], "generated_from_issue": nil, "custom_attributes_values": {}, "subject": storysubject, "status": "New", "assigned_to": nil, "version": 4, "finish_date": nil, "is_closed": false, "modified_date": "2016-10-31T21:17:03+0000", "backlog_order": 0, "milestone": "TJI Sprint 1", "kanban_order": 1477944450673, "owner": "", "is_blocked": false, "history": [{"comment": "", "delete_comment_user": [], "values": {}, "diff": {}, "is_snapshot": true, "type": 2, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": {"attachments": [], "tribe_gig": nil, "ref": 2, "owner": 164863, "description_html": "", "subject": "TAIGA JIRA IMPORTER", "status": 939936, "is_blocked": false, "sprint_order": 1477944450673, "assigned_to": nil, "finish_date": "None", "is_closed": false, "backlog_order": 1477944450673, "custom_attributes": [], "milestone": nil, "kanban_order": 1477944450673, "points": {"970045": 1915738, "970044": 1915738, "970043": 1915738, "970046": 1915740}, "blocked_note_html": "", "from_issue": nil, "blocked_note": "", "tags": [], "description": "", "client_requirement": false, "team_requirement": false}, "comment_versions": nil, "user": ["", "Alympian Spectator"], "created_at": "2016-10-31T20:07:30+0000", "is_hidden": false}, {"comment": "", "delete_comment_user": [], "values": {}, "diff": {"subject": ["TAIGA JIRA IMPORTER", "Download data files"]}, "is_snapshot": false, "type": 1, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": nil, "comment_versions": nil, "user": ["", "Alympian Spectator"], "created_at": "2016-10-31T21:16:17+0000", "is_hidden": false}, {"comment": "", "delete_comment_user": [], "values": {"milestone": {"103261": "TJI Sprint 1"}}, "diff": {"milestone": [nil, 103261], "sprint_order": [1477944450673, 1]}, "is_snapshot": false, "type": 1, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": nil, "comment_versions": nil, "user": ["", "Alympian Spectator"], "created_at": "2016-10-31T21:17:04+0000", "is_hidden": false}], "blocked_note": "", "created_date": "2016-10-31T20:07:30+0000", "description": "", "client_requirement": false, "external_reference": nil, "role_points": [{"points": "?", "role": "UX"}, {"points": "?", "role": "Design"}, {"points": "?", "role": "Front"}, {"points": "1/2", "role": "Back"}]}.to_json
#puts @doc.xpath("//AuditItem[@objectName='"+ currentproject[0]['name']+"']/@logId")


#subject is key word

# another important thing needing to be built
 #.to_json
#typearray
puts  "story type:" +  user_stories.class.name

# use push to add to array
# user_stories.push(singleuserstory)
# user_story.to_hash << singleuserstory.to_has

timeline=[] # this is ok to be empty

tempjson=
    {
"transfer_token": nil,
"default_task_status": "New",
"userstories_csv_uuid": nil,
"slug": currentproject[0]['name'].downcase.tr!(" ", "-").to_s,
"default_us_status": "New",
"issue_types": [{"order": 1, "name": "Bug", "color": "#89BAB4"}, {"order": 2, "name": "Question", "color": "#ba89a8"}, {"order": 3, "name": "Enhancement", "color": "#89a8ba"}],
"total_fans": 0,
"name": currentproject[0]['name'],
"logo": nil,
"videoconferences_extra_data": nil,
"is_issues_activated": true,
"issuecustomattributes": [],
"default_priority": "Normal",
"total_fans_last_year": 0,
"wiki_links": [],
"created_date": "2016-10-31T14:13:34+0000",
"creation_template": "scrum",
"default_issue_status": "New",
"is_epics_activated": true,
"tasks_csv_uuid": nil,
"default_epic_status": "New",
"epics": epiclist,
"blocked_code": nil,
"wiki_pages": wikipages,
"userstorycustomattributes": [],
"issues_csv_uuid": nil,
"issues": issues,
"looking_for_people_note": "",
"is_featured": false,
"points": points,
"anon_permissions": ["view_project", "view_epics", "view_tasks", "view_wiki_pages", "view_wiki_links", "view_us", "view_milestones", "view_issues"],
"tasks": tasks,
"total_story_points": total_story_points, # can be nil, place value to see graph
"default_severity": "Normal",
"us_statuses": [{"wip_limit": nil, "is_closed": false, "slug": "new", "order": 1, "is_archived": false, "name": "New", "color": "#999999"}, {"wip_limit": nil, "is_closed": false, "slug": "ready", "order": 2, "is_archived": false, "name": "Ready", "color": "#ff8a84"}, {"wip_limit": nil, "is_closed": false, "slug": "in-progress", "order": 3, "is_archived": false, "name": "In progress", "color": "#ff9900"}, {"wip_limit": nil, "is_closed": false, "slug": "ready-for-test", "order": 4, "is_archived": false, "name": "Ready for test", "color": "#fcc000"}, {"wip_limit": nil, "is_closed": true, "slug": "done", "order": 5, "is_archived": false, "name": "Done", "color": "#669900"}, {"wip_limit": nil, "is_closed": true, "slug": "archived", "order": 6, "is_archived": true, "name": "Archived", "color": "#5c3566"}],
"milestones": milestones,
"task_statuses": [{"order": 1, "name": "New", "color": "#999999", "is_closed": false, "slug": "new"}, {"order": 2, "name": "In progress", "color": "#ff9900", "is_closed": false, "slug": "in-progress"}, {"order": 3, "name": "Ready for test", "color": "#ffcc00", "is_closed": true, "slug": "ready-for-test"}, {"order": 4, "name": "Closed", "color": "#669900", "is_closed": true, "slug": "closed"}, {"order": 5, "name": "Needs Info", "color": "#999999", "is_closed": false, "slug": "needs-info"}],
"is_looking_for_people": false,
"videoconferences": nil,
"totals_updated_datetime": "2016-10-31T21:40:18+0000",
"taskcustomattributes": [],
"owner": "",
"total_fans_last_month": 0,
"default_issue_type": "Bug",
"is_private": isprivate, # only one project per user
"memberships": memberships,
"tags": [],
"roles": [{"order": 10, "computable": true, "name": "UX", "permissions": ["add_issue", "modify_issue", "delete_issue", "view_issues", "add_milestone", "modify_milestone", "delete_milestone", "view_milestones", "view_project", "add_task", "modify_task", "delete_task", "view_tasks", "add_us", "modify_us", "delete_us", "view_us", "add_wiki_page", "modify_wiki_page", "delete_wiki_page", "view_wiki_pages", "add_wiki_link", "delete_wiki_link", "view_wiki_links", "view_epics", "add_epic", "modify_epic", "delete_epic", "comment_epic", "comment_us", "comment_task", "comment_issue", "comment_wiki_page"], "slug": "ux"}, {"order": 20, "computable": true, "name": "Design", "permissions": ["add_issue", "modify_issue", "delete_issue", "view_issues", "add_milestone", "modify_milestone", "delete_milestone", "view_milestones", "view_project", "add_task", "modify_task", "delete_task", "view_tasks", "add_us", "modify_us", "delete_us", "view_us", "add_wiki_page", "modify_wiki_page", "delete_wiki_page", "view_wiki_pages", "add_wiki_link", "delete_wiki_link", "view_wiki_links", "view_epics", "add_epic", "modify_epic", "delete_epic", "comment_epic", "comment_us", "comment_task", "comment_issue", "comment_wiki_page"], "slug": "design"}, {"order": 30, "computable": true, "name": "Front", "permissions": ["add_issue", "modify_issue", "delete_issue", "view_issues", "add_milestone", "modify_milestone", "delete_milestone", "view_milestones", "view_project", "add_task", "modify_task", "delete_task", "view_tasks", "add_us", "modify_us", "delete_us", "view_us", "add_wiki_page", "modify_wiki_page", "delete_wiki_page", "view_wiki_pages", "add_wiki_link", "delete_wiki_link", "view_wiki_links", "view_epics", "add_epic", "modify_epic", "delete_epic", "comment_epic", "comment_us", "comment_task", "comment_issue", "comment_wiki_page"], "slug": "front"}, {"order": 40, "computable": true, "name": "Back", "permissions": ["add_issue", "modify_issue", "delete_issue", "view_issues", "add_milestone", "modify_milestone", "delete_milestone", "view_milestones", "view_project", "add_task", "modify_task", "delete_task", "view_tasks", "add_us", "modify_us", "delete_us", "view_us", "add_wiki_page", "modify_wiki_page", "delete_wiki_page", "view_wiki_pages", "add_wiki_link", "delete_wiki_link", "view_wiki_links", "view_epics", "add_epic", "modify_epic", "delete_epic", "comment_epic", "comment_us", "comment_task", "comment_issue", "comment_wiki_page"], "slug": "back"}, {"order": 50, "computable": false, "name": "Product Owner", "permissions": ["add_issue", "modify_issue", "delete_issue", "view_issues", "add_milestone", "modify_milestone", "delete_milestone", "view_milestones", "view_project", "add_task", "modify_task", "delete_task", "view_tasks", "add_us", "modify_us", "delete_us", "view_us", "add_wiki_page", "modify_wiki_page", "delete_wiki_page", "view_wiki_pages", "add_wiki_link", "delete_wiki_link", "view_wiki_links", "view_epics", "add_epic", "modify_epic", "delete_epic", "comment_epic", "comment_us", "comment_task", "comment_issue", "comment_wiki_page"], "slug": "product-owner"}, {"order": 60, "computable": false, "name": "Stakeholder", "permissions": ["add_issue", "modify_issue", "delete_issue", "view_issues", "view_milestones", "view_project", "view_tasks", "view_us", "modify_wiki_page", "view_wiki_pages", "add_wiki_link", "delete_wiki_link", "view_wiki_links", "view_epics", "comment_epic", "comment_us", "comment_task", "comment_issue", "comment_wiki_page"], "slug": "stakeholder"}],
"description": description,
"total_activity": 32, #needs to be recalculated
"issue_statuses": [{"order": 1, "name": "New", "color": "#8C2318", "is_closed": false, "slug": "new"}, {"order": 2, "name": "In progress", "color": "#5E8C6A", "is_closed": false, "slug": "in-progress"}, {"order": 3, "name": "Ready for test", "color": "#88A65E", "is_closed": true, "slug": "ready-for-test"}, {"order": 4, "name": "Closed", "color": "#BFB35A", "is_closed": true, "slug": "closed"}, {"order": 5, "name": "Needs Info", "color": "#89BAB4", "is_closed": false, "slug": "needs-info"}, {"order": 6, "name": "Rejected", "color": "#CC0000", "is_closed": true, "slug": "rejected"}, {"order": 7, "name": "Postponed", "color": "#666666", "is_closed": false, "slug": "postponed"}],
"is_wiki_activated": false, # going to go w/ false
"is_backlog_activated": true,
"priorities": [{"order": 1, "name": "Low", "color": "#666666"}, {"order": 3, "name": "Normal", "color": "#669933"}, {"order": 5, "name": "High", "color": "#CC0000"}],
"total_activity_last_year": 32, #need to testing
"tags_colors": tags_colors,
"severities": [{"order": 1, "name": "Wishlist", "color": "#666666"}, {"order": 2, "name": "Minor", "color": "#669933"}, {"order": 3, "name": "Normal", "color": "#0000FF"}, {"order": 4, "name": "Important", "color": "#FFA500"}, {"order": 5, "name": "Critical", "color": "#CC0000"}],
"total_activity_last_month": 32, # need to test
"epics_csv_uuid": nil,
"default_points": "?",
"total_fans_last_week": 0,
"epic_statuses": [{"order": 1, "name": "New", "color": "#999999", "is_closed": false, "slug": "new"}, {"order": 2, "name": "Ready", "color": "#ff8a84", "is_closed": false, "slug": "ready"}, {"order": 3, "name": "In progress", "color": "#ff9900", "is_closed": false, "slug": "in-progress"}, {"order": 4, "name": "Ready for test", "color": "#fcc000", "is_closed": false, "slug": "ready-for-test"}, {"order": 5, "name": "Done", "color": "#669900", "is_closed": true, "slug": "done"}],
"epiccustomattributes": [],
"user_stories": user_stories,
"total_milestones": 4,
"public_permissions": ["view_project", "view_epics", "view_tasks", "view_wiki_pages", "view_wiki_links", "view_us", "view_milestones", "view_issues"], # this will need to be reconfig for private
"modified_date": "2016-10-31T21:38:42+0000",
"timeline": timeline # is this required?
    }
# currentproject[0]['name'].downcase.tr!(" ", "-").to_s
# print tempjson
# print JSON.pretty_generate(tempjson) #.to_json

# File.open(currentproject[0]['name'].downcase.tr!(" ", "-").to_s+".json","w") do |f|
# #   f.write(tempjson.to_json)
#   f.puts JSON.pretty_generate(tempjson)
# end

# File.open("taigaoutput.json","w") do |f|
#   f.write(tempjson.to_json)
# end

#output to taiga jira file(s)
tempHash = {
    "key_a" => "val_a",
    "key_b" => "val_b"
}
# create json file
# File.open("taigaoutput.json","w") do |f|
#   f.write(tempHash.to_json)
# end




# puts (@doc.xpath("//Project")).to_s
# puts "candy"
# http://www.w3schools.com/xml/xpath_syntax.asp

# print
#database schema https://developer.atlassian.com/jiradev/jira-platform/jira-architecture/database-schema
# ar_tires = @doc.xpath('//car:tire', 'car' => 'http://alicesautoparts.com/')
#convert to taiga json
    # <Project id="10119" name="TAIGA JIRA IMPORTER" url="https://tree.taiga.io/project/last_link-taiga-jira-importer/backlog" lead="username[0]" description="build a parser to convert jira xml to taiga and taiga json to jira xml." key="TJI" counter="10" assigneetype="3" avatar="10510" originalkey="TJI" projecttype="software"/>

# <AuditChangedValue id="10737" logId="10492" name="Name" deltaTo="Software Simplified Workflow for Project TJI"/>
#     <AuditChangedValue id="10738" logId="10492" name="Description" deltaTo="Generated by JIRA Software version 7.2.8-DAILY20160816152029. This workflow is managed internally by JIRA Software. Do not manually modify this workflow."/>
#     <AuditChangedValue id="10739" logId="10493" name="Name" deltaTo="TJI: Software Simplified Workflow Scheme"/>
#     <AuditChangedValue id="10740" logId="10493" name="Description" deltaTo="Generated by JIRA Software version 7.2.8-DAILY20160816152029. This workflow scheme is managed internally by JIRA Software. Do not manually modify this workflow scheme."/>
#     <AuditChangedValue id="10741" logId="10497" name="Name" deltaTo="TAIGA JIRA IMPORTER"/>
#     <AuditChangedValue id="10742" logId="10497" name="Key" deltaTo="TJI"/>
#     <AuditChangedValue id="10743" logId="10497" name="Description" deltaTo=""/>
#     <AuditChangedValue id="10744" logId="10497" name="URL" deltaTo=""/>
#     <AuditChangedValue id="10745" logId="10497" name="Project Lead" deltaTo="username[0]"/>
#     <AuditChangedValue id="10746" logId="10497" name="Default Assignee" deltaTo="Unassigned"/>
#     <AuditChangedValue id="10747" logId="10498" name="Description" deltaFrom="" deltaTo="build a parser to convert jira xml to taiga and taiga json to jira xml."/>
#     <AuditChangedValue id="10748" logId="10498" name="URL" deltaFrom="" deltaTo="https://tree.taiga.io/project/last_link-taiga-jira-importer/backlog"/>
#     <AuditChangedValue id="10749" logId="10500" name="Name" deltaTo="Version One"/>
#     <AuditChangedValue id="10750" logId="10500" name="Description" deltaTo="finish exporter v1"/>
#     <AuditChangedValue id="10751" logId="10500" name="Release date" deltaTo="2016-12-10"/>
#     <AuditChangedValue id="10752" logId="10501" name="Name" deltaTo="jira data"/>
#     <AuditChangedValue id="10753" logId="10501" name="Description" deltaTo="test component"/>
#     <AuditChangedValue id="10754" logId="10501" name="Component Lead" deltaTo="username[0]"/>
#     <AuditChangedValue id="10755" logId="10501" name="Default Assignee" deltaTo="Component Lead"/>
#     <AuditChangedValue id="10756" logId="10502" name="Name" deltaTo="Completed Version"/>
#     <AuditChangedValue id="10757" logId="10502" name="Description" deltaTo="test completion"/>
#     <AuditChangedValue id="10758" logId="10502" name="Release date" deltaTo="2016-10-31"/>
#     <AuditChangedValue id="10759" logId="10504" name="Name" deltaTo="test Comp"/>
#     <AuditChangedValue id="10760" logId="10504" name="Default Assignee" deltaTo="Project Default"/>