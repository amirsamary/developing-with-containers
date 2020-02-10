Class TravelAgency.Exception.BadRequest Extends TravelAgency.Exception.Base
{

Parameter HTTPStatus As %String = {##class(%CSP.REST).#HTTP400BADREQUEST};

Parameter LogError As %Boolean = 1;

}
