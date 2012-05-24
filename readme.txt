=== Extention Name ===
Name: RANCHO
Contributors: Kunal Saini
Language: CFML


== Description ==
Rancho as of now supports code coverage for tags in CFML. Script suooprt is not integrated yet.
Rancho adds traces to the cfm to be instrumented. By default a trace is added at the start of a valid cf tag/end.There are some tags for which trace should be aded at the last i.e </cfswitch>. Or no trace is required i.e <cfargument>.

There is a list of such tags maintained under:
		/handlers/config/putTraceAfter.txt
		/handlers/config/doNottrace.txt
Only some tags have been added to these lists. As and when you encounter such tags please add them to
these lists.


== Limitations ==

* Suopprts only tags not script
* Multiple level of folders is not suooprted yet.
* Instrumentation of single file is not supported. Only folders are instrumented.
* Only line coverage is provided.


== Usage ==
* MAke sure files are writable before instrumenting them.
* Use of code formatter is recommended before instrumenting.
* In CFB Navigator go the folder needs to be instrumented.
* Do a right click and on the menue go to Rancho --> Instrument. A new window/page is open(It will take some time. ALso if you are doing it for the sccond time you amy need to regresh the page)
* Now run your testcases.
* Once done again go to folder and go to Rancho --> Code Coverage.
* Report will be generated in Server View. Click on the individual file link to se the line coverage
 