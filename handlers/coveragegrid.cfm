<cfsetting  showdebugoutput="false" >
<div id ="layout" style="float:center;width:700;height:450px;overflow:auto;
position: relative;margin-left: auto;
margin-right: auto;">

<cfscript>
	index=0;
	totalline=0;
	absfilepath="";
	executedline=0;

	codecoveragedir = DirectoryList(#expandpath('.')# & "/record",true,"query","*.txt");
	baseline = FileOpen(expandpath('.') & "/" & "baseline.txt", "read");
	baselinestruct = structnew();
	while(NOT FileisEOF(baseline)) {
		x = FileReadLine(baseline);

	    	file_path= left(x,FindNoCase(".",x)+3);
	    	instrumentedcodebase = reverse(right(reverse(file_path),len(file_path)-findnocase("/",reverse(file_path))));
		    x= reverse(left(reverse(x),FindNoCase("/",reverse(x))-1)) ;
			//y= name of the CFC
			y = left(x,FindNoCase(":",x)-1);
			z= right(x,len(x)-FindNoCase(":",x));
			// z =  LOC in the CFC
			totalline = totalline + z;
			structInsert(baselinestruct,trim(y),trim(z),"yes");
	}
	Application.baselinecodebase = file_path & '_bak';
	WriteOutput("<b><h2 align=center>LOC executed </h2></b><br>" );
	WriteOutput("<b>TOTAL LINES : " & totalline & "</b><br>");
	codecoveragequery = queryNew("CFCName,TotalRow,ExecutedRow,link");
	for(j=1;j<=codecoveragedir.recordcount;j++){
		if(StructKeyExists(baselinestruct,left(codecoveragedir.name[j],len(codecoveragedir.name[j])-4))){
		    baselinefilename = left(codecoveragedir.name[j],len(codecoveragedir.name[j])-4);
			//writeOutput("<b>" & baselinefilename & "</b><br>");
			codeCoverageForFile(codecoveragedir.directory[j] & "/" & codecoveragedir.name[j],baselinefilename);
		}
	}
	WriteOutput("<b>EXECUTED LINES " & executedline );

    drawImg(executedline+1,totalline+1);

	writeOutput( "#Int((executedline/totalline)*100)#%</b><br><br><br>");
	WriteOutput('<table >');
	WriteOutput('<tr bgcolor=##6694E3 height=20>' );
		  WriteOutput('<td width=100 align=center>');
		  	WriteOutput("<b><font color='White'> File Name</font> </b>");
		  WriteOutput('</td>');
		  WriteOutput('<td width=100 align=center>');
		  	WriteOutput("<b><font color='White'> Total Lines</font> </b>");
		  WriteOutput('</td>');
		  WriteOutput('<td width=150 align=center> ');
		  	WriteOutput("<b><font color='White'> Executed Lines</font> </b>");
		  WriteOutput('</td>');
		  WriteOutput('<td width=150 align=center> ');
		  	WriteOutput("<b><font color='White'> Code Coverage </font> </b>");
		  WriteOutput('</td>');
		  WriteOutput('<td>');

		  WriteOutput('</td>');
	WriteOutput('</tr>');
	counter=1;
	for(intRow=1;intRow LTE codecoveragequery.recordcount; intRow=(intRow+1)){
		if(counter EQ 1){
		   	WriteOutput('<tr>');
			counter=0;
		}
		else{
			WriteOutput('<tr bgcolor=##E0ECFF>');
			counter=1;
	    }

	   //WriteOutput('<tr>');
	    WriteOutput('<td>');
			WriteOutput( #codecoveragequery["CFCName"][intRow]# );
		WriteOutput('</td>');
		WriteOutput('<td align=center>');
			WriteOutput( #codecoveragequery["TotalRow"][intRow]#  );
		WriteOutput('</td>');
		WriteOutput('<td align=center>');
			WriteOutput(" <b><font color='Green'>" & #codecoveragequery["ExecutedRow"][intRow]#  & "</font></b>");
		WriteOutput('</td>');
		WriteOutput('<td align=center>');
        if(Int(codecoveragequery["TotalRow"][intRow]))
 			WriteOutput( #evaluate(Int((Int(codecoveragequery["ExecutedRow"][intRow])/Int(codecoveragequery["TotalRow"][intRow]))*100))#  & "%</b>");
		WriteOutput('</td>');
		WriteOutput('<td>');
			drawImg(#codecoveragequery["ExecutedRow"][intRow]#,#codecoveragequery["TotalRow"][intRow]#);
			writeOutput(#codecoveragequery["link"][intRow]#);
		WriteOutput('</td>');
		WriteOutput('</tr>');
	}

	WriteOutput('</table>');

	// Gets the total lines in the file and lines executed
	function codeCoverageForFile(string myfilepath,string baselinefilename){

		myfile = FileOpen(myfilepath, "read");
		exe = structnew();

		structInsert(exe,1,1,"yes");

		while(NOT FileisEOF(myfile)) {
			x = FileReadLine(myfile);
			 if(( findNoCase("cf",trim(x))) ){
	        	x = right(x,len(x)-FindNoCase(":",x));
				y=x;
				if(!structkeyexists(exe,Int(x))){
					structInsert(exe,Int(x),Int(x),"yes");
					index= index +1;
				}
			 }
		}
		FileClose(myfile);
		totallines= structFindkey(baselinestruct,trim(baselinefilename));

		exe = StructSort(exe,"numeric", "ASC" );
		if(index >0){
			executedline = executedline + index +1 ;
		}

		queryAddRow(codecoveragequery);
		querySetCell(codecoveragequery,"CFCName",baselinefilename);
		querySetCell(codecoveragequery,"TotalRow",#Int(totallines[1].value)#);
		if(index >0){
			querySetCell(codecoveragequery,"ExecutedRow",index+1);
		}else{
			querySetCell(codecoveragequery,"ExecutedRow",index);
		}

		index=0;
	    findUnexecutedLines(myfilepath,baselinefilename,exe);
		exe="";
		y="";
	}

	// Gets the line numbers of lines not executed in a file
	function findUnexecutedLines(String myfilepath, string baselinefilename,array exe){

		f1 = FileOpen(expandpath('.') & '/unexecuted/' & baselinefilename & '.txt' ,'write');
		for(var i=1;i < ArrayLen(exe);i++){
        	if((exe[i+1] -exe[i]> 1))
				for(var k=exe[i]+1;k < exe[i+1]; k++){
					FileWriteLine(f1,k);}
				}
		if(totallines[1].value > ArrayLen(exe))
			for(var j=exe[i]+1;j <= totallines[1].value;j++){
				FileWriteLine(f1,j);
			}
		FileClose(f1);
		querySetCell(codecoveragequery,"link","<a href='generate_report.cfm?filename=#baselinefilename#&&file_path=#instrumentedcodebase#/#baselinefilename#' > generate_report</a>");
	}

</cfscript>

<cffunction name="drawImg" >
	<cfargument name="executedline" type="any" required="true">
	<cfargument name="totalline" type="any" required="true">

	<cfscript>
		myImage=ImageNew("",100,10,"rgb","orange");
		ImageSetDrawingColor(myImage,"green");
		ImageSetBackgroundColor(myImage,"red");
		ImageDrawBeveledRect(myImage,0,0,(executedline/totalline)*100,10,"yes","yes");
	</cfscript>
	<cfimage source="#myImage#" action="writeToBrowser" >
</cffunction>
</div>