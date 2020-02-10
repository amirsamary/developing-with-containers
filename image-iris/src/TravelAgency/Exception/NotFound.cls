Class TravelAgency.Exception.NotFound Extends TravelAgency.Exception.Base
{

Parameter HTTPStatus As %String = {##class(%CSP.REST).#HTTP404NOTFOUND};

Parameter LogError As %Boolean = 0;

}
