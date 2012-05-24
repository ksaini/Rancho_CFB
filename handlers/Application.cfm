<cfset Application.selectfile = "">

<!---<cfset baselinecodebase = instrumentedcodebase & '_bak'>--->
<cfset Application.allTags = []>

<!--------Returns a valid tag if present,
    else returns empty string if there is no tag--------------->
<cffunction name="getTag" returntype="Any">
	<cfargument name="toParse"/>

	<cfset result = []>
	<cfset result = REMatch("<[/]*cf[a-z]*[ | >]", toParse)>

	<cfif arraylen(result) gt 0>
		<cfset result[1] = replace(trim(result[1]), ">", "")>
		<cfreturn result[1]>
	</cfif>
	<cfreturn "">
</cffunction>

<cffunction name="isValidTag" returntype="boolean">
	<cfargument name="toParse"/>
	<cfargument name="tagstr" required="false" >

	<cfif findNoCase("<cf",toParse) || findNoCase("</cf",toParse)>
	   <cfreturn 1>
    </cfif>
	<cfreturn 0>
</cffunction>

<!----
	There may be some tags for which tracing is not required.
	There is a list of such tags maintained under /config/doNottrace.txt
----->
<cffunction name="getDoNotTraceMeTag" returntype="Any">
	<cfset doNotTrace = []>
	
	<cfscript>
		myfile1 = FileOpen(#expandpath('.')# & "/config/doNottrace.txt", "read");
		while(NOT FileisEOF(myfile1)){
			x = FileReadLine(myfile1);
			if(len(trim(x)))
				arrayappend(doNotTrace, x);
		}
	</cfscript>
	
	<cfreturn doNotTrace>
</cffunction>

<!----
	By default a trace is added at the start of a valid cf tag/end-tag.
	There are some tags for which trace should be aded at tha last i.e </cfswitch>.
	There is a list of such tags maintained under /config/putTraceAfter.txt
	
----->
<cffunction name="putTraceAfter" returntype="Any">
	<cfset addTraceAfter = []>
	
	<cfscript>
		myfile2 = FileOpen(#expandpath('.')# & "/config/putTraceAfter.txt", "read");
		while(NOT FileisEOF(myfile2)){
			x = FileReadLine(myfile2);
			if(len(trim(x)))
				arrayappend(addTraceAfter, x);
		}
	</cfscript>
	
	<cfreturn addTraceAfter>
</cffunction>

<cffunction name="findInArray" returntype="boolean">
	<cfargument name="myArray" type="array"/>
	<cfargument name="val" type="string"/>
     
	<cfloop array=#myArray# index="name">
		<cfif !CompareNoCase(name, val)>
			<cfreturn 1>
		</cfif>
	</cfloop>
	
	<cfreturn 0>
</cffunction>
