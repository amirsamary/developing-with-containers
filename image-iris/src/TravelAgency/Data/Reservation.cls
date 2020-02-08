Class TravelAgency.Data.Reservation Extends %Persistent
{

Property Customer As %String [ Required ];

Property StartLocation As %String [ Required ];

Property Destination As %String [ Required ];

Property StartDate As %Date [ Required ];

Property EndDate As %Date [ Required ];

Storage Default
{
<Data name="ReservationDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Customer</Value>
</Value>
<Value name="3">
<Value>StartLocation</Value>
</Value>
<Value name="4">
<Value>Destination</Value>
</Value>
<Value name="5">
<Value>StartDate</Value>
</Value>
<Value name="6">
<Value>EndDate</Value>
</Value>
</Data>
<DataLocation>^TravelAgency.Data.ReservationD</DataLocation>
<DefaultData>ReservationDefaultData</DefaultData>
<IdLocation>^TravelAgency.Data.ReservationD</IdLocation>
<IndexLocation>^TravelAgency.Data.ReservationI</IndexLocation>
<StreamLocation>^TravelAgency.Data.ReservationS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
