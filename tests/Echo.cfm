<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<cfset a = {}>
<cfset structappend(form, url, true)>
<cfset a.headers = GetHttpRequestData().Headers>
<cfset a.params = form>
<cfset a.cgi = cgi>
<cfoutput>#SerializeJSON(a)#</cfoutput>