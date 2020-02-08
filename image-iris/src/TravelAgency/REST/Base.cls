Class TravelAgency.REST.Base
{

ClassMethod GetJSONData() As %DynamicObject
{
	// Throw our own exception if the request body does not contain valid JSON.
	Try 
	{
		Set obj = ##class(%DynamicObject).%FromJSON(%request.Content)
	} 
	Catch ex 
	{
		Throw ##class(TravelAgency.Exception.BadRequest).%New("Invalid JSON")
	}

	Quit obj
}

ClassMethod ReportHTTPStatusCreated(id As %String = "")
{
	Set %response.Status = ##class(%CSP.REST).#HTTP201CREATED
	Set %response.Headers("Location") = ..ComposeUrlWithId(id)
}

ClassMethod ComposeUrlWithId(id As %String)
{
	Set url=$Piece(%request.URL,"?",1)
	If $Extract(url,*)="/"
	{
		Set url=url_id
	}
	Else 
	{
		Set url=url_"/"_id
	}

	Quit url
}

ClassMethod ErrorHandling(ex)
{
	If ex.%IsA("TravelAgency.Exception.Base") 
	{
		Set %response.Status = ex.#HTTPStatus
		
		If ex.#LogError 
		{
			Do ex.Log() // Write to application error log (^ERRORS)
		}
		
		Set obj = {"error": (ex.Name)}

		Write obj.%ToJSON()

	} 
	Else 
	{
		Set %response.Status = "500 Internal Server Error"
		Do ex.Log() // Write to application error log (^ERRORS)
		Set obj = {"error": ($System.Status.GetOneErrorText(ex.AsStatus()))}
		Write obj.%ToJSON()
	}
}

/// Careful when testing your cache. Many browsers and tools today will ignore the Expires
/// and Cache-Control headers when you are calling the REST endpoint directly. The cache will be
/// used by the browser though, if you are calling the resources from your Web application.
ClassMethod CacheResponse(cacheTimeoutInSeconds As %Integer = 3600)
{
	Set %response.Expires = cacheTimeoutInSeconds
	Set %response.Headers("Cache-Control") = "max-age="_cacheTimeoutInSeconds
}

}
