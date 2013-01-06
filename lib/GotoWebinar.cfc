<cfcomponent extends="Base" output="true">


	<cffunction name="init">
		<cfargument name="access_token" type="string" required="true" hint="access token for api calls">
		<cfargument name="organizer_key" type="string" required="true" hint="organizer key for api calls">
		<cfset var loc = {}>

		<cfset variables.access_token = arguments.access_token>
		<cfset variables.organizer_key = arguments.organizer_key>
		
		<cfset arguments.baseURL = "https://api.citrixonline.com/G2W/rest/organizers/#variables.organizer_key#/">
		
		<cfset arguments.headers = {}>
		<cfset arguments.headers["Content-type"] = "application/json">
		<cfset arguments.headers["Accept"] = "application/json">
		<cfset arguments.headers["Authorization"] = "OAuth oauth_token=#variables.access_token#">
		
		<cfset StructDelete(arguments, "access_token", false)>
		<cfset StructDelete(arguments, "organizer_key", false)>
		
		<!--- all request are returned json objects --->
		<cfset after("to_json")>
		
		<cfreturn super.init(argumentCollection=arguments)>
	</cffunction>

	<!--- sessions --->

	<cffunction name="get_organizer_sessions">
		<cfreturn get("sessions")>
	</cffunction>
    
	<cffunction name="get_session">
		<cfargument name="webinar_key" type="string" required="true">
		<cfargument name="session_key" type="string" required="true">
		<cfreturn get("webinars/#arguments.webinar_key#/sessions/#arguments.session_key#")>
	</cffunction>
    
	<cffunction name="get_session_attendees">
		<cfargument name="webinar_key" type="string" required="true">
		<cfargument name="session_key" type="string" required="true">
		<cfreturn get("webinars/#arguments.webinar_key#/sessions/#arguments.session_key#/attendees")>
	</cffunction>
    
	<cffunction name="get_session_performance">
		<cfargument name="webinar_key" type="string" required="true">
		<cfargument name="session_key" type="string" required="true">
		<cfreturn get("webinars/#arguments.webinar_key#/sessions/#arguments.session_key#/performance")>
	</cffunction>
    
	<cffunction name="get_session_polls">
		<cfargument name="webinar_key" type="string" required="true">
		<cfargument name="session_key" type="string" required="true">
		<cfreturn get("webinars/#arguments.webinar_key#/sessions/#arguments.session_key#/polls")>
	</cffunction>
    
	<cffunction name="get_session_questions">
		<cfargument name="webinar_key" type="string" required="true">
		<cfargument name="session_key" type="string" required="true">
		<cfreturn get("webinars/#arguments.webinar_key#/sessions/#arguments.session_key#/questions")>
	</cffunction>
    
	<cffunction name="get_session_surveys">
		<cfargument name="webinar_key" type="string" required="true">
		<cfargument name="session_key" type="string" required="true">
		<cfreturn get("webinars/#arguments.webinar_key#/sessions/#arguments.session_key#/surveys")>
	</cffunction>
    
	<cffunction name="get_webinar_sessions">
		<cfargument name="webinar_key" type="string" required="true">
		<cfreturn get("webinars/#arguments.webinar_key#/sessions")>
	</cffunction>
	
	<!--- attendees --->
	
	<cffunction name="get_attendee">
		<cfargument name="webinar_key" type="string" required="true">
		<cfargument name="session_key" type="string" required="true">
		<cfargument name="registrant_key" type="string" required="true">
		<cfreturn get("webinars/#arguments.webinar_key#/sessions/#arguments.session_key#/attendees/#arguments.registrant_key#")>
	</cffunction>
	
	<cffunction name="get_attendee_poll_answers">
		<cfargument name="webinar_key" type="string" required="true">
		<cfargument name="session_key" type="string" required="true">
		<cfargument name="registrant_key" type="string" required="true">
		<cfreturn get("webinars/#arguments.webinar_key#/sessions/#arguments.session_key#/attendees/#arguments.registrant_key#/polls")>
	</cffunction>

	<cffunction name="get_attendee_questions">
		<cfargument name="webinar_key" type="string" required="true">
		<cfargument name="session_key" type="string" required="true">
		<cfargument name="registrant_key" type="string" required="true">
		<cfreturn get("webinars/#arguments.webinar_key#/sessions/#arguments.session_key#/attendees/#arguments.registrant_key#/questions")>
	</cffunction>
    
	<cffunction name="get_attendee_survey_answers">
		<cfargument name="webinar_key" type="string" required="true">
		<cfargument name="session_key" type="string" required="true">
		<cfargument name="registrant_key" type="string" required="true">
		<cfreturn get("webinars/#arguments.webinar_key#/sessions/#arguments.session_key#/attendees/#arguments.registrant_key#/surveys")>
	</cffunction>

	<cffunction name="get_attendees_for_all_webinar_sessions">
		<cfargument name="webinar_key" type="string" required="true">
		<cfreturn get("webinars/#arguments.webinar_key#/attendees")>
	</cffunction>
		
	<!--- registrants --->
	
	<cffunction name="create_registrant">
		<cfargument name="webinar_key" type="string" required="true">
		<cfargument name="params" type="struct" required="true">
		<cfreturn post(endpoint="webinars/#arguments.webinar_key#/registrants", body="#SerializeJSON(arguments.params)#")>
	</cffunction>
    
	<cffunction name="get_registrant">
		<cfargument name="webinar_key" type="string" required="true">
		<cfargument name="registrant_key" type="string" required="true">
		<cfreturn get("webinars/#arguments.webinar_key#/registrants/#arguments.registrant_key#")>
	</cffunction>

	<cffunction name="get_registrants">
		<cfargument name="webinar_key" type="string" required="true">
		<cfreturn get("webinars/#arguments.webinar_key#/registrants")>
	</cffunction>

	<cffunction name="get_registrant_fields">
		<cfargument name="webinar_key" type="string" required="true">
		<cfreturn get("webinars/#arguments.webinar_key#/registrants/fields")>
	</cffunction>
	
	<!--- webinars --->
	
	<cffunction name="get_historical_webinars">
		<cfargument name="params" type="struct" required="false" default="#StructNew()#">
		<cfreturn get(endpoint="historicalWebinars", params="#arguments#")>
	</cffunction>

	<cffunction name="get_upcoming_webinars">
		<cfargument name="params" type="struct" required="false" default="#StructNew()#">
		<cfreturn get(endpoint="upcomingWebinars", params="#arguments#")>
	</cffunction>

	<cffunction name="get_webinar">
		<cfargument name="webinar_key" type="string" required="true">
		<cfreturn get("webinars/#arguments.webinar_key#")>
	</cffunction>

	<cffunction name="get_webinar_meeting_times">
		<cfargument name="webinar_key" type="string" required="true">
		<cfreturn get("webinars/#arguments.webinar_key#/meetingTimes")>
	</cffunction>

	<cffunction name="get_webinars">
		<cfreturn get("webinars")>
	</cffunction>	

</cfcomponent>