Include MyAppMacros

Class IRISDemo.REST.Dispatcher Extends %CSP.REST
{

Parameter CONVERTINPUTSTREAM = 1;

Parameter CHARSET = "utf-8";

XData UrlMap
{
<Routes> 
    <Map Prefix="/predict" Forward="ML.Model.BS.ExecutorService.Service"/>
</Routes>
}

}
