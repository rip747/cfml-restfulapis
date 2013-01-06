<cfcomponent output="false" extends="Base">

	<cffunction name="init">
		<cfargument name="client_id" type="string" required="false">
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

	<!--- users --->

	<cffunction name="user_info" description="Get basic information about a user">
		<cfargument name="user_id" type="string" required="true" hint="Pass 'self' to get details of the acting user.">
		<cfreturn get("users/#arguments.user_id#")>
	</cffunction>

	<cffunction name="user_feed" description="See the authenticated user's feed">
		<cfargument name="count" type="numeric" required="false" hint="Count of media to return">
		<cfargument name="max_id" type="string" required="false" hint="Return media earlier than this max_id">
		<cfargument name="min_id" type="string" required="false" hint="Return media later than this max_id">
		<cfreturn get("users/self/feed", arguments)>
	</cffunction>

	<cffunction name="user_recent" description="Get the most recent media published by a user.">
		<cfargument name="user_id" type="string" required="true" hint="The id of the user you're interested in">
		<cfargument name="count" type="numeric" required="false" hint="Count of media to return">
		<cfargument name="max_id" type="string" required="false" hint="Return media earlier than this max_id">
		<cfargument name="min_id" type="string" required="false" hint="Return media later than this max_id">
		<cfargument name="max_timestamp" type="string" required="false" hint="Return media before this UNIX timestamp">
		<cfargument name="min_timestamp" type="string" required="false" hint="Return media after this UNIX timestamp">
		<cfset var userid = arguments.user_id>
		<cfset StructDelete(arguments, "user_id", false)>
		<cfreturn get("users/#userid#/media/recent", arguments)>
	</cffunction>

	<cffunction name="user_like" description="See the authenticated user's list of media they've liked">
		<cfargument name="count" type="numeric" required="false" hint="Count of media to return">
		<cfargument name="max_like_id" type="string" required="false" hint="Return media liked before this id">
		<cfreturn get("users/self/media/liked", arguments)>
	</cffunction>

	<cffunction name="user_search" description="Search for a user by name" returntype="struct" access="public" output="false">
		<cfargument name="q" type="string" required="true" hint="A name to search for">
		<cfargument name="count" type="numeric" required="false" hint="Number of users to return">
		<cfreturn get("users/search", arguments)>
	</cffunction>

	<!--- relationships --->

	<cffunction name="user_follows" description="Get the list of users this user follows">
		<cfargument name="user_id" type="string" required="true" hint="Pass 'self' to get details of the acting user.">
		<cfreturn get("users/#arguments.user_id#/follows")>
	</cffunction>

	<cffunction name="user_followed_by" description="Get the list of users this user is followed by">
		<cfargument name="user_id" type="string" required="true" hint="Pass 'self' to get details of the acting user.">
		<cfreturn get("users/#arguments.user_id#/followed-by")>
	</cffunction>

	<cffunction name="user_requested_by" description="List the users who have requested this user's permission to follow">
		<cfreturn get("users/self/requested-by")>
	</cffunction>

	<cffunction name="user_relationship" description="Get information about a relationship to another user.">
		<cfargument name="user_id" type="string" required="true" hint="Pass 'self' to get details of the acting user.">
		<cfreturn get("users/#arguments.user_id#/relationship")>
	</cffunction>
	
	<cffunction name="user_relationship_modify" description="Modify the relationship between the current user and the target user.">
		<cfargument name="user_id" type="string" required="true" hint="Pass 'self' to get details of the acting user.">
		<cfargument name="action" type="string" required="false" hint="Only used to change relationship. One of follow/unfollow/block/unblock/approve/deny.">
		<cfset var userid = arguments.user_id>
		<cfset StructDelete(arguments, "user_id", false)>
		<cfreturn post("users/#arguments.user_id#/relationship", arguments)>
	</cffunction>

	<!--- media --->

	<cffunction name="media" description="Get information about a media object">
		<cfargument name="media_id" type="string" required="true" hint="ID of the object to be retrieved.">
		<cfreturn get("media/#arguments.media_id#")>
	</cffunction>

	<cffunction name="media_search" description="Search for media in a given area">
		<cfargument name="lat" type="string" required="true" hint="Latitude of the center search coordinate.">
		<cfargument name="lng" type="string" required="true" hint="Longitude of the center search coordinate.">
		<cfargument name="max_timestamp" type="string" required="false" hint="A unix timestamp. All media returned will be taken earlier than this timestamp.">
		<cfargument name="min_timestamp" type="string" required="false" hint="A unix timestamp. All media returned will be taken later than this timestamp.">
		<cfargument name="distance" type="numeric" required="false" hint="Default is 1km.">
		<cfreturn get("media/search", arguments)>
	</cffunction>

	<cffunction name="media_popular" description="Get a list of what media is most popular at the moment">
		<cfreturn get("media/popular")>
	</cffunction>

	<!--- comments --->

	<cffunction name="comments" description="Get a full list of comments on a media">
		<cfargument name="media_id" type="string" required="true" hint="ID of the object to be retrieved.">
		<cfreturn get("media/#arguments.media_id#/comments")>
	</cffunction>

	<cffunction name="comment_add" description="Create a comment on a media">
		<cfargument name="media_id" type="string" required="true" hint="ID of the object to be retrieved.">
		<cfargument name="text" type="string" required="true" hint="Text to post as a comment on the media.">
		<cfset var mediaid = arguments.media_id>
		<cfset StructDelete(arguments, "user_id", false)>
		<cfreturn post("media/#mediaid#/comments", arguments)>
	</cffunction>

	<cffunction name="comment_delete" description="Create a comment on a media">
		<cfargument name="media_id" type="string" required="true" hint="ID of the object to be retrieved.">
		<cfargument name="comment_id" type="string" required="true" hint="The id of the comment to be deleted.">
		<cfreturn delete("media/#arguments.media_id#/comments/#arguments.comment_id#")>
	</cffunction>

	<!--- likes --->
	
	<cffunction name="likes" description="Get a list of users who have liked this media.">
		<cfargument name="media_id" type="string" required="true" hint="ID of the object to be retrieved.">
		<cfreturn get("media/#arguments.media_id#/likes")>
	</cffunction>

	<cffunction name="likes_add" description="Set a like on this media by the currently authenticated user.">
		<cfargument name="media_id" type="string" required="true" hint="ID of the object to be retrieved.">
		<cfreturn post("media/#arguments.media_id#/likes")>
	</cffunction>

	<cffunction name="likes_delete" description="Remove a like on this media by the currently authenticated user.">
		<cfargument name="media_id" type="string" required="true" hint="ID of the object to be retrieved.">
		<cfreturn delete("media/#arguments.media_id#/likes")>
	</cffunction>

	<!--- tags --->

	<cffunction name="tags" description="Get information about a tag object">
		<cfargument name="tag_name" type="string" required="true" hint="ID of the object to be retrieved.">
		<cfreturn get("tags/#arguments.tag_name#")>
	</cffunction>

	<cffunction name="tags_recent" description="Gets a list of recently tagged media">
		<cfargument name="tag_name" type="string" required="true" hint="ID of the object to be retrieved.">
		<cfreturn get("tags/#arguments.tag_name#/media/recent")>
	</cffunction>

	<cffunction name="tags_search" description="Search for tags by name - results are ordered first as an exact match, then by popularity">
		<cfargument name="q" type="string" required="true" hint="valid tag name without a leading ##. (eg. snow, nofilter)">
		<cfreturn get("tags/search", arguments)>
	</cffunction>

	<!--- locations --->

	<cffunction name="locations" description="Get information about a location">
		<cfargument name="location_id" type="string" required="true" hint="ID of the object to be retrieved.">
		<cfreturn get("locations/#arguments.location_id#")>
	</cffunction>

	<cffunction name="locations_recent" description="Get a list of recent media objects from a given location">
		<cfargument name="location_id" type="string" required="true" hint="ID of the object to be retrieved.">
		<cfargument name="max_id" type="string" required="false" hint="Return media after this max_id.">
		<cfargument name="min_id" type="string" required="false" hint="Return media before this max_id.">
		<cfargument name="min_timestamp" type="string" required="false" hint="Return media after this UNIX timestamp.">
		<cfargument name="max_timestamp" type="string" required="false" hint="Return media before this UNIX timestamp.">
		<cfset var locationid = arguments.location_id>
		<cfset StructDelete(arguments, "location_id", false)>
		<cfreturn get("locations/#arguments.locationid#/media/recent", arguments)>
	</cffunction>

	<cffunction name="locationSearch" description="Search for a location by geographic coordinate" returntype="struct" access="public" output="false">
		<cfargument name="lat" type="string" required="false" hint="Latitude of the center search coordinate.">
		<cfargument name="lng" type="string" required="false" hint="Longitude of the center search coordinate.">
		<cfargument name="foursquare_v2_id" type="string" required="false" hint="Returns a location mapped off of a foursquare v2 api location id. If used, you are not required to use lat and lng">
		<cfargument name="distance" type="numeric" required="false" hint="Default is 1000m (distance=1000), max distance is 5000">
		<cfreturn get("locations/search", arguments)>
	</cffunction>
	
	<!--- geographies --->
	
	<cffunction name="geographies" description="Get very recent media from a geography subscription that you created.">
		<cfargument name="geo_id" type="string" required="true" hint="ID of the object to be retrieved.">
		<cfargument name="count" type="numeric" required="false" hint="Max number of media to return.">
		<cfargument name="min_id" type="string" required="true" hint="Return media before this min_id.">
		<cfset var geoid = arguments.geo_id>
		<cfset StructDelete(arguments, "geo_id", false)>
		<cfreturn get("/geographies/#geoid#/media/recent")>
	</cffunction>

</cfcomponent>