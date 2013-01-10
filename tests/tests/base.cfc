<cfcomponent extends="cfml-restfulapis.tests.Test">

	<cffunction name="setup">
		<cfset loc.restful = createobject("component", request.settings.libPath).init(request.settings.domain)>
	</cffunction>

	<cffunction name="test_created_instance">
		<cfset loc.a = loc.restful.inspect()>
		<cfset assert("StructKeyExists(loc.a, 'defaults')")>
		<cfset assert("StructKeyExists(loc.a, 'callbacks')")>
	</cffunction>

	<cffunction name="test_makeHttpCall_basic">
		<cfset loc.a = loc.restful.makeHttpCall(method="get", endpoint="#request.settings.endPoint#")>
		<cfset assert("!StructIsEmpty(loc.a)")>
		<cfset assert("StructKeyExists(loc.a, 'success')")>
		<cfset assert("loc.a.success eq 1")>
	</cffunction>
	
	<cffunction name="test_makeHttpCall_with_callbacks">
		<cfset loc.restful.copy_to_variables = copy_to_variables>
		<cfset loc.restful.before_callback = before_callback>
		<cfset loc.restful.after_callback = after_callback>
		<cfset loc.restful.copy_to_variables("before_callback")>
		<cfset loc.restful.copy_to_variables("after_callback")>
		<cfset loc.restful.before("before_callback")>
		<cfset loc.restful.after("after_callback")>
		
		<cfset loc.a = loc.restful.makeHttpCall(method="get", endpoint="#request.settings.endPoint#")>
		
		<cfset loc.b = loc.restful.inspect()>
		
		<cfset assert("StructKeyExists(loc.b, 'before_scope')")>
		<cfset assert("StructKeyExists(loc.b.before_scope, 'tony')")>
		<cfset assert("loc.b.before_scope.tony eq 'petruzzi'")>
		
		<cfset assert("StructKeyExists(loc.b, 'after_scope')")>
		<cfset assert("StructKeyExists(loc.b.after_scope, 'per')")>
		<cfset assert("loc.b.after_scope.per eq 'djurner'")>
	</cffunction>
	
	<cffunction name="test_makeHttpCall_with_defaults">
		<cfset loc.headers = {}>
		<cfset loc.headers["Tony"] = "Petruzzi">
		
		<cfset loc.params = {}>
		<cfset loc.params["Per"] = "Djurner">

		<cfset loc.restful = createobject("component", request.settings.libPath).init(
			baseurl = request.settings.domain
			,headers = loc.headers
			,params = loc.params
		)>
		
		<cfset loc.a = loc.restful.makeHttpCall(method="get", endpoint="#request.settings.endPoint#")>
		<cfset loc.b = DeserializeJSON(loc.a.filecontent)>
		
		<cfset assert("StructKeyExists(loc.b.headers, 'Tony')")>
		<cfset assert("loc.b.headers.tony eq 'petruzzi'")>
		
		<cfset assert("StructKeyExists(loc.b.params, 'Per')")>
		<cfset assert("loc.b.params.per eq 'djurner'")>
	</cffunction>
	
	<cffunction name="test_callback_transforms_response_to_json">
		<cfset loc.restful.copy_to_variables = copy_to_variables>
		<cfset loc.restful.before_callback = before_callback>
		<cfset loc.restful.after_callback_to_json = after_callback_to_json>
		<cfset loc.restful.copy_to_variables("before_callback")>
		<cfset loc.restful.copy_to_variables("after_callback_to_json")>
		<cfset loc.restful.before("before_callback")>
		<cfset loc.restful.after("after_callback_to_json")>
		
		<cfset loc.a = loc.restful.makeHttpCall(method="get", endpoint="#request.settings.endPoint#")>

		<cfset assert("StructKeyExists(loc.a, 'cgi')")>
	</cffunction>
	
	<cffunction name="before_callback">
		<cfset arguments.scope.tony = "petruzzi">
		<cfset variables.instance.before_scope = duplicate(arguments.scope)>
	</cffunction>
	
	<cffunction name="after_callback">
		<cfset arguments.scope.per = "djurner">
		<cfset variables.instance.after_scope = duplicate(arguments.scope)>
	</cffunction>
	
	<cffunction name="after_callback_to_json">
		<cfset var loc = {}>
		<cfif arguments.scope.success eq 1 && IsJSON(arguments.scope.filecontent)>
			<cfreturn DeserializeJSON(arguments.scope.filecontent)>
		</cfif>
		<cfreturn StructNew()>
	</cffunction>
	
	<cffunction name="copy_to_variables">
		<cfargument name="method" type="string" required="true">
		<cfset variables[arguments.method] = this[arguments.method]>
	</cffunction>

</cfcomponent>