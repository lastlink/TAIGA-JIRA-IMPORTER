# http://www.nokogiri.org/tutorials/searching_a_xml_html_document.html
require 'nokogiri' # provides support for xpath queries
require 'iconv' # used for cleaning bad control characters
require 'json' # used to export to json
require 'date'
#gem install each require
# load ruby functions used in project
load 'functions.rb'




#paths to the 2 jira xml databases
jira_entities = "jira_xml_databases/entities.xml"
jira_active = "jira_xml_databases/activeobjects.xml"
#create nokogiri xpath objects
@doc = Nokogiri::XML(only_valid_chars(jira_entities))
@activeObjects=Nokogiri::XML(File.open(jira_active))

#run this to check that whole document reads
# puts @doc.xpath("*")

#active objects uses namespaces & b/c I don't understand them I decided to remove them
@activeObjects.remove_namespaces! 
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

#select project or do all projects w/ 4 loop

projectname="TAIGA JIRA IMPORTER"
# puts  "project info: id:"
# get specific project
currentproject= @doc.xpath("//Project[@name='"+projectname+"']")

sprintboard="TJI board"
sprintobject = @activeObjects.xpath("//data[@tableName='AO_60DB71_RAPIDVIEW']/row[string='"+sprintboard+"']")
sprintobject= removeInteger(sprintobject[0].search('integer')[0])

# needs to be an email on taiga
# however leaving it blank will result in creator being replaced by the user importing the taiga json
#initialize variables

# give user option to add for each project
# taiga email 0, username 1, userid2
username=["","",nil]

# can't start at 0
backlogorder=1

# taiga uses a datetime format similar to 2016-10-31T14:13:34+0000 for all it's dates
# audid log is like history in taiga, only use it to get the creation date of the project
# I really leave history blank for the taiga project, as users can't really be imported there is no point to importing user history from jira
dateprojectcreated=DateTime.parse(@doc.xpath("//AuditLog[@objectId='"+currentproject[0]['id']+"' and @summary='Project created']/@created").to_s,'%Q')

project_tags=[]

epiclist=[]


# default wiki pages giving credit to self, really these could only come from confluence since jira doesn't have a wiki'
wikipages=[{
      "watchers": [

      ],
      "history": [
        
      ],
      "last_modifier": "",
      "created_date": "2016-10-31T21:03:37+0000",
      "slug": "home",
      "content": "Goal of this project is to build an importer into taiga from jira and vice versa. Nothing as this exists now. I need to change datatypes. Jira is xml and taiga is json. Will be comparing both these projects and may post the files here. Plan to use python to convert.",
      "version": 1,
      "modified_date": "2016-10-31T21:03:37+0000",
      "owner": "",
      "attachments": [

      ]
    },{"watchers": [], "history": [], "last_modifier": username[0], "created_date": "2016-11-11T08:05:30+0000", "slug": "credits", "content": "This project has been converted from JIRA using [lastlink](https://github.com/lastlink \"lastlink\")'s parser. \n\nGithub [source](https://github.com/lastlink/TAIGA-JIRA-IMPORTER \"source\").", "version": 3, "modified_date": "2016-11-11T08:07:48+0000", "owner": username[0], "attachments": []}]

issueslist=[]
#default points setup, note the .5 is = to 1/2
defaultpoints=[{"order": 1, "name": "?", "value": nil}, {"order": 2, "name": "0", "value": 0.0}, {"order": 3, "name": "1/2", "value": 0.5}, {"order": 4, "name": "1", "value": 1.0}, {"order": 5, "name": "2", "value": 2.0}, {"order": 6, "name": "3", "value": 3.0}, {"order": 7, "name": "5", "value": 5.0}, {"order": 8, "name": "8", "value": 8.0}, {"order": 9, "name": "10", "value": 10.0}, {"order": 10, "name": "13", "value": 13.0}, {"order": 11, "name": "20", "value": 20.0}, {"order": 12, "name": "40", "value": 40.0}]

taskslist=[]

total_story_points=nil # used to create graph, could put a default value here, right now it uses the total of all story points which should make the graph completely equal

isprivate=false #all projects default value is not private

#1477923215395
#this is currently ignored
memberships=[{"user_order": nil, "role": "Product Owner", "invited_by": nil, "user": username[1], "email": username[0], "is_admin": true, "created_at": dateprojectcreated, "invitation_extra_text": nil}]
#only do top if user email provided
memberships=[]

