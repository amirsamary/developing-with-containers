Include MyAppMacros

Class TravelAgency.REST.Reservations Extends (TravelAgency.REST.Base, %CSP.REST)
{

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="" Method="GET" Call="ImplGetAll" />
<Route Url="" Method="POST" Call="ImplCreate" />
<Route Url="/:id" Method="GET" Call="ImplGet" />
<Route Url="/:id" Method="PUT" Call="ImplFullUpdate" />
<Route Url="/:id" Method="PATCH" Call="ImplSelectiveUpdate" />
<Route Url="/:id" Method="DELETE" Call="ImplDelete" />
</Routes>
}

ClassMethod ImplGetAll() As %Status
{
	Try 
	{
		Set obj = {"reservations":[]}

		Set rs = ##class(%SQL.Statement).%ExecDirect(,"SELECT ID FROM TravelAgency_Data.Reservation")
		$$$ThrowSQLExceptionIfResultError(rs, "GetAllSQLReservationsStatementException")

		While rs.%Next()
		{
			Do obj.reservations.%Push(..DataModelToJSONObject(rs.%Get("ID")))
		}

		Write obj.%ToJSON()
	} 
	Catch ex 
	{
		Do ..ErrorHandling(ex)
	}

	Quit $$$OK
}

ClassMethod ImplGet(id As %String)
{
	Try 
	{
		Set reservation = ##class(TravelAgency.Data.Reservation).%OpenId(id)

		Set output = ..DataModelToJSONObject(reservation)

		Write output.%ToJSON()
	} 
	Catch ex 
	{
		Do ..ErrorHandling(ex)
	}
	Quit $$$OK
}

/// This looks pretty straighfoward now. But a JSON document may be created with data
/// coming not from one single object like in this example, but from a graph of related 
/// objects on the database. So it is useful to encapsulate this on a single method.
ClassMethod DataModelToJSONObject(idOrObjectref) As %DynamicObject
{
	If $IsObject(idOrObjectref)
	{
		Set reservation = idOrObjectref
	}
	Else
	{
		Set reservation = ##class(TravelAgency.Data.Reservation).%OpenId(idOrObjectref)
	}

	Set output = {
		"id": (reservation.%Id()),
		"customer": (reservation.Customer),
		"startLocation": (reservation.StartLocation),
		"destination": (reservation.Destination),
		"startDate": ($ZDate(reservation.StartDate,3)),
		"endDate": ($ZDate(reservation.EndDate,3))
	}

	Quit output
}

ClassMethod ImplCreate() As %Status
{
	Try 
	{
		Set input = ..GetJSONData()

		Do ..Validate(input)

		Set reservation = ##class(TravelAgency.Data.Reservation).%New()
		
		Do ..JSONObjectToDataModel(input, .reservation)
		
		Set status = reservation.%Save()
		$$$ThrowStatusExceptionIfError(status, "SaveReservationException")

		Do ..ReportHTTPStatusCreated(reservation.%Id())
	} 
	Catch ex 
	{
		Do ..ErrorHandling(ex)
	}

	Quit $$$OK
}

ClassMethod Validate(reservation As %Library.DynamicObject)
{
	If reservation.customer = "" {
		$$$ThrowBadRequestException("Customer cannot be empty")
	}
	
	If reservation.startLocation = "" {
		$$$ThrowBadRequestException("Start location cannot be empty")
	}
	
	If reservation.destination = "" {
		$$$ThrowBadRequestException("Destination cannot be empty")
	}
	
	If reservation.startDate = "" {
		$$$ThrowBadRequestException("Start date cannot be empty")
	}
	
	If reservation.endDate = "" {
		$$$ThrowBadRequestException("End date cannot be empty")
	}
	
	// Catch <ILLEGAL VALUE> error returned by $zdateh and throw our own exception. 
	Try 
	{
		Set startDate = $zdateh(reservation.startDate,3)
	} 
	Catch 
	{
		$$$ThrowBadRequestException("Invalid format for start date")
	}
	
	Try {
		Set endDate = $zdateh(reservation.endDate,3)
	} Catch {
		$$$ThrowBadRequestException("Invalid format for end date")
	}
	
	If startDate > endDate {
		$$$ThrowBadRequestException("Start date must be earlier than end date")
	}
}

