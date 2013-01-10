<cfcomponent output="false" extends="Base">

	<cffunction name="init">
		<cfargument name="oauth_consumer_key" type="string" required="true">
		<cfargument name="access_token" type="string" required="false" hint="only needed for authenticated requests">
		<cfset var loc = {}>
		<cfset loc.defaults = {}>
		
		<cfset loc.defaults.params = {}>
		<cfset StructAppend(loc.defaults.params, arguments)>

		<cfset loc.defaults.baseURL = "https://api.instagram.com/v1/media/popular">
		
		<!--- all request are returned json objects --->
		<cfset after("to_json")>

		<cfreturn super.init(argumentCollection=loc.defaults)>
	</cffunction>
	
</cfcomponent>