description=currentproject[0]['description']
# "build a parser to convert jira xml to taiga and taiga json to jira xml."
#in herit from project
tags_colors=[["jira", nil], ["xml", nil]]
tags_colors=[]
# sprint="TJI Sprint 1" # can be nil

#create issue list
issuelist=
    {
        # "Sub-task":nil,
        # "Story":nil
    }

# generates issue type list
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

# getsprint board name
puts "board id function"
# projectid=currentproject[0]['id'].to_s

puts currentproject[0]['id'] +" entity:"+jira_entities+" active:"+jira_active
tjiboardid= getBoardId(currentproject[0]['id'],jira_entities,jira_active)
puts "get sprints"
# puts @activeObjectstemp.xpath("//data[@tableName='AO_60DB71_SPRINT']/row[integer='"+tjiboardid+"'][position()=2]")
sprintlist= @activeObjectstemp.xpath("//data[@tableName='AO_60DB71_SPRINT']/row[normalize-space(integer[4])='"+tjiboardid+"']")

end_date=DateTime.now
puts end_date
# exit
milestones=[]
puts "each sprint"
# need to create a sprint list to keep track of task order
milestoneorder=1


milestonelistorder={}
milestonelistorder["empty"]=0
for sprint in sprintlist
    # puts sprint
    # puts sprint.search('boolean')[0]
    # puts removeTag(sprint.search('boolean')[1],"boolean")
    # puts removeTag(sprint.search('boolean')[1],"boolean")
    if  removeTag(sprint.search('boolean')[1],"boolean") == "true" then
        startdate=removeInteger(sprint.search('integer')[5])
        end_date= removeInteger(sprint.search('integer')[1])
        startdate = DateTime.strptime(startdate.to_s,'%Q')
        end_date = DateTime.strptime(end_date.to_s,'%Q')
    else
        startdate=end_date.next_day(1)   # moveDay(end_date)
        end_date=startdate.next_day(14) # move2Weeks(start_date)
        # puts startdate.to_s + ": " + end_date.to_s
    end
    sprintname= generateSlug(removeTag(sprint.search('string')[1],"string"))
    # puts boolean(removeTag(sprint.search('boolean')[0],"boolean")=="true")
    newmilestone={"estimated_start": startdate.strftime("%Y-%m-%d"), "watchers": [], "estimated_finish": end_date.strftime("%Y-%m-%d"), "created_date": startdate.to_s, "slug": sprintname, "order": milestoneorder, "disponibility": 0.0, "name": removeTag(sprint.search('string')[1],"string"), "closed": boolean(removeTag(sprint.search('boolean')[0],"boolean")=="true"), "owner": "", "modified_date": DateTime.parse(startdate.to_s,'%Q')}
    # puts newmilestone.to_s
    puts "sprint name:"
    puts sprintname
    milestonelistorder[sprintname]=0
    # milestoneobject = {"name": sprintname, "order": 0}
    # milestonelistorder.push(milestoneobject)
    milestoneorder+=1
    milestones.push(newmilestone)
end
totaluserpoints=0.0

#get user stories use .push to add to array
storylist=@doc.xpath("//Issue[@project='"+ currentproject[0]['id']+"']")
# <IssueLinkType id="10100" linkname="jira_subtask_link" inward="jira_subtask_inward" outward="jira_subtask_outward" style="jira_subtask"/>
# puts "story list type" +storylist.class.name
userstorylink={}

