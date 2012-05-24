<cfparam name="ideeventinfo">
<cfsetting  showdebugoutput="false" >
<cfset xmldoc=xmlParse(ideeventinfo)>
<cfset selectfile= xmldoc.event.ide.projectview.resource.xmlattributes.path >
<cfset nextUrl ="http://" & #cgi.server_name# & ":" & #cgi.server_port#  & #getPageContext().getrequest().getrequesturi()# >
<cfset nextUrl =replace(nextUrl,"codecoveragehndlr.cfm","coveragegrid.cfm")>
<!-----<cffile action="write" file="#expandPath('.')#/Application.cfm" output="<cfset baselinecodebase = '#selectfile#_bak'>">----->
<cfheader name="Content-Type" value="text/xml">
<cfoutput>
<response showresponse="true">
	<ide url="#nextUrl#?name=#selectfile#" >
		<!---<dialog width="1200" height="1100" />--->
<!----		<view id="serverview" title="View Servers" />--->
			<view id="editor" title="View Servers" />
	</ide>
</response>
</cfoutput>
