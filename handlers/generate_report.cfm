<style type="text/css" media="screen">
    @import url('./style.css');

</style>
<html>
<!-----
	This file shows report containing line coverage for an individual file
------>
<cfif isDefined("filename")>
	<cfset baselinecodebase = reverse(right(reverse(file_path),len(file_path)-findnocase("/",reverse(file_path)))) & '_bak'>
	<cfset dir = DirectoryList(baselinecodebase,true,"query","*.cf?")>

	<cfquery dbtype="query" name="file_name">
	  SELECT directory,name
	  FROM dir where dir.name = '#filename#'
	</cfquery>

	<cfscript>
	 color="black";
	 Variables.a = Arraynew(1);
	 str ="";

	 Variables.i=1;
	 // Open instrumented file
	 instrumented_file = FileOpen(file_path, "read");
	 // Open baseline file
	 baseline_file = FileOpen(file_name.directory & "/" & file_name.name, "read");

	 //Open un-executed file
	 codecoveragedir = DirectoryList(#expandpath('.')# & "/unexecuted",true,"query","*.txt");
	 unreadline = FileOpen(expandpath('.') & "/unexecuted/" & filename & ".txt", "read");

	 // Get all unexecuted LOC of file in an struct
	 exe = structnew();
	 try{
		while(NOT FileisEOF(unreadline)){
			x = FileReadLine(unreadline);
			if(!structkeyexists(exe,#Int(x)#)){
				structInsert(exe,#Int(x)#,#Int(x)#,"yes");
			}
		}
		StructSort(exe,"numeric");
		FileClose(unreadline);

	// Now loop through Instrumented file , for any line not there in exe struct imples
	// LOC not covered add a comment <!---$$--> there to mark that Line as unexecuted
	// First take a backup of instrumented file
		FileMove(instrumented_file.path,expandpath('.') & "/temp.txt");

		//open this back up file in write mode
		instrumented_file_backup = FileOpen(expandpath('.') & "/temp.txt", "write");
	    counter =0;
	    // Now mark $$ for lines not executed
		while(NOT FileisEOF(instrumented_file)){
			x = FileReadLine(instrumented_file);
			if(len(#trim(x)#) gt 0){
				if(findNoCase("format=",x)){
				linecount = left(x,findNoCase("format",x)-4);
				linecount = right(linecount,len(linecount) - findNoCase(":",linecount));
				// $$ ==> line unecxecuted
				// @@ ==> Line covered
				// **==> Comment
				// Nothing ==> non CF/Not to be covered code

					if(structkeyexists(exe,linecount)){
						str = "<!---$$--->" & x;
						FileWriteLine(instrumented_file_backup,str);
					}else{
						str = "<!---@@--->" & x;
						FileWriteLine(instrumented_file_backup,str);
					}
				}else{
					FileWriteLine(instrumented_file_backup,x);}
			}else{
				FileWriteLine(instrumented_file_backup,"<!---**--->");
			}
		}
		// Now close instrumented_file and instrumented_file_backup
		FileClose(instrumented_file);
		FileClose(instrumented_file_backup);

		// We have baseline file already open, reopen backup instrumented file 'instrumented_file_backup'
		// Go through baseline file if for any line in baseline there is <!---$$--> in backup file==> line not executed
		// Mark that line in red
		instrumented_file_backup = FileOpen(expandpath('.') & "/temp.txt", "read");
		counter =0;
		while(NOT FileisEOF(baseline_file)){
			counter= counter+1;
			original = FileReadLine(baseline_file);
			unread = FileReadLine(instrumented_file_backup);
			tag = getTag(original);
			original1 = left(original,findnocase(tag,original));
			if(len(original)){
				original2 = right(original,len(original) - findnocase(tag,original)- len(tag)+1);
			}

			writeoutput('<table cellspacing="0" cellpadding="0">');
			// $$ ==> line unecxecuted
			// @@ ==> Line covered
			// **==> Comment
			// Nothing ==> non CF/Not to be covered code
			if(findnocase("$$",unread)){
				writeoutput("<tr><td align='right' class='lineCount Bad' width=30>" & counter & "</td>");
				writeoutput("<td class='coverageCount Bad ' width=40>&nbsp;&nbsp;</td>");
				writeoutput("<td class='  srcCell'><span class='spacer' ></span>");writeoutput('<span class="srcLine">');
				writeoutput("<span class='srcLineHilight'>");

				if(len(tag) && len(original1)){
					writeOutput(HTMLEditFormat(original1));
					writeoutput('<span class="keyword">');
					writeOutput(HTMLEditFormat(replace(tag,'<',"")));
					writeOutput("</span>");
					writeOutput(HTMLEditFormat(original2));
				}
				writeOutput("</span>");
			}else if(findnocase("**",unread)){
				writeoutput("<tr><td align='right' class='lineCount NoHilight' width=30>" & counter & "</td>");
				writeoutput("<td class='coverageCount NoHilight ' width=40>&nbsp;&nbsp;</td>");
				writeoutput("<td class='  srcCell'><span class='spacer'></span>");writeoutput('<span class="srcLine">');
				writeoutput("<span class='comment'>");
				writeOutput(" <html><font >" & HTMLEditFormat(original) & "</font></html><br>");
				writeOutput("</span>");
			}else if(findnocase("@@",unread)){
				writeoutput("<tr><td align='right' class='lineCount Good' width=30>" & counter & "</td>");
				writeoutput("<td class='coverageCount Good ' width=40>&nbsp;&nbsp;</td>");
			    writeoutput("<td class='  srcCell'><span class='spacer'></span>");writeoutput('<span class="srcLine">');
				if(len(tag) && len(original1)){
					writeOutput(HTMLEditFormat(original1));
					writeoutput('<span class="keyword">');
					writeOutput(HTMLEditFormat(replace(tag,'<',"")));
					writeOutput("</span>");

				}
				writeOutput(HTMLEditFormat(original2));
			}else{
				writeoutput("<tr><td align='right' class='lineCount NoHilight' width=30>" & counter & "</td>");
				writeoutput("<td class='coverageCount NoHilight ' width=40>&nbsp;&nbsp;</td>");
			    writeoutput("<td class='  srcCell'><span class='spacer'></span>");writeoutput('<span class="srcLine">');
			    writeoutput("<span class='comment'>");
				writeOutput(" <html><font color='black'>" & HTMLEditFormat(original) & "</font></html><br>");
				writeOutput("</span>");
			}
			writeOutput("</span>");writeoutput("</td>");
			writeoutput("</tr>");
		}

		}catch(exception e){}
		finally{
			FileClose(instrumented_file);
			FileClose(unreadline);
			FileClose(baseline_file);
			FileClose(instrumented_file_backup);
	   }
	</cfscript>
</cfif>