# Jira Taiga Importer:

##Description:
* Goal is to build a parser that will convert jira xml to taiga json format and a parser that does that opposite.

###Technologies
* Software Project Management Platforms
    * JIRA (xml database of all projects supports json import)
    * Taiga (json database for each project)
* Parser program 
    * Python element tree (having issues)
    * Ruby 
        * nokogiri ruby xml reader (PROGRESS)
    * Pearl - heard good for parsing may build one as well


###Features
* Export each JIRA project as a separate json project in TAIGA FORMATTING

###Taiga json notes:
* [Source](https://tree.taiga.io/project/last_link-taiga-jira-importer/)
* Owner is left blank unless email in taiga database
* Logo is saved as img text file

###Jira xml notes
* project id is 24

###Xml Resources:
* [W3 schools](http://www.w3schools.com/xml/xpath_syntax.asp)

####Not Supported:
* [ ] Logos
* [ ] Epics (need to figure out xml database better first)
* [ ] Issues

####Supported:
* [x] Export Project names
* [x] Export json
* [ ] Taiga valid json