/// This method encapsulates the work of transforming the incoming JSON object into the object graph inside
/// the database. It is called from ImplCreate(), ImplFullUpdate() and ImplSelectiveUpdate()
/// 
/// If fullUpdate is 1 (true), and properties on the persistent data model are not present in the input,
/// then these properties will be set to "" (to implement PUT's semanthics). 
/// 
/// If fullUpdate is 0 (false), then they will be left alone untouched (to implement PATCH's semanthics)
ClassMethod JSONObjectToDataModel(input As %DynamicObject, ByRef reservation As TravelAgency.Data.Reservation, fullUpdate As %Boolean = 0) [ Private ]
{
	
	If $Get(reservation)=""
	{
		Set reservation = ##class(TravelAgency.Data.Reservation).%New()
	}

	If input.%IsDefined("customer") {
		Set reservation.Customer = $zstrip(input.customer,"<>W")
	}
	ElseIf fullUpdate {
		Set reservation.Customer = ""
	}
	
	If input.%IsDefined("startLocation") {
		Set reservation.StartLocation = $zstrip(input.startLocation,"<>W")
	}
	ElseIf fullUpdate {
		Set reservation.StartLocation = ""
	}
	
	
	If input.%IsDefined("destination") {
		Set reservation.Destination = $zstrip(input.destination,"<>W")
	}
	ElseIf fullUpdate {
		Set reservation.Destination = ""
	}

	
	If input.%IsDefined("startDate") {
		Set reservation.StartDate = $ZDateH(input.startDate,3)
	}
	ElseIf fullUpdate {
		Set reservation.StartDate = ""
	}

	
	If input.%IsDefined("endDate") {
		Set reservation.EndDate = $ZDateH(input.endDate,3)
	}
	ElseIf fullUpdate {
		Set reservation.EndDate = ""
	}
}

/// PUT - Updates all properties on the data model. If the input doesn't have a value for a 
/// property, it will be set with ""
ClassMethod ImplFullUpdate(id As %String, input As %DynamicObject) As %Status
{
	Try 
	{
		Set input = ..GetJSONData()

		Do ..Validate(input)

		Set reservation = ..Open(id)

		Do ..JSONObjectToDataModel(input, reservation, 1)
		
		Set status = reservation.%Save()
		$$$ThrowStatusExceptionIfError(status, "SaveReservationException")
	} 
	Catch ex 
	{
		Do ..ErrorHandling(ex)
	}

	Quit $$$OK
}

/// PATCH - Updates on the data model only what came in into the input leaving other properties untouched
ClassMethod ImplSelectiveUpdate(id As %String) As %Status
{
	Try 
	{
		// Starting a transaction. We may need to rollback updates in case of a validation problem
		TStart 

		Set input = ..GetJSONData()

		Set reservation = ..Open(id)

		// fullUpdate = 0
		Do ..JSONObjectToDataModel(input, reservation, 0)

		// Need to validate the end result of the patch. So let's reconstruct
		// the json object from the model
		Set updatedInput=..DataModelToJSONObject(reservation)

		// Validating
		Do ..Validate(updatedInput)

		// If we are here, it is because it is valid
		Set status = reservation.%Save()
		$$$ThrowStatusExceptionIfError(status, "SaveReservationException")

		// If we are here, everything is fine and we should commit
		TCommit
	} 
	Catch ex 
	{
		//If we are here, we must rollback this transaction
		TRollback 

		Do ..ErrorHandling(ex)
	}

	Quit $$$OK
}

ClassMethod Open(id) As TravelAgency.Data.Reservation
{
	Set reservation = ##class(TravelAgency.Data.Reservation).%OpenId(id)
	If reservation="" $$$ThrowNotFoundException("Reservation not found")

	Quit reservation
}

ClassMethod ImplDelete(id As %String) As %Status
{
	Try 
	{
		If ##class(TravelAgency.Data.Reservation).%ExistsId(id)
		{
			Set status = ##class(TravelAgency.Data.Reservation).%DeleteId(id)
		}
	} 
	Catch ex 
	{
		Do ..ErrorHandling(ex)
	}
	
	Quit $$$OK
}

}
