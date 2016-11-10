# http://www.nokogiri.org/tutorials/searching_a_xml_html_document.html
require 'nokogiri'
require 'iconv'
require 'json'
#gem install each

puts "Running jira xml reader."


def only_valid_chars(text)
  return "" unless text
  text
  File.open('entities.xml') do |f|
  #  this removes bad control characters
  text = Iconv.conv('UTF-8//IGNORE', 'UTF-8', f.read.gsub(/[\u0001-\u001A]/ , ''))
  end

  text.encode('UTF-8', 'UTF-8', {:invalid => :replace, :undef => :replace, :replace => ""})
  
  return text
end

@doc = Nokogiri::XML(only_valid_chars(File.open("entities.xml")))
#run this to check that whole document reads
# puts @doc.xpath("*")

#list project names
puts "Available Projects:"
projectlist= @doc.xpath("//Project/@name")
# //Project/@name
# type: Nokogiri::XML::NodeSet
for item in projectlist
    puts item
end

# projectlist.xpath("/@nam").each do |node|
#   # some instruction
# end


puts projectlist.class.name.to_s
puts projectlist[0].to_s

# projectlist1="sup"
# print projectlist1
# puts @doc.css("Project name")
# //Project[@name]
# @name
#select project or do all projects w/ 4 loop
# <Project id="10119" name="TAIGA JIRA IMPORTER" url="https://tree.taiga.io/project/last_link-taiga-jira-importer/backlog" lead="username" description="build a parser to convert jira xml to taiga and taiga json to jira xml." key="TJI" counter="10" assigneetype="3" avatar="10510" originalkey="TJI" projecttype="software"/>

projectname="TAIGA JIRA IMPORTER"
puts  "project info: id:"
# get specific project
currentproject= @doc.xpath("//Project[@name='"+projectname+"']")
# currentproject[0]['name']
# use id to get other info
puts currentproject[0]['id']#.to_i.class.name
# [@lang='en']

puts "selected project: "+projectname

puts "epic link ids"
puts @doc.xpath("//AuditItem[@objectName='"+ currentproject[0]['name']+"']/@logId")
# <AuditItem id="10276" logId="10500" objectType="PROJECT" objectId="10119" objectName="TAIGA JIRA IMPORTER"/>
#     <AuditItem id="10277" logId="10501" objectType="PROJECT" objectId="10119" objectName="TAIGA JIRA IMPORTER"/>
#     <AuditItem id="10278" logId="10501" objectType="USER" objectId="username" objectName="username" objectParentId="1" objectParentName="JIRA Internal Directory"/>
#     <AuditItem id="10279" logId="10502" objectType="PROJECT" objectId="10119" objectName="TAIGA JIRA IMPORTER"/>
#     <AuditItem id="10280" logId="10503" objectType="PROJECT" objectId="10119" objectName="TAIGA JIRA IMPORTER"/>
#     <AuditItem id="10281" logId="10504" objectType="PROJECT" objectId="10119" objectName="TAIGA JIRA IMPORTER"/>

