<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<cfparam name="url._format" default="">
<cfparam name="form._format" default="#url._format#">
<cfset a = {}>
<cfset structappend(form, url, true)>
<cfset a.headers = GetHttpRequestData().Headers>
<cfset a.params = form>
<cfset a.cgi = cgi>
<cfif a.params._format eq "xml">
<cfsilent><cfoutput><cfxml variable="myxml"><response><cfloop collection="#a#" item="b"><#b#><cfloop collection="#a[b]#" item="c"><#c#><![CDATA[#(a[b][c])#]]></#c#></cfloop></#b#></cfloop></response></cfxml></cfoutput></cfsilent>
<cfoutput>#myxml#</cfoutput>
<cfelse>
<cfoutput>#SerializeJSON(a)#</cfoutput>
</cfif>