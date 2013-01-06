<cfcomponent output="false" hint="component to interface with citrixonline GotoWebinar">


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
		<cfset var loc = {}>

		<cfset variables.instance.defaults.headers = duplicate(arguments.headers)>
		<cfset variables.instance.defaults.params = duplicate(arguments.params)>
		<cfset variables.instance.defaults.body = arguments.body>
		
		<cfset StructDelete(arguments, "headers", false)>
		<cfset StructDelete(arguments, "params", false)>
		<cfset StructDelete(arguments, "body", false)>
		
		<cfset variables.instance.defaults.settings = duplicate(arguments)>
		
		<cfreturn this>
	</cffunction>


	<cffunction name="get">
		<cfargument name="endpoint" type="string" required="true">
		<cfargument name="params" type="struct" required="false" default="#StructNew()#">
		<cfargument name="headers" type="struct" required="false" default="#StructNew()#">
		<cfargument name="body" type="string" required="false" default="">
		<cfset arguments.method = "get">
		<cfreturn makeHttpCall(argumentCollection=arguments)>
	</cffunction>


	<cffunction name="post">
		<cfargument name="endpoint" type="string" required="true">
		<cfargument name="params" type="struct" required="false" default="#StructNew()#">
		<cfargument name="headers" type="struct" required="false" default="#StructNew()#">
		<cfargument name="body" type="string" required="false" default="">
		<cfset arguments.method = "post">
		<cfreturn makeHttpCall(argumentCollection=arguments)>
	</cffunction>
	
	
	<cffunction name="delete">
		<cfargument name="endpoint" type="string" required="true">
		<cfargument name="params" type="struct" required="false" default="#StructNew()#">
		<cfargument name="headers" type="struct" required="false" default="#StructNew()#">
		<cfargument name="body" type="string" required="false" default="">
		<cfset arguments.method = "delete">
		<cfreturn makeHttpCall(argumentCollection=arguments)>
	</cffunction>
	
	
	<cffunction name="makeHttpCall">
		<cfargument name="method" type="string" required="true">
		<cfargument name="endpoint" type="string" required="true">
		<cfargument name="params" type="struct" required="false" default="#StructNew()#">
		<cfargument name="headers" type="struct" required="false" default="#StructNew()#">
		<cfargument name="body" type="string" required="false" default="">
		<cfset var loc = {}>
		
		<cfset loc.ret = {}>
		<cfset loc.response = {}>
		<cfset loc.response.success = 1>

		<cfset variables.instance.defaults.settings["url"] = "#variables.instance.defaults.settings.baseURL#/#arguments.endpoint#">
		<cfset variables.instance.defaults.settings["method"] = arguments.method>
		<cfset variables.instance.defaults.settings["result"] = "loc.ret">
		
		<cfset StructDelete(variables.instance.defaults.settings, "baseURL", false)>
		
		<cfset StructAppend(arguments.params, variables.instance.defaults.params, false)>
		<cfset StructAppend(arguments.headers, variables.instance.defaults.headers, false)>
		<cfset arguments.body = variables.instance.defaults.body & arguments.body>
		
		<cfset arguments = callback("before", arguments)>

		<cftry>
			
			<cfset loc.ret = _cfhttp(argumentCollection=variables.instance.defaults)>
			<cfset StructAppend(loc.response, duplicate(loc.ret), true)>

			<cfcatch type="any">
				<cfset loc.response.success = 0>
			</cfcatch>
			
		</cftry>
		
		<cfset loc.response = callback("after", loc.response)>

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
	
	
	<cffunction name="to_json">
		<cfset var loc = {}>
		<cfif arguments.scope.success eq 1 && IsJSON(arguments.scope.filecontent)>
			<cfreturn DeserializeJSON(arguments.scope.filecontent)>
		</cfif>
		<cfreturn StructNew()>
	</cffunction>
	
	
</cfcomponent>