# this pulls out all issues which is included but not limited to sub tasks, user stories epics, bugs
# tasks and user stories are treated as users stories
# bugs are treated as issues & any sub tasks of bugs are ignored
for item in storylist
    if item['type']==issuelist["Story"]['id'] or item['type']==issuelist["Task"]['id']
        # puts item 
        #place summary in subject line
        #generate user story list
        #need to do points and sprint linked to, sprint order
        #need to figure out order
        puts "custom fields:"
        points=@doc.xpath("//CustomFieldValue[@customfield='"+customfieldlist['Story Points']['id']+"' and @issue='"+item['id']+"']/@numbervalue") # 10006
        sprintid=@doc.xpath("//CustomFieldValue[@customfield='"+customfieldlist['Sprint']['id']+"' and @issue='"+item['id']+"']/@stringvalue") # 10000
        puts "//CustomFieldValue[@customfield='"+customfieldlist['Sprint']['id']+"' and @issue='"+item['id']+"']/@stringvalue"
        puts "//data[@tableName='AO_60DB71_SPRINT']/row[normalize-space(integer[3])='"+sprintid.to_s+"']"
        sprintdetails=""
        sprintNum=0
        if sprintid.to_s != ""
            sprintdetails= @activeObjects.xpath("//data[@tableName='AO_60DB71_SPRINT']/row[normalize-space(integer[3])='"+sprintid.to_s+"']")[0]
            sprintdetails=removeTag(sprintdetails.search('string')[1],"string")

            puts generateSlug(sprintdetails)
            puts "items in sprint"
            sprintNum= milestonelistorder[generateSlug(sprintdetails)]
            milestonelistorder[generateSlug(sprintdetails).to_s]+=1
        else
            sprintNum=milestonelistorder["empty"]
            milestonelistorder["empty"]+=1
        end
        puts sprintNum
        if points.size==0
            points="?"
        else
            points=points[0].to_s
            totaluserpoints+=points.to_f
            if points=="0.5"
                points="1/2"
            else
                points=points.to_i.to_s
            end
        end
        puts "points are:" + points
        # next are dates, orders and comments
        # maybe issues next
 
    #   "slug": "new",
    #   "name": "New",
    #   "slug": "ready",
    #   "name": "Ready",
    #   "slug": "in-progress",
    #   "name": "In progress",
    #   "slug": "ready-for-test",
    #   "name": "Ready for test",
    #   "slug": "done",
    #   "name": "Done",
    #   "slug": "archived",
    #   "name": "Archived",
     #jira: 
     # To Do In Progress Done
        status=  @doc.xpath("//Status[@id='"+item["status"]+"']/@name").to_s
        case status
        when "To Do"
            status="New"
        when "In Progress"
            status="In progress"
        when "Done"
            status="Done"
        else
            status="New"
        end
        finished_date=nil
        if status=="Done"
            finished_date=DateTime.parse(item["updated"],'%Q')
        end

        tagslist=[]
        # puts "tags list"
        # puts item['id']
        # <Label id="10002" issue="10387" label="jira"/>
        for tag in @doc.xpath("//Label[@issue='"+item['id']+"']/@label")
            tagslist.push(tag)
            puts tagslist
        end

        newstory={"attachments": [], "sprint_order": sprintNum, "tribe_gig": nil, "team_requirement": false, "tags": tagslist, "ref": backlogorder, "watchers": [], "generated_from_issue": nil, "custom_attributes_values": {}, "subject": item['summary'], "status": status, "assigned_to": nil, "version": backlogorder, "finish_date": finished_date, "is_closed": false, "modified_date": DateTime.parse(item["updated"],'%Q'), "backlog_order": backlogorder, "milestone": sprintdetails, "kanban_order": backlogorder, "owner": username[0], "is_blocked": false, 
        "history": [], "blocked_note": "", "created_date": DateTime.parse(item["created"],'%Q'), "description": item['description'].to_s, "client_requirement": false, "external_reference": nil, "role_points": [{"points": "?", "role": "UX"}, {"points": "?", "role": "Design"}, {"points": "?", "role": "Front"}, {"points": points, "role": "Back"}]}
        userstorylink[item['id']]=backlogorder
        puts userstorylink[item['id']].to_s + " " + item['id']
        
        user_stories.push(newstory)
    elsif item['type']==issuelist["Sub-task"]['id']
        # need to ignore subtasks of bugs and epics
        status=@doc.xpath("//Status[@id='"+item["status"]+"']/@name").to_s
        case status
        when "To Do"
            status="New"
        when "In Progress"
            status="In progress"
        when "Done"
            status="Done"
        else
            status="New"
        end
        
        finished_date=nil
        if status=="Done"
            finished_date=DateTime.parse(item["updated"],'%Q')
        end
        # get userstory link
        # <IssueLink id="10098" linktype="10100" source="10383" destination="10387" sequence="0"/>
        linkuserstoryid=@doc.xpath("//IssueLink[@destination='"+item['id']+"']/@source").to_s
        issuetype=@doc.xpath("//Issue[@project='"+ currentproject[0]['id']+"' and @id='"+linkuserstoryid+"']/@type").to_s
        puts "issue type break"
        #should skip this if the linked task is not a story or task
        # e.g. epics and bugs are ignored
        if issuetype!=issuelist["Task"]['id'] and issuetype!=issuelist["Story"]['id']
            break
        end
        sprintid=@doc.xpath("//CustomFieldValue[@customfield='"+customfieldlist['Sprint']['id']+"' and @issue='"+linkuserstoryid+"']/@stringvalue") # 10000
        puts "//CustomFieldValue[@customfield='"+customfieldlist['Sprint']['id']+"' and @issue='"+item['id']+"']/@stringvalue"
        puts "//data[@tableName='AO_60DB71_SPRINT']/row[normalize-space(integer[3])='"+sprintid.to_s+"']"
        sprintdetails=""
        sprintNum=0
        if sprintid.to_s != ""
            sprintdetails= @activeObjects.xpath("//data[@tableName='AO_60DB71_SPRINT']/row[normalize-space(integer[3])='"+sprintid.to_s+"']")[0]
            sprintdetails=removeTag(sprintdetails.search('string')[1],"string")
        end
        # get tags from labels
        tagslist=[]
        for tag in @doc.xpath("//Label[@issue='"+item['id']+"']/@label")
            tagslist.push(tag)
            puts tagslist
        end
        newtask={"attachments": [],
            "tags": tagslist,
            "user_story": userstorylink[linkuserstoryid], # fun part....
            "ref": backlogorder,
            "watchers": [],
            "modified_date": DateTime.parse(item["updated"],'%Q'),
            "subject": item['summary'],
            "status": status,
            "is_iocaine": false,
            "taskboard_order": backlogorder,
            "assigned_to": nil,
            "us_order": backlogorder,
            "milestone": sprintdetails,
            "owner": "",
            "is_blocked": false,
            "history": [],
            "blocked_note": "",
            "finished_date": finished_date,
            "created_date": DateTime.parse(item["created"],'%Q'),
            "version": backlogorder,
            "custom_attributes_values": {},
            "external_reference": nil,
            "description": item['description'].to_s}
        taskslist.push(newtask)
    elsif item['type']==issuelist["Epic"]['id']
        # epiclist.push(candy)

        tagslist=[]
        for tag in @doc.xpath("//Label[@issue='"+item['id']+"']/@label")
            tagslist.push(tag)
            puts tagslist
        end
        puts "epic link"
        puts "//IssueLink[@source='"+item['id']+"']/@destination"
        linkuserstoryids=@doc.xpath("//IssueLink[@source='"+item['id']+"']/@destination")
        puts linkuserstoryids
        related_user_stories=[]

        # should check to verify that it's a task or user story'
        for userstory in linkuserstoryids
            newlinkeduserstory={
                "user_story": userstorylink[userstory.value],
                "order": backlogorder
                }
            related_user_stories.push(newlinkeduserstory)    
        end
        puts related_user_stories
        status=@doc.xpath("//Status[@id='"+item["status"]+"']/@name").to_s
        case status
        when "To Do"
            status="New"
        when "In Progress"
            status="In progress"
        when "Done"
            status="Done"
        else
            status="New"
        end
        epic={
            "attachments": [],
            "assigned_to": nil,
            "version": backlogorder,
            "tags": tagslist,
            "client_requirement": false,
            "description": item['description'].to_s,
            "related_user_stories": related_user_stories,
            "owner": "",
            "epics_order": backlogorder,
            "ref": backlogorder,
            "watchers": [],
            "history": [],
            "blocked_note": "",
            "custom_attributes_values": {},
            "created_date": DateTime.parse(item["created"],'%Q'),
            "subject": item['summary'],
            "status": status,
            "is_blocked": false,
            "color": "#d3d7cf",
            "modified_date": DateTime.parse(item["updated"],'%Q'),
            "team_requirement": false
            }
        epiclist.push(epic)
    elsif item['type']==issuelist["Bug"]['id']
        # issues support priorities others do not
        status=@doc.xpath("//Status[@id='"+item["status"]+"']/@name").to_s
        case status
        when "To Do"
            status="New"
        when "In Progress"
            status="In progress"
        when "Done"
            status="Done"
        else
            status="New"
        end
        finished_date=nil
        if status=="Done"
            finished_date=DateTime.parse(item["updated"],'%Q')
        end
        puts "getting priority"
        puts item["id"]
        puts item["priority"]
        priority=@doc.xpath("//Priority[@id='"+item["priority"]+"']/@name").to_s
        case priority
        when "High","Highest"
            priority="High"
        when "Medium"
            priority="Normal"
        when "Low","Lowest"
            priority="Low"
        else
            priority="Low"
        end
        puts "returning bug priority"
        puts priority
        
