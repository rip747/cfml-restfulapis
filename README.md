This project aims to make creating Restful API wrappers for CFML easier.

What it is
==========

Basically this is just a wrapper for CFHTTP with some sugar and callback support to make writing APIs
a lot less verbose. 

What it ain't
=============

Remember that this can only be used for RESTFUL API services and _IT DOES NOT_ have
any support for registering with a service with OAuth as there are already projects out there that do
such things. You would use the project to interact with the API after you have authenticated with OAuth.


Creating an API Wrapper
=======================
To use, just create a CFC as a warapper for the service that you want to hit against and extend the
Base.cfc in the lib directory.

```coldfusion
<cfcomponent output="false" extends="Base">
</cfcomponent>
```

After extending you will need to overload the Base.cfc `init` method providing the base url for the API,
and any defaults that should be pasted with each request (such as headers and/or params).

```coldfusion
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
	
</cfcomponent>
```

A good example of using default is when an API calls for passing an access token with each request.
Rather then having to worry about passing the access token to each method in your wrapper or asking the
user to provid it with each method call, you can please the access token in the
`variables.instance.defaults.params` scope and they will be pasted for you with each request.

For further examples, see the wrappers that come with this project in the `lib` directory.


API Calling Methods
===================

To make things easier, this wrapper provides methods for calling the API. The `get`, `post` and `delete`
method are shortcuts for calling the CFHTTP and CFHTTPPARAM tags and returning the results. Depending
upon which method you use, underneath it will automatically know to use either `URL` for `FormFields`
when calling your API. `get` and `delete` use the `URL` and `post` will use the `FormFields`.

Each method takes the endpoint as the first argument and then any addition params or headers. An example
of using the `get` method is below. Notice how compact the code is since we just can pass the `arguments`
scope as a second parameter.

```coldfusion
	<cffunction name="media_search" description="Search for media in a given area">
		<cfargument name="lat" type="string" required="true" hint="Latitude of the center search coordinate.">
		<cfargument name="lng" type="string" required="true" hint="Longitude of the center search coordinate.">
		<cfargument name="max_timestamp" type="string" required="false" hint="A unix timestamp. All media returned will be taken earlier than this timestamp.">
		<cfargument name="min_timestamp" type="string" required="false" hint="A unix timestamp. All media returned will be taken later than this timestamp.">
		<cfargument name="distance" type="numeric" required="false" hint="Default is 1km.">
		<cfreturn get("media/search", arguments)>
	</cffunction>
```

Callbacks
=========

Sometimes you will need to intercept the API call. This can be before or after the call is made. To
things easier you can register a or multiple callback methods using the `before` or `after` methods
within your wrappers' `init` method. These callbacks will then execute in order.

Below is an example of using an `after` callback is to alter the response returned from the API. By
default the Base component will return the CFHTTP struct. However, most APIs return their reponses in
JSON. In order to do this, you can register the built in `to_json` method as an `after` callback. This
will modify the response so that it will always be a deserialized json object returned.

```coldfusion
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

```

Methods
=======

`get` - make a GET request to the API

`post` - make a POST request to the API

`delete` - make a DELETE request to the API

`before` - register a before callback

`after` - register an after callback

`inspect` - returns the variables set on the instance


Usage
=====

Simply copy the available wrappers (or the entire lib directory) to your project. Then create an
instance of the wrapper you want to use like so:

```coldfusion
<cfset instagram = createObject("component", "Instagram").init("YOUR_CLIENT_ID", "YOUR_ACCESS_TOKEN")>
<cfset info = instagram.user_info("self")>
<cfdump var="#info#">
```


Problems? Issues? Enhancements?
===============================

__Send a pull request!!! Don't know how? [LEARN!!!][1]__

Seriously, if open a ticket for an issue or an enhancement and it doesn't have a pull request, I will
delete your ticket. Simple as that. Don't like it? Don't use my code.


[1]: https://help.github.com/articles/using-pull-requests