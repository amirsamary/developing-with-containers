Include MyAppMacros

Class TravelAgency.REST.Dispatcher Extends (TravelAgency.REST.Base, %CSP.REST)
{

Parameter CONVERTINPUTSTREAM = 1;

Parameter CHARSET = "utf-8";

Parameter CONTENTTYPE = "application/json";

/// Useful for authentication and holding a single license for every user 
/// when running on a concurrent user licensed IRIS box.
Parameter UseSession As Integer = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <Map Prefix="/reservations" Forward="TravelAgency.REST.Reservations"/>
    <Route Url="/destinations" Method="GET" Call="Destinations"/>
</Routes>
}

ClassMethod Destinations() As %Status
{
    Do ..CacheResponse()

    Set obj = {"destinations": ["London","Madrid","Tokyo"]} 
    Write obj.%ToJSON()
    
    Quit $$$OK
}

}
