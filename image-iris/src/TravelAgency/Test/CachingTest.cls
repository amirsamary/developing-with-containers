Class TravelAgency.Test.CachingTest Extends %CSP.Page
{

ClassMethod OnPage() As %Status
{
    &Html<
    <h1>Hi!</h1>


    <script language="javascript">
        
        setTimeout(() => {
            
        },1000);

    </script>
    >

    Quit $$$OK
}

}
