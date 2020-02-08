ROUTINE MyAppMacros [Type=INC]

#define ThrowStatusExceptionIfError(%Status, %Name)	Do ##class(TravelAgency.Exception.Support).ThrowStatusExceptionIfError(%Status, %Name)

#define ThrowSQLExceptionIfError(%Name)	If SQLCODE<0 Do ##class(TravelAgency.Exception.Support).ThrowSQLExceptionIfError(SQLCODE, %msg, %Name)

#define ThrowSQLExceptionIfResultError(%oSQLResultStatement, %Name)	If %oSQLResultStatement.%SQLCODE<0 Do ##class(TravelAgency.Exception.Support).ThrowSQLExceptionIfError(%oSQLResultStatement.%SQLCODE, %oSQLResultStatement.%Message, %Name)

#define ThrowException(%Name,%Details) Set e = ##class(%Exception.General).%New(%Name, %Name,,%Details) Throw e

#define ExceptionAsJSON(%exception) ##class(TravelAgency.Exception.Support).ExceptionAsJSON(%exception)

#define ThrowBadRequestException(%message) Throw ##class(TravelAgency.Exception.BadRequest).%New(%message)

#define ThrowNotFoundException(%message) Throw ##class(TravelAgency.Exception.NotFound).%New(%message)