# <Priority id="1" sequence="1" name="Highest" description="This problem will block progress." iconurl="/images/icons/priorities/highest.png" statusColor="#d04437"/>
#     <Priority id="2" sequence="2" name="High" description="Serious problem that could block progress." iconurl="/images/icons/priorities/high.svg" statusColor="#ff6600"/>
#     <Priority id="3" sequence="3" name="Medium" description="Has the potential to affect progress." iconurl="/images/icons/priorities/medium.svg" statusColor="#ffff00"/>
#     <Priority id="4" sequence="4" name="Low" description="Minor problem or easily worked around." iconurl="/images/icons/priorities/low.svg" statusColor="#00cc33"/>
#     <Priority id="5" sequence="5" name="Lowest" description="Trivial problem with little or no impact on progress." iconurl="/images/icons/priorities/lowest.svg" statusColor="#0000ff"/>



        issue={
            "votes": [],
            "created_date": DateTime.parse(item["created"],'%Q'),
            "type": "Bug", #hard coded
            "ref": backlogorder,
            "watchers": [],
            "custom_attributes_values": {},
            "subject": item['summary'],
            "status": status,
            "severity": "Minor", # default value
            "assigned_to": nil,
            "modified_date": DateTime.parse(item["updated"],'%Q'),
            "milestone": nil,
            "owner": "",
            "is_blocked": false,
            "priority": priority,
            "history": [],
            "blocked_note": "",
            "finished_date": finished_date,
            "tags": [],
            "version": backlogorder,
            "attachments": [],
            "external_reference": nil,
            "description": item['description'].to_s
            }
        issueslist.push(issue)
        # if any sub tasks these will be ignored, although they could be added into the description
        # issuelist
    else
        puts "this type is not included in the import: "+item['type']
    end 
    backlogorder+=1