epiclist=
[
{"attachments": [], "assigned_to": nil, "version": 1, "tags": [], "client_requirement": false, "description": "test epic", "related_user_stories": [{"user_story": 2, "order": 1477950018264}, {"user_story": 1, "order": 1477950012880}], "owner": "", "epics_order": 1477948242204, "ref": 10, "watchers": [], "history": [{"comment": "", "delete_comment_user": [], "values": {}, "diff": {}, "is_snapshot": true, "type": 2, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": {"blocked_note_html": "", "assigned_to": nil, "tags": [], "custom_attributes": [], "blocked_note": "", "epics_order": 1477948242204, "owner": 164863, "client_requirement": false, "ref": 10, "is_blocked": false, "status": 654412, "description_html": "<p>test epic</p>", "subject": "Jira Epic", "team_requirement": false, "color": "#d3d7cf", "attachments": [], "description": "test epic"}, "comment_versions": nil, "user": ["", "Alympian Spectator"], "created_at": "2016-10-31T21:10:42+0000", "is_hidden": false}], "blocked_note": "", "custom_attributes_values": {}, "created_date": "2016-10-31T21:10:42+0000", "subject": "Jira Epic", "status": "New", "is_blocked": false, "color": "#d3d7cf", "modified_date": "2016-10-31T21:10:42+0000", "team_requirement": false}]
#ignore epics for now
epiclist=[] 

wikipages=[
{"watchers": [], "history": [{"comment": "", "delete_comment_user": [], "values": {}, "diff": {}, "is_snapshot": true, "type": 2, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": {"content": "Goal of this project is to build an importer into taiga from jira and vice versa. Nothing as this exists now. I need to change datatypes. Jira is xml and taiga is json. Will be comparing both these projects and may post the files here. Plan to use python to convert.", "content_html": "<p>Goal of this project is to build an importer into taiga from jira and vice versa. Nothing as this exists now. I need to change datatypes. Jira is xml and taiga is json. Will be comparing both these projects and may post the files here. Plan to use python to convert.</p>", "attachments": [], "owner": 164863, "slug": "home"}, "comment_versions": nil, "user": ["7cce31b2@opayq.com", "Alympian Spectator"], "created_at": "2016-10-31T21:03:37+0000", "is_hidden": false}], "last_modifier": "7cce31b2@opayq.com", "created_date": "2016-10-31T21:03:37+0000", "slug": "home", "content": "Goal of this project is to build an importer into taiga from jira and vice versa. Nothing as this exists now. I need to change datatypes. Jira is xml and taiga is json. Will be comparing both these projects and may post the files here. Plan to use python to convert.", "version": 1, "modified_date": "2016-10-31T21:03:37+0000", "owner": "7cce31b2@opayq.com", "attachments": []}]

wikipages=[]

issues=[
{"votes": [], "created_date": "2016-10-31T21:21:16+0000", "type": "Bug", "ref": 11, "watchers": [], "custom_attributes_values": {}, "subject": "taiga issue test", "status": "New", "severity": "Minor", "assigned_to": nil, "modified_date": "2016-10-31T21:32:33+0000", "milestone": nil, "owner": "7cce31b2@opayq.com", "is_blocked": false, "priority": "Low", "history": [{"comment": "", "delete_comment_user": [], "values": {}, "diff": {}, "is_snapshot": true, "type": 2, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": {"severity": 795218, "assigned_to": nil, "tags": [], "custom_attributes": [], "blocked_note": "", "milestone": nil, "owner": 164863, "blocked_note_html": "", "ref": 11, "is_blocked": false, "status": 1116113, "priority": 478781, "description_html": "", "subject": "taiga issue test", "type": 481276, "attachments": [], "description": ""}, "comment_versions": nil, "user": ["7cce31b2@opayq.com", "Alympian Spectator"], "created_at": "2016-10-31T21:21:17+0000", "is_hidden": false}, {"comment": "", "delete_comment_user": [], "values": {"severity": {"795217": "Minor", "795218": "Normal"}}, "diff": {"severity": [795218, 795217]}, "is_snapshot": false, "type": 1, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": nil, "comment_versions": nil, "user": ["7cce31b2@opayq.com", "Alympian Spectator"], "created_at": "2016-10-31T21:32:30+0000", "is_hidden": false}, {"comment": "", "delete_comment_user": [], "values": {"priority": {"478780": "Low", "478781": "Normal"}}, "diff": {"priority": [478781, 478780]}, "is_snapshot": false, "type": 1, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": nil, "comment_versions": nil, "user": ["7cce31b2@opayq.com", "Alympian Spectator"], "created_at": "2016-10-31T21:32:33+0000", "is_hidden": false}], "blocked_note": "", "finished_date": nil, "tags": [], "version": 3, "attachments": [], "external_reference": nil, "description": ""}]
issues=[]

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
"issues": issues
    }

print tempjson.to_json
File.open("taigaoutput.json","w") do |f|
  f.write(tempjson.to_json)
end

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
    # <Project id="10119" name="TAIGA JIRA IMPORTER" url="https://tree.taiga.io/project/last_link-taiga-jira-importer/backlog" lead="theefunk" description="build a parser to convert jira xml to taiga and taiga json to jira xml." key="TJI" counter="10" assigneetype="3" avatar="10510" originalkey="TJI" projecttype="software"/>

# <AuditChangedValue id="10737" logId="10492" name="Name" deltaTo="Software Simplified Workflow for Project TJI"/>
#     <AuditChangedValue id="10738" logId="10492" name="Description" deltaTo="Generated by JIRA Software version 7.2.8-DAILY20160816152029. This workflow is managed internally by JIRA Software. Do not manually modify this workflow."/>
#     <AuditChangedValue id="10739" logId="10493" name="Name" deltaTo="TJI: Software Simplified Workflow Scheme"/>
#     <AuditChangedValue id="10740" logId="10493" name="Description" deltaTo="Generated by JIRA Software version 7.2.8-DAILY20160816152029. This workflow scheme is managed internally by JIRA Software. Do not manually modify this workflow scheme."/>
#     <AuditChangedValue id="10741" logId="10497" name="Name" deltaTo="TAIGA JIRA IMPORTER"/>
#     <AuditChangedValue id="10742" logId="10497" name="Key" deltaTo="TJI"/>
#     <AuditChangedValue id="10743" logId="10497" name="Description" deltaTo=""/>
#     <AuditChangedValue id="10744" logId="10497" name="URL" deltaTo=""/>
#     <AuditChangedValue id="10745" logId="10497" name="Project Lead" deltaTo="username"/>
#     <AuditChangedValue id="10746" logId="10497" name="Default Assignee" deltaTo="Unassigned"/>
#     <AuditChangedValue id="10747" logId="10498" name="Description" deltaFrom="" deltaTo="build a parser to convert jira xml to taiga and taiga json to jira xml."/>
#     <AuditChangedValue id="10748" logId="10498" name="URL" deltaFrom="" deltaTo="https://tree.taiga.io/project/last_link-taiga-jira-importer/backlog"/>
#     <AuditChangedValue id="10749" logId="10500" name="Name" deltaTo="Version One"/>
#     <AuditChangedValue id="10750" logId="10500" name="Description" deltaTo="finish exporter v1"/>
#     <AuditChangedValue id="10751" logId="10500" name="Release date" deltaTo="2016-12-10"/>
#     <AuditChangedValue id="10752" logId="10501" name="Name" deltaTo="jira data"/>
#     <AuditChangedValue id="10753" logId="10501" name="Description" deltaTo="test component"/>
#     <AuditChangedValue id="10754" logId="10501" name="Component Lead" deltaTo="username"/>
#     <AuditChangedValue id="10755" logId="10501" name="Default Assignee" deltaTo="Component Lead"/>
#     <AuditChangedValue id="10756" logId="10502" name="Name" deltaTo="Completed Version"/>
#     <AuditChangedValue id="10757" logId="10502" name="Description" deltaTo="test completion"/>
#     <AuditChangedValue id="10758" logId="10502" name="Release date" deltaTo="2016-10-31"/>
#     <AuditChangedValue id="10759" logId="10504" name="Name" deltaTo="test Comp"/>
#     <AuditChangedValue id="10760" logId="10504" name="Default Assignee" deltaTo="Project Default"/>