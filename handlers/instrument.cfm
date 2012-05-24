<cfparam name="ideeventinfo">
<cfsetting  showdebugoutput="false" >
<cfset xmldoc=xmlParse(ideeventinfo)>
<cfset selectfile= xmldoc.event.ide.projectview.resource.xmlattributes.path >
<cfset nextUrl ="http://" & #cgi.server_name# & ":" & #cgi.server_port#  & #getPageContext().getrequest().getrequesturi()# >
<cfset nextUrl =replace(nextUrl,"instrument.cfm","instrumentprogress.cfm")>

<cfheader name="Content-Type" value="text/xml">
<cfoutput>
<response showresponse="true">
	<ide url="#nextUrl#?name=#selectfile#" >
		<dialog width="800" height="700" />
	</ide>
</response>
</cfoutput>



<!---
<cfset Application.selectfile = "">
<form name="instrument" action="instrumentprogress.cfm?file_path=#file_path#">
	Enter folder to instrument:
	<input name="file_path" type="text">
	<input name="instrumentit" value="Instrument It!" type="submit">
</form>
--->