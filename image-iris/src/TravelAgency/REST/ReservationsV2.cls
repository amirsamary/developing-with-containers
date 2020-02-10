Include MyAppMacros

Class TravelAgency.REST.ReservationsV2 Extends (TravelAgency.REST.Base, %CSP.REST)
{

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
	<Route Url="/:id" Method="GET" Call="ImplGet" />
	<Route Url="" Method="POST" Call="ImplCreate" />
	<Route Url="" Method="GET" Call="ImplGetAll" />
	<Route Url="/:id" Method="PUT" Call="ImplFullUpdate" />
	<Route Url="/:id" Method="PATCH" Call="ImplSelectiveUpdate" />
	<Route Url="/:id" Method="DELETE" Call="ImplDelete" />
</Routes>
}

/// GET
ClassMethod ImplGet(id As %String)
{
	Set reservation = ##class(TravelAgency.Data.Reservation).%OpenId(id)
	If reservation=""
	{
		Set %response.Status = ##class(%CSP.REST).#HTTP404NOTFOUND
		Quit $$$OK
	}

	Set output = {
		"id": (reservation.%Id()),
		"customer": (reservation.Customer),
		"startLocation": (reservation.StartLocation),
		"destination": (reservation.Destination),
		"startDate": ($ZDate(reservation.StartDate,3)),
		"endDate": ($ZDate(reservation.EndDate,3))
	}

	Write output.%ToJSON()

	Quit $$$OK
}

/// POST
ClassMethod ImplCreate() As %Status
{
	Try 
	{
		Set input = ##class(%DynamicObject).%FromJSON(%request.Content)
	} 
	Catch 
	{
		Set %response.Status=##class(%CSP.REST).#HTTP400BADREQUEST
		Return $$$OK
	}

	Set reservation = ##class(TravelAgency.Data.Reservation).%New()
	If reservation = ""
	{
		Set %response.Status=##class(%CSP.REST).#HTTP404NOTFOUND
		Quit $$$OK
	}

	Set reservation.Customer = $zstrip(input.customer,"<>W")
	Set reservation.StartLocation = $zstrip(input.startLocation,"<>W")
	Set reservation.Destination = $zstrip(input.destination,"<>W")
	Set reservation.StartDate = $ZDateH(input.startDate,3)
	Set reservation.EndDate = $ZDateH(input.endDate,3)

	Set status = reservation.%Save()

	Quit status
}

/// GET
ClassMethod ImplGetAll() As %Status
{
	Set obj = {"reservations":[]}

	Set rs = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID FROM TravelAgency_Data.Reservation")

	While rs.%Next()
	{
		Set reservation = ##class(TravelAgency.Data.Reservation).%OpenId(rs.%Get("ID"))
		Set output = {
			"id": (reservation.%Id()),
			"customer": (reservation.Customer),
			"startLocation": (reservation.StartLocation),
			"destination": (reservation.Destination),
			"startDate": ($ZDate(reservation.StartDate,3)),
			"endDate": ($ZDate(reservation.EndDate,3))
		}

		Do obj.reservations.%Push(output)
	}

	Write obj.%ToJSON()

	Quit $$$OK
}

/// PUT - Updates all properties on the data model.
ClassMethod ImplFullUpdate(id As %String, input As %DynamicObject) As %Status
{
	Try 
	{
		Set input = ##class(%DynamicObject).%FromJSON(%request.Content)
	} 
	Catch 
	{
		Set %response.Status=##class(%CSP.REST).#HTTP400BADREQUEST
		Return $$$OK
	}

	Set reservation = ##class(TravelAgency.Data.Reservation).%OpenId(id)
	If reservation = ""
	{
		Set %response.Status=##class(%CSP.REST).#HTTP404NOTFOUND
		Quit $$$OK
	}

	Set reservation.Customer = $zstrip(input.customer,"<>W")	
	Set reservation.StartLocation = $zstrip(input.startLocation,"<>W")
	Set reservation.Destination = $zstrip(input.destination,"<>W")
	Set reservation.StartDate = $ZDateH(input.startDate,3)
	Set reservation.EndDate = $ZDateH(input.endDate,3)
	
	Set status = reservation.%Save()

	Quit status
}

/// PATCH
ClassMethod ImplSelectiveUpdate(id As %String) As %Status
{
	Try 
	{
		Set input = ##class(%DynamicObject).%FromJSON(%request.Content)
	} 
	Catch 
	{
		Set %response.Status=##class(%CSP.REST).#HTTP400BADREQUEST
		Return $$$OK
	}

	Set reservation = ##class(TravelAgency.Data.Reservation).%OpenId(id)
	If reservation = ""
	{
		Set %response.Status=##class(%CSP.REST).#HTTP404NOTFOUND
		Quit $$$OK
	}

	If input.%IsDefined("customer") {
		Set reservation.Customer = $zstrip(input.customer,"<>W")
	}
	
	If input.%IsDefined("startLocation") {
		Set reservation.StartLocation = $zstrip(input.startLocation,"<>W")
	}	
	
	If input.%IsDefined("destination") {
		Set reservation.Destination = $zstrip(input.destination,"<>W")
	}
	
	If input.%IsDefined("startDate") {
		Set reservation.StartDate = $ZDateH(input.startDate,3)
	}
	
	If input.%IsDefined("endDate") {
		Set reservation.EndDate = $ZDateH(input.endDate,3)
	}

	Set status = reservation.%Save()

	Quit status
}

/// DELETE - It is not idempotent.
ClassMethod ImplDelete(id As %String) As %Status
{
	If '##class(TravelAgency.Data.Reservation).%ExistsId(id)
	{
		Set %response.Status=##class(%CSP.REST).#HTTP404NOTFOUND
		Quit $$$OK
	}

	Quit ##class(TravelAgency.Data.Reservation).%DeleteId(id)
}

}
