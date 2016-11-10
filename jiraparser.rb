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


# needs to be an email on taiga
#my user email taiga: 7cce31b2@opayq.com
#initialize varialbes

username=""

# epics rather confusing since jira has multiple epics in audit log
epiclist=
[
{"attachments": [], "assigned_to": nil, "version": 1, "tags": [], "client_requirement": false, "description": "test epic", "related_user_stories": [{"user_story": 2, "order": 1477950018264}, {"user_story": 1, "order": 1477950012880}], "owner": "", "epics_order": 1477948242204, "ref": 10, "watchers": [], "history": [{"comment": "", "delete_comment_user": [], "values": {}, "diff": {}, "is_snapshot": true, "type": 2, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": {"blocked_note_html": "", "assigned_to": nil, "tags": [], "custom_attributes": [], "blocked_note": "", "epics_order": 1477948242204, "owner": 164863, "client_requirement": false, "ref": 10, "is_blocked": false, "status": 654412, "description_html": "<p>test epic</p>", "subject": "Jira Epic", "team_requirement": false, "color": "#d3d7cf", "attachments": [], "description": "test epic"}, "comment_versions": nil, "user": ["", "Alympian Spectator"], "created_at": "2016-10-31T21:10:42+0000", "is_hidden": false}], "blocked_note": "", "custom_attributes_values": {}, "created_date": "2016-10-31T21:10:42+0000", "subject": "Jira Epic", "status": "New", "is_blocked": false, "color": "#d3d7cf", "modified_date": "2016-10-31T21:10:42+0000", "team_requirement": false}]
#ignore epics for now
epiclist=[] 

wikipages=[
{"watchers": [], "history": [{"comment": "", "delete_comment_user": [], "values": {}, "diff": {}, "is_snapshot": true, "type": 2, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": {"content": "Goal of this project is to build an importer into taiga from jira and vice versa. Nothing as this exists now. I need to change datatypes. Jira is xml and taiga is json. Will be comparing both these projects and may post the files here. Plan to use python to convert.", "content_html": "<p>Goal of this project is to build an importer into taiga from jira and vice versa. Nothing as this exists now. I need to change datatypes. Jira is xml and taiga is json. Will be comparing both these projects and may post the files here. Plan to use python to convert.</p>", "attachments": [], "owner": 164863, "slug": "home"}, "comment_versions": nil, "user": [username, "Alympian Spectator"], "created_at": "2016-10-31T21:03:37+0000", "is_hidden": false}], "last_modifier": "7cce31b2@opayq.com", "created_date": "2016-10-31T21:03:37+0000", "slug": "home", "content": "Goal of this project is to build an importer into taiga from jira and vice versa. Nothing as this exists now. I need to change datatypes. Jira is xml and taiga is json. Will be comparing both these projects and may post the files here. Plan to use python to convert.", "version": 1, "modified_date": "2016-10-31T21:03:37+0000", "owner": username, "attachments": []}]

wikipages=[]

issues=[
{"votes": [], "created_date": "2016-10-31T21:21:16+0000", "type": "Bug", "ref": 11, "watchers": [], "custom_attributes_values": {}, "subject": "taiga issue test", "status": "New", "severity": "Minor", "assigned_to": nil, "modified_date": "2016-10-31T21:32:33+0000", "milestone": nil, "owner": "7cce31b2@opayq.com", "is_blocked": false, "priority": "Low", "history": [{"comment": "", "delete_comment_user": [], "values": {}, "diff": {}, "is_snapshot": true, "type": 2, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": {"severity": 795218, "assigned_to": nil, "tags": [], "custom_attributes": [], "blocked_note": "", "milestone": nil, "owner": 164863, "blocked_note_html": "", "ref": 11, "is_blocked": false, "status": 1116113, "priority": 478781, "description_html": "", "subject": "taiga issue test", "type": 481276, "attachments": [], "description": ""}, "comment_versions": nil, "user": ["7cce31b2@opayq.com", "Alympian Spectator"], "created_at": "2016-10-31T21:21:17+0000", "is_hidden": false}, {"comment": "", "delete_comment_user": [], "values": {"severity": {"795217": "Minor", "795218": "Normal"}}, "diff": {"severity": [795218, 795217]}, "is_snapshot": false, "type": 1, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": nil, "comment_versions": nil, "user": ["7cce31b2@opayq.com", "Alympian Spectator"], "created_at": "2016-10-31T21:32:30+0000", "is_hidden": false}, {"comment": "", "delete_comment_user": [], "values": {"priority": {"478780": "Low", "478781": "Normal"}}, "diff": {"priority": [478781, 478780]}, "is_snapshot": false, "type": 1, "delete_comment_date": nil, "edit_comment_date": nil, "snapshot": nil, "comment_versions": nil, "user": [username, "Alympian Spectator"], "created_at": "2016-10-31T21:32:33+0000", "is_hidden": false}], "blocked_note": "", "finished_date": nil, "tags": [], "version": 3, "attachments": [], "external_reference": nil, "description": ""}]
issues=[]

#default setup
points=[{"order": 1, "name": "?", "value": nil}, {"order": 2, "name": "0", "value": 0.0}, {"order": 3, "name": "1/2", "value": 0.5}, {"order": 4, "name": "1", "value": 1.0}, {"order": 5, "name": "2", "value": 2.0}, {"order": 6, "name": "3", "value": 3.0}, {"order": 7, "name": "5", "value": 5.0}, {"order": 8, "name": "8", "value": 8.0}, {"order": 9, "name": "10", "value": 10.0}, {"order": 10, "name": "13", "value": 13.0}, {"order": 11, "name": "20", "value": 20.0}, {"order": 12, "name": "40", "value": 40.0}]

#power is how to feel
tasks=[]

total_story_points=nil # used to create graph

isprivate=false #this will change after testing is done

memberships=[{"user_order": 1477923215395, "role": "Product Owner", "invited_by": nil, "user": username, "email": "", "is_admin": true, "created_at": "2016-10-31T14:13:35+0000", "invitation_extra_text": nil}]
#only do top if user email provided
memberships=[]

#in herit from project
tags_colors=[["jira", nil], ["xml", nil]]

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
"milestones": [{"estimated_start": "2016-10-31", "watchers": [], "estimated_finish": "2016-11-14", "created_date": "2016-10-31T21:16:30+0000", "slug": "tji-sprint-1", "order": 1, "disponibility": 0.0, "name": "TJI Sprint 1", "closed": false, "owner": "", "modified_date": "2016-10-31T21:16:30+0000"}, {"estimated_start": "2016-11-14", "watchers": [], "estimated_finish": "2016-11-28", "created_date": "2016-10-31T21:16:37+0000", "slug": "tji-sprint-2", "order": 1, "disponibility": 0.0, "name": "TJI Sprint 2", "closed": false, "owner": "", "modified_date": "2016-10-31T21:16:37+0000"}, {"estimated_start": "2016-11-28", "watchers": [], "estimated_finish": "2016-12-12", "created_date": "2016-10-31T21:16:51+0000", "slug": "tji-sprint-3", "order": 1, "disponibility": 0.0, "name": "TJI Sprint 3", "closed": false, "owner": "", "modified_date": "2016-10-31T21:16:51+0000"}],
"task_statuses": [{"order": 1, "name": "New", "color": "#999999", "is_closed": false, "slug": "new"}, {"order": 2, "name": "In progress", "color": "#ff9900", "is_closed": false, "slug": "in-progress"}, {"order": 3, "name": "Ready for test", "color": "#ffcc00", "is_closed": true, "slug": "ready-for-test"}, {"order": 4, "name": "Closed", "color": "#669900", "is_closed": true, "slug": "closed"}, {"order": 5, "name": "Needs Info", "color": "#999999", "is_closed": false, "slug": "needs-info"}],
"is_looking_for_people": false,
"videoconferences": nil,
"totals_updated_datetime": "2016-10-31T21:40:18+0000",
"taskcustomattributes": [],
"owner": "",
"total_fans_last_month": 0,
"default_issue_type": "Bug",
"is_private": isprivate, # only one project per user
"memberships": ,
"tags": [],
"roles": [{"order": 10, "computable": true, "name": "UX", "permissions": ["add_issue", "modify_issue", "delete_issue", "view_issues", "add_milestone", "modify_milestone", "delete_milestone", "view_milestones", "view_project", "add_task", "modify_task", "delete_task", "view_tasks", "add_us", "modify_us", "delete_us", "view_us", "add_wiki_page", "modify_wiki_page", "delete_wiki_page", "view_wiki_pages", "add_wiki_link", "delete_wiki_link", "view_wiki_links", "view_epics", "add_epic", "modify_epic", "delete_epic", "comment_epic", "comment_us", "comment_task", "comment_issue", "comment_wiki_page"], "slug": "ux"}, {"order": 20, "computable": true, "name": "Design", "permissions": ["add_issue", "modify_issue", "delete_issue", "view_issues", "add_milestone", "modify_milestone", "delete_milestone", "view_milestones", "view_project", "add_task", "modify_task", "delete_task", "view_tasks", "add_us", "modify_us", "delete_us", "view_us", "add_wiki_page", "modify_wiki_page", "delete_wiki_page", "view_wiki_pages", "add_wiki_link", "delete_wiki_link", "view_wiki_links", "view_epics", "add_epic", "modify_epic", "delete_epic", "comment_epic", "comment_us", "comment_task", "comment_issue", "comment_wiki_page"], "slug": "design"}, {"order": 30, "computable": true, "name": "Front", "permissions": ["add_issue", "modify_issue", "delete_issue", "view_issues", "add_milestone", "modify_milestone", "delete_milestone", "view_milestones", "view_project", "add_task", "modify_task", "delete_task", "view_tasks", "add_us", "modify_us", "delete_us", "view_us", "add_wiki_page", "modify_wiki_page", "delete_wiki_page", "view_wiki_pages", "add_wiki_link", "delete_wiki_link", "view_wiki_links", "view_epics", "add_epic", "modify_epic", "delete_epic", "comment_epic", "comment_us", "comment_task", "comment_issue", "comment_wiki_page"], "slug": "front"}, {"order": 40, "computable": true, "name": "Back", "permissions": ["add_issue", "modify_issue", "delete_issue", "view_issues", "add_milestone", "modify_milestone", "delete_milestone", "view_milestones", "view_project", "add_task", "modify_task", "delete_task", "view_tasks", "add_us", "modify_us", "delete_us", "view_us", "add_wiki_page", "modify_wiki_page", "delete_wiki_page", "view_wiki_pages", "add_wiki_link", "delete_wiki_link", "view_wiki_links", "view_epics", "add_epic", "modify_epic", "delete_epic", "comment_epic", "comment_us", "comment_task", "comment_issue", "comment_wiki_page"], "slug": "back"}, {"order": 50, "computable": false, "name": "Product Owner", "permissions": ["add_issue", "modify_issue", "delete_issue", "view_issues", "add_milestone", "modify_milestone", "delete_milestone", "view_milestones", "view_project", "add_task", "modify_task", "delete_task", "view_tasks", "add_us", "modify_us", "delete_us", "view_us", "add_wiki_page", "modify_wiki_page", "delete_wiki_page", "view_wiki_pages", "add_wiki_link", "delete_wiki_link", "view_wiki_links", "view_epics", "add_epic", "modify_epic", "delete_epic", "comment_epic", "comment_us", "comment_task", "comment_issue", "comment_wiki_page"], "slug": "product-owner"}, {"order": 60, "computable": false, "name": "Stakeholder", "permissions": ["add_issue", "modify_issue", "delete_issue", "view_issues", "view_milestones", "view_project", "view_tasks", "view_us", "modify_wiki_page", "view_wiki_pages", "add_wiki_link", "delete_wiki_link", "view_wiki_links", "view_epics", "comment_epic", "comment_us", "comment_task", "comment_issue", "comment_wiki_page"], "slug": "stakeholder"}],
"description": "build a parser to convert jira xml to taiga and taiga json to jira xml.",
"total_activity": 32, #needs to be recalculated
"issue_statuses": [{"order": 1, "name": "New", "color": "#8C2318", "is_closed": false, "slug": "new"}, {"order": 2, "name": "In progress", "color": "#5E8C6A", "is_closed": false, "slug": "in-progress"}, {"order": 3, "name": "Ready for test", "color": "#88A65E", "is_closed": true, "slug": "ready-for-test"}, {"order": 4, "name": "Closed", "color": "#BFB35A", "is_closed": true, "slug": "closed"}, {"order": 5, "name": "Needs Info", "color": "#89BAB4", "is_closed": false, "slug": "needs-info"}, {"order": 6, "name": "Rejected", "color": "#CC0000", "is_closed": true, "slug": "rejected"}, {"order": 7, "name": "Postponed", "color": "#666666", "is_closed": false, "slug": "postponed"}],
"is_wiki_activated": false, # going to go w/ false
"is_backlog_activated": true,
"priorities": [{"order": 1, "name": "Low", "color": "#666666"}, {"order": 3, "name": "Normal", "color": "#669933"}, {"order": 5, "name": "High", "color": "#CC0000"}],
"total_activity_last_year": nil,
"tags_colors": tags_colors,
"severities": [{"order": 1, "name": "Wishlist", "color": "#666666"}, {"order": 2, "name": "Minor", "color": "#669933"}, {"order": 3, "name": "Normal", "color": "#0000FF"}, {"order": 4, "name": "Important", "color": "#FFA500"}, {"order": 5, "name": "Critical", "color": "#CC0000"}],
"total_activity_last_month": nil,
"epics_csv_uuid": nil,
"default_points": "?",
"total_fans_last_week": 0,
"epic_statuses": [{"order": 1, "name": "New", "color": "#999999", "is_closed": false, "slug": "new"}, {"order": 2, "name": "Ready", "color": "#ff8a84", "is_closed": false, "slug": "ready"}, {"order": 3, "name": "In progress", "color": "#ff9900", "is_closed": false, "slug": "in-progress"}, {"order": 4, "name": "Ready for test", "color": "#fcc000", "is_closed": false, "slug": "ready-for-test"}, {"order": 5, "name": "Done", "color": "#669900", "is_closed": true, "slug": "done"}],
"epiccustomattributes": []
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
    # <Project id="10119" name="TAIGA JIRA IMPORTER" url="https://tree.taiga.io/project/last_link-taiga-jira-importer/backlog" lead="username" description="build a parser to convert jira xml to taiga and taiga json to jira xml." key="TJI" counter="10" assigneetype="3" avatar="10510" originalkey="TJI" projecttype="software"/>

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