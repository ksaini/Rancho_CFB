
<cfset selectfile= url.name >

<cfset backupdir = selectfile & "_bak">

<cfscript>
	if(DirectoryExists(selectfile)){
		filequery = DirectoryList(selectfile, false, "query", "*.cf?");

		// First take a backup of given folder as <foldername_bak> in the same dir
		writeOutput("<b>Taking backup of folder : </b>" & selectfile & ".......<br>");
		getPageContext().getOut().flush();

		copyDirectory(selectfile, backupdir);
		writeOutput("<b>Backup Taken</b><br><br>");
		getPageContext().getOut().flush();

		// Now delete any previous data in baseline.txt file
		FileWrite("#expandPath('.')#/baseline.txt", "<cfset baselinecodebase = ''>");

		// Now Delete  all the files in the dir record and unexecuted
		filestodelete = DirectoryList("#expandPath('.')#/record", true, "query", "*.txt");
		for(todel = 1; todel <= filestodelete.recordcount; todel++){
			FileDelete(filestodelete.directory[todel] & "/" & filestodelete.name[todel]);
		}
		filestodelete = DirectoryList("#expandPath('.')#/unexecuted", true, "query", "*.txt");
		for(todel = 1; todel <= filestodelete.recordcount; todel++){
			FileDelete(filestodelete.directory[todel] & "/" & filestodelete.name[todel]);
		}

		// From the target Folder to instrument, get all cfm/cfcs
		filearray = DirectoryList(selectfile, false, "path", "*.cf?");

		baselinefile = expandpath('.') & "vmannebo" & "baseline.txt";
		bfile = FileOpen(baselinefile, 'write');

		writeoutput("Starting  Instrumenting... <br>");
		for(v = 1; v <= filequery.recordcount; v++){
			// Mark each CFC/CFM for codecoverage
			markForCodeCoverage(filequery.directory[v] & "/" & filequery.name[v] & ".new",
		                        filequery.directory[v] & "/" & filequery.name[v],filequery.name[v]);
			writeOutput("<html><font color='green'><b>Instrumented :</b></font></html>" & filequery.directory[v] & "/" & filequery.name[v] & "....<br>");
			getPageContext().getOut().flush();

			FileWrite("#expandPath('.')#/record/" & filequery.name[v] & ".txt", "");
		}
		FileClose(bfile);
		writeOutput("<html><font color='green'><br><br><b>Instrumentation Done !!!</b></font></html>");
	}

</cfscript>

