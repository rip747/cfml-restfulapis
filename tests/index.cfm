<cfset request.settings = {}>
<cfset request.settings.domain = 'http://#cgi.http_host#/cfml-restfulapis/tests'>
<cfset request.settings.endPoint = "echo.cfm">
<cfset request.settings.libPath = 'cfml-restfulapis.lib.base'>
<cfset request.settings.testPath = 'cfml-restfulapis.tests.tests'>

<html>
<head>
	<title>Sample unit tests</title>
</head>
<body>
	<cfset test = createObject("component", "Test")>
	<cfset test.runTestPackage(request.settings.testPath)>
	<cfoutput>#test.HTMLFormatTestResults()#</cfoutput>
</body>
</html>