end

# if totalpoints is float add .5
if totaluserpoints.class.name=="Float"
    totaluserpoints+=0.5
end

total_story_points=totaluserpoints.to_i


timeline=[] # this is ok to be empty, very possible to generate although low priority and usernames impossible

# puts "default points"
# puts defaultpoints
# exit
# this is what is populated from the above variables
tempjson=
    {
"transfer_token": nil,
"default_task_status": "New",
"userstories_csv_uuid": nil,
"slug": generateSlug(currentproject[0]['name']),
"default_us_status": "New",
"issue_types": [{"order": 1, "name": "Bug", "color": "#89BAB4"}, {"order": 2, "name": "Question", "color": "#ba89a8"}, {"order": 3, "name": "Enhancement", "color": "#89a8ba"}],
"total_fans": 0,
"name": currentproject[0]['name'],
"logo": nil, # this valud is a 64bit
"videoconferences_extra_data": nil,
"is_issues_activated": true,
"issuecustomattributes": [],
"default_priority": "Normal",
"total_fans_last_year": 0,
"wiki_links": [],
"created_date": dateprojectcreated, # datetime format e.g. "2016-10-31T14:13:34+0000",
"creation_template": "scrum",
"default_issue_status": "New",
"is_epics_activated": true, # default true
"tasks_csv_uuid": nil,
"default_epic_status": "New",
"epics": epiclist,
"blocked_code": nil,
"wiki_pages": wikipages, # uses default wikipages giving credit
"userstorycustomattributes": [],
"issues_csv_uuid": nil,
"issues": issueslist,
"looking_for_people_note": "",
"is_featured": false,
"points": defaultpoints,
"anon_permissions": ["view_project", "view_epics", "view_tasks", "view_wiki_pages", "view_wiki_links", "view_us", "view_milestones", "view_issues"],
"tasks": taskslist,
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
"tags": project_tags,
"roles": [{"order": 10, "computable": true, "name": "UX", "permissions": ["add_issue", "modify_issue", "delete_issue", "view_issues", "add_milestone", "modify_milestone", "delete_milestone", "view_milestones", "view_project", "add_task", "modify_task", "delete_task", "view_tasks", "add_us", "modify_us", "delete_us", "view_us", "add_wiki_page", "modify_wiki_page", "delete_wiki_page", "view_wiki_pages", "add_wiki_link", "delete_wiki_link", "view_wiki_links", "view_epics", "add_epic", "modify_epic", "delete_epic", "comment_epic", "comment_us", "comment_task", "comment_issue", "comment_wiki_page"], "slug": "ux"}, {"order": 20, "computable": true, "name": "Design", "permissions": ["add_issue", "modify_issue", "delete_issue", "view_issues", "add_milestone", "modify_milestone", "delete_milestone", "view_milestones", "view_project", "add_task", "modify_task", "delete_task", "view_tasks", "add_us", "modify_us", "delete_us", "view_us", "add_wiki_page", "modify_wiki_page", "delete_wiki_page", "view_wiki_pages", "add_wiki_link", "delete_wiki_link", "view_wiki_links", "view_epics", "add_epic", "modify_epic", "delete_epic", "comment_epic", "comment_us", "comment_task", "comment_issue", "comment_wiki_page"], "slug": "design"}, {"order": 30, "computable": true, "name": "Front", "permissions": ["add_issue", "modify_issue", "delete_issue", "view_issues", "add_milestone", "modify_milestone", "delete_milestone", "view_milestones", "view_project", "add_task", "modify_task", "delete_task", "view_tasks", "add_us", "modify_us", "delete_us", "view_us", "add_wiki_page", "modify_wiki_page", "delete_wiki_page", "view_wiki_pages", "add_wiki_link", "delete_wiki_link", "view_wiki_links", "view_epics", "add_epic", "modify_epic", "delete_epic", "comment_epic", "comment_us", "comment_task", "comment_issue", "comment_wiki_page"], "slug": "front"}, {"order": 40, "computable": true, "name": "Back", "permissions": ["add_issue", "modify_issue", "delete_issue", "view_issues", "add_milestone", "modify_milestone", "delete_milestone", "view_milestones", "view_project", "add_task", "modify_task", "delete_task", "view_tasks", "add_us", "modify_us", "delete_us", "view_us", "add_wiki_page", "modify_wiki_page", "delete_wiki_page", "view_wiki_pages", "add_wiki_link", "delete_wiki_link", "view_wiki_links", "view_epics", "add_epic", "modify_epic", "delete_epic", "comment_epic", "comment_us", "comment_task", "comment_issue", "comment_wiki_page"], "slug": "back"}, {"order": 50, "computable": false, "name": "Product Owner", "permissions": ["add_issue", "modify_issue", "delete_issue", "view_issues", "add_milestone", "modify_milestone", "delete_milestone", "view_milestones", "view_project", "add_task", "modify_task", "delete_task", "view_tasks", "add_us", "modify_us", "delete_us", "view_us", "add_wiki_page", "modify_wiki_page", "delete_wiki_page", "view_wiki_pages", "add_wiki_link", "delete_wiki_link", "view_wiki_links", "view_epics", "add_epic", "modify_epic", "delete_epic", "comment_epic", "comment_us", "comment_task", "comment_issue", "comment_wiki_page"], "slug": "product-owner"}, {"order": 60, "computable": false, "name": "Stakeholder", "permissions": ["add_issue", "modify_issue", "delete_issue", "view_issues", "view_milestones", "view_project", "view_tasks", "view_us", "modify_wiki_page", "view_wiki_pages", "add_wiki_link", "delete_wiki_link", "view_wiki_links", "view_epics", "comment_epic", "comment_us", "comment_task", "comment_issue", "comment_wiki_page"], "slug": "stakeholder"}],
"description": description,
"total_activity": 32, #needs to be recalculated
"issue_statuses": [{"order": 1, "name": "New", "color": "#8C2318", "is_closed": false, "slug": "new"}, {"order": 2, "name": "In progress", "color": "#5E8C6A", "is_closed": false, "slug": "in-progress"}, {"order": 3, "name": "Ready for test", "color": "#88A65E", "is_closed": true, "slug": "ready-for-test"}, {"order": 4, "name": "Closed", "color": "#BFB35A", "is_closed": true, "slug": "closed"}, {"order": 5, "name": "Needs Info", "color": "#89BAB4", "is_closed": false, "slug": "needs-info"}, {"order": 6, "name": "Rejected", "color": "#CC0000", "is_closed": true, "slug": "rejected"}, {"order": 7, "name": "Postponed", "color": "#666666", "is_closed": false, "slug": "postponed"}],
"is_wiki_activated": true, # true b/c credits would be deleted otherwise
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
puts "end parser"
puts currentproject[0]['name'].downcase.tr!(" ", "-").to_s
File.open(currentproject[0]['name'].downcase.tr!(" ", "-").to_s+".json","w") do |f|
  f.write(JSON.pretty_generate(tempjson))
#   f.write(tempjson.to_json)
#   f.puts JSON.pretty_generate(tempjson)
end


# File.open("taigaproject1a.json","w") do |f|
#   File.open("taigaproject.1.json") do |o|
#     openjson=JSON(o.read)
#     f.write(JSON.pretty_generate(openjson))
#   end
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