<cfscript>
	// This function instruments a file for Code coverage. It first parse file for comment
	// and then add traces to instrument the file
	function markForCodeCoverage(string filetoinstrument, string basefile, string basefilename)
	{
		commentstart = 0;
		Application.traceLineCounter=1;
		Application.lineCounter=1;
		start_trace = 1;
		Variables.a = Arraynew(1);
		var str = "";
		//Variables.i = 0;

		a = removeMultilineComment(filetoinstrument, basefile);
		sleep(1000);
		try{
			myfile = FileOpen(basefile, "read");

			instrumentedfile = FileOpen(filetoinstrument, "write");
			while(NOT FileisEOF(myfile)){
				x = FileReadLine(myfile);
				str = #addTrace(x, basefilename)#;
				Application.lineCounter = Application.lineCounter + 1;
				FileWriteLine(instrumentedfile, str);
			}
			FileClose(myfile);
			FileClose(instrumentedfile);
			sleep(1000);
			// Now delete old file and rename new file to old file name
			if(FileExists(basefile))
				FileDelete(basefile);
		}
		catch(exception e){
			WriteDump(e);
		}
		finally{
			FileClose(myfile);
			FileClose(instrumentedfile);
		}
		sleep(1000);
		FileMove(filetoinstrument, basefile);

		if(FileExists(filetoinstrument))
			FileDelete(filetoinstrument);

		FileWriteLine(bfile, basefile & ":" & Application.traceLineCounter);
	}

	function removeMultilineComment(string filetoinstrument, string basefile)
	{
		try{
			mlcomment = 0;//multi line comment
			myfile = FileOpen(basefile, "read");
			instrumentedfile = FileOpen(filetoinstrument, "write");
			while(NOT FileisEOF(myfile)){
				iline = FileReadLine(myfile);
				commentstartposition = findNoCase("<!--", #trim(iline)#);
				commentendposition = findNoCase("-->", #trim(iline)#);
				if(commentstartposition){
					iline =REReplace(iline,"<!---.*--->","");
					commentstartposition=0;
				}

				// Find Multiline comments
				if(mlcomment == 0){
					// if comment block not started
					if(commentstartposition eq 0){
						FileWriteLine(instrumentedfile, iline);
					}
					else{
						mlcomment = 1;
						if(commentendposition neq 0)
							mlcomment = 0;
						FileWriteLine(instrumentedfile, "");
					}
				}
				else{
					FileWriteLine(instrumentedfile, "");
					// Set comment block off
					commentposition = findNoCase("-->", #trim(iline)#);
					if(commentposition gt 0){
						mlcomment = 0;
					}
				}
			}
		}
		catch(exception e){
			WRITEDUMP(e);
		}
		finally{
			sleep(1000);
			FileClose(myfile);
			FileClose(instrumentedfile);
			sleep(1000);
			FileMove(filetoinstrument, basefile);
			sleep(1000);
			if(FileExists(filetoinstrument))
				FileDelete(filetoinstrument);
		}
	}


	// This function contains the actual logic to instrument a file.
	function addTrace(string ftext, string basefilename)
	{
		trace1 = "<cfdump var='" & basefilename & ":" ;
		trace2 = "'  format='text' output='#expandpath('.')#/record/" 	& basefilename & ".txt'>";
		// Use trace 2 to make this tool WebSocket enabled.
		// This will enable to see live code coverage at the run time.
		//trace2 = "'  format='text' output='#expandpath('.')#/record/" 	& basefilename & ".txt'><cfset WSPublish('" & replace(basefilename,'.cfm','') & "',";
		//trace3 = ")>";

		ftext = trim(ftext);
		tag = getTag(ftext);
		isTagValid = isValidTag(ftext, tag & '>');
		inNoTraceList = findInArray(getDoNotTraceMeTag(), tag & '>');
		istraceAfter = findInArray(putTraceAfter(), tag& '>');

		if(len(ftext) && isTagValid && !inNoTraceList && len(tag)){
			//trace = trace1 & #Application.i# & trace2 & #Application.j# & trace3;
			// Without Websocket support
			trace = trace1 & #Application.traceLineCounter# & trace2 ;
			Application.traceLineCounter = Application.traceLineCounter + 1;
		   if(istraceAfter){
		   	// tags can be :
		   	//Case1:	<cfelse>
		   	//Case2:	<cfcase val=xyx>
		   	//Case3:  <cfcase
		   	//			val=xyz>...someother statement
		   	// Case 4: <cfelse>....someother code not ending with >
		   	// For Case 1 and Case2:
		   	//			1. Check if last char of ftext is a '>' then add trace there
		   	// As of now not covering code coverage for case 3/4 for those tags which require trace to be added in the last
		   	// Using code formatting will reduce Case 3 and Case 4 occurrences.
		   	lastchar =left(reverse(trim(ftext)),1);

		   	if((lastchar contains '>') && !(ftext contains '</'))
		   		return ftext & trace ;
		   		//return replace(ftext,tag,tag & '>' & trace) ;
		   	else
		   		return ftext ;
		   }
			return replace(ftext,tag,trace & tag) ;
		}
		else{
			return ftext;
		}
	}

</cfscript>

<cffunction name="copyDirectory" output="false">
	<cfargument name="source" required="true" type="string"/>
	<cfargument name="destination" required="true" type="string"/>

	<cfset var uid = CreateUUID()>
	<cfzip action="zip" file="#GetTempDirectory()##uid#.zip" recurse="yes" source="#arguments.source#"
	       storepath="yes"/>
	<cfif !DirectoryExists("#arguments.destination#")>
		<cfdirectory action="create" directory="#arguments.destination#">
	</cfif>
	<cfzip action="unzip" file="#GetTempDirectory()##uid#.zip" destination="#arguments.destination#"
	       storepath="yes"/>

	<cffile action="delete" file="#GetTempDirectory()##uid#.zip">
</cffunction>
