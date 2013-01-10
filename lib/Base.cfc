<cfcomponent output="false" hint="component to interface with citrixonline GotoWebinar">
	
	<cfset variables.formats = {}>
	
	<cfset variables.instance.defaults = {}>
	<cfset variables.instance.callbacks = {}>
	<cfset variables.instance.callbacks.before = []>
	<cfset variables.instance.callbacks.after = []>


	<cffunction name="init" hint="returns an instance of the object. note that any overloaded arguments will be used for as a cfhttp attribute">
		<cfargument name="baseURL" type="string" required="true" hint="the base url for the api enpoints">
		<cfargument name="timeout" type="numeric" required="false" default="5" hint="maximum time for the request to take">
		<cfargument name="params" type="struct" required="false" default="#StructNew()#" hint="default params that need to be sent with each requests to the api. like a clientid or authenication token">
		<cfargument name="headers" type="struct" required="false" default="#StructNew()#" hint="default headers that need to be sent with each requests to the api">
		<cfargument name="body" type="string" required="false" default="" hint="default body for each api request">
		<cfargument name="format" type="string" required="false" default="json" hint="the format that the response is in so it can be transformed into CFML related variables. available formats are json, xml, raw. while json and xml formats are transformed, a format of raw will return the cfhttp return struct">
		<cfset var loc = {}>

		<cfset variables.instance.defaults.headers = duplicate(arguments.headers)>
		<cfset variables.instance.defaults.params = duplicate(arguments.params)>
		<cfset variables.instance.defaults.body = arguments.body>
		<cfset variables.instance.defaults.format = arguments.format>
		
		<cfset StructDelete(arguments, "headers", false)>
		<cfset StructDelete(arguments, "params", false)>
		<cfset StructDelete(arguments, "body", false)>
		<cfset StructDelete(arguments, "format", false)>
		
		<cfset variables.instance.defaults.settings = duplicate(arguments)>
		
		<cfset register_format_parser("json", "parse_json")>
		<cfset register_format_parser("xml", "parse_xml")>
		
		<cfreturn this>
	</cffunction>


	<cffunction name="get">
		<cfargument name="endpoint" type="string" required="true">
		<cfargument name="params" type="struct" required="false" default="#StructNew()#">
		<cfargument name="headers" type="struct" required="false" default="#StructNew()#">
		<cfargument name="body" type="string" required="false" default="">
		<cfargument name="format" type="string" required="false" default="#variables.instance.defaults.format#">
		<cfset arguments.method = "get">
		<cfreturn makeHttpCall(argumentCollection=arguments)>
	</cffunction>


	<cffunction name="post">
		<cfargument name="endpoint" type="string" required="true">
		<cfargument name="params" type="struct" required="false" default="#StructNew()#">
		<cfargument name="headers" type="struct" required="false" default="#StructNew()#">
		<cfargument name="body" type="string" required="false" default="">
		<cfargument name="format" type="string" required="false" default="#variables.instance.defaults.format#">
		<cfset arguments.method = "post">
		<cfreturn makeHttpCall(argumentCollection=arguments)>
	</cffunction>
	
	
	<cffunction name="delete">
		<cfargument name="endpoint" type="string" required="true">
		<cfargument name="params" type="struct" required="false" default="#StructNew()#">
		<cfargument name="headers" type="struct" required="false" default="#StructNew()#">
		<cfargument name="body" type="string" required="false" default="">
		<cfargument name="format" type="string" required="false" default="#variables.instance.defaults.format#">
		<cfset arguments.method = "delete">
		<cfreturn makeHttpCall(argumentCollection=arguments)>
	</cffunction>
	
	
	<cffunction name="makeHttpCall">
		<cfargument name="method" type="string" required="true">
		<cfargument name="endpoint" type="string" required="true">
		<cfargument name="params" type="struct" required="false" default="#StructNew()#">
		<cfargument name="headers" type="struct" required="false" default="#StructNew()#">
		<cfargument name="body" type="string" required="false" default="">
		<cfargument name="format" type="string" required="false" default="#variables.instance.defaults.format#">
		<cfset var loc = {}>

		<cfset loc.ret = {}>
		<cfset loc.response = {}>
		<cfset loc.response.success = true>
		
		<cfset loc.args = duplicate(variables.instance.defaults)>

		<cfset loc.args.settings["url"] = "#loc.args.settings.baseURL#/#arguments.endpoint#">
		<cfset loc.args.settings["method"] = arguments.method>
		<cfset loc.args.settings["result"] = "loc.ret">
		
		<cfset StructDelete(loc.args.settings, "baseURL", false)>
		<cfset StructAppend(loc.args.params, arguments.params, true)>
		<cfset StructAppend(loc.args.headers, arguments.headers, true)>
		
		<cfset loc.args.body = variables.instance.defaults.body & arguments.body>
		
		<cfset loc.args = callback("before", loc.args)>

		<cftry>
			
			<cfset loc.ret = _cfhttp(argumentCollection=loc.args)>
			<cfset StructAppend(loc.response, duplicate(loc.ret), true)>

			<cfcatch type="any">
				<cfset loc.response.success = false>
				<cfset StructAppend(loc.response, cfcatch, true)>
			</cfcatch>
			
		</cftry>
		
		<cfset loc.response = callback("after", loc.response)>

		<cfif loc.response.success AND StructKeyExists(variables.formats, arguments.format)>
			<cfinvoke method="#variables.formats[arguments.format]#" returnvariable="loc.response" response="#loc.response.filecontent#"/>
		</cfif>

		<cfreturn loc.response>
	</cffunction>


	<cffunction name="before">
		<cfargument name="methodName" type="string" required="true" hint="method to run before making the http call. before callbacks get passed in the arguments scope of the makeHttpCall method">
		<cfset ArrayAppend(variables.instance.callbacks.before, arguments.methodName)>
	</cffunction>


	<cffunction name="after">
		<cfargument name="methodName" type="string" required="true" hint="method to run after making the http call. after callbacks get passed in the cfhttp return struct.">
		<cfset ArrayAppend(variables.instance.callbacks.after, arguments.methodName)>
	</cffunction>	


	<cffunction name="callback">
		<cfargument name="type" type="string" required="true">
		<cfargument name="scope" type="struct" required="true">
		<cfset var loc = {}>
		
		<cfset loc.collection = variables.instance.callbacks[arguments.type]>
		
		<cfloop array="#loc.collection#" index="loc.i">
			<cfinvoke method="#loc.i#" scope="#arguments.scope#" returnvariable="loc.ret"/>
			<cfif StructKeyExists(loc, "ret")>
				<cfset arguments.scope = loc.ret>
			</cfif>
		</cfloop>
		<cfreturn arguments.scope>
	</cffunction>
	
	
	<cffunction name="_cfhttp">
		<cfargument name="settings" type="struct" required="true">
		<cfargument name="headers" type="struct" required="true">
		<cfargument name="params" type="struct" required="true">
		<cfargument name="body" type="string" required="true">
		<cfset var loc = {}>
		
		<cfhttp attributecollection="#arguments.settings#">
			<cfloop collection="#arguments.headers#" item="loc.i">
				<cfhttpparam type="header" name="#loc.i#" value="#arguments.headers[loc.i]#">
			</cfloop>
			<cfif ListFindNoCase("get,delete", arguments.settings.method)>
				<cfloop collection="#arguments.params#" item="loc.i">
					<cfhttpparam type="url" name="#loc.i#" value="#arguments.params[loc.i]#">
				</cfloop>
			<cfelse>
				<cfloop collection="#arguments.params#" item="loc.i">
					<cfhttpparam type="formField" name="#loc.i#" value="#arguments.params[loc.i]#">
				</cfloop>			
			</cfif>
			<cfif len(arguments.body)>
				<cfhttpparam type="body" value="#arguments.body#">
			</cfif>
		</cfhttp>

		<cfreturn loc.ret>
	</cffunction>


	<cffunction name="inspect">
		<cfreturn variables.instance>
	</cffunction>
	
	
	<cffunction name="register_format_parser">
		<cfargument name="format" type="string" required="true" hint="name of the format">
		<cfargument name="method" type="string" required="true" hint="method to parse the format with">
		<cfset variables.formats[arguments.format] = arguments.method>
	</cffunction>
	
	
	<cffunction name="parse_json">
		<cfargument name="response" type="any" required="true">
		<cfreturn DeserializeJSON(arguments.response)>
	</cffunction>
	
	
	<cffunction name="parse_xml">
		<cfargument name="response" type="any" required="true">
		<cfreturn XMLParse(arguments.response)>
	</cffunction>
	
	
</cfcomponent>