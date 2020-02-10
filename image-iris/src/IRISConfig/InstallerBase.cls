Class IRISConfig.InstallerBase [ Abstract ]
{

/// This method must always be here
ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 0, pInstaller As %Installer.Installer) As %Status [ CodeMode = objectgenerator, Internal ]
{
	     Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "Install")
}

ClassMethod AuthForSMP() As %Integer
{
		Quit $$$AutheNormal
}

ClassMethod AuthAllowed()
{
 
		Quit $$$AutheUnauthenticated+$$$AutheCache+$$$AutheDelegated
}

ClassMethod AuthForCSP()
{
		Quit $$$AutheCache+$$$AutheDelegated
}

ClassMethod AuthForInt()
{
		Quit $$$AutheUnauthenticated
}

ClassMethod AuthForREST()
{
		Quit $$$AutheLoginToken+$$$AutheCache
}

ClassMethod AuthForSOAP()
{
		Quit $$$AutheLoginToken+$$$AutheCache
		
		// You can override this method on your subclass and use unauthenticated if you are using another method to protect your SOAP
		// service such as a Config class to define orthogonal security
		//Quit $$$AutheUnauthenticated
}

/// This method is called by a RUN instruction inside your Dockerfile. It will
/// use environment variables defined on your Dockerfile to further parameterize
/// this setup.
ClassMethod Install()
{
		Set tSC = $$$OK
		Try
		{
			Set pVars("InstallDir")=$System.Util.GetEnviron("ISC_PACKAGE_INSTALLDIR")
			
			Set tSourceDir=$System.Util.GetEnviron("IRIS_APP_SOURCEDIR")
			If tSourceDir'="" Set pVars("SourceDir")=tSourceDir
			
			Set pVars("Namespace")=$System.Util.GetEnviron("IRIS_APP_NAME")
			If pVars("Namespace")="" 
			{
				Set tSC = $System.Status.Error(5001,"You need to specify IRIS_APP_NAME environment variable on your Dockerfile.")
				Quit
			}
			
			Set pVars("CSPAppName")=$ZConvert(pVars("Namespace"),"L")

			Set pVars("ConfigureAutoStartProduction")=$System.Util.GetEnviron("IRIS_PRODUCTION_AUTOSTART")
			
			Set tSC = ..setup(.pVars, 2)
		}
		Catch (oException)
		{
			Set tSC = oException.AsStatus()
		}
		
		/// This terminates this process with a exit value for the operating system so that
		/// Docker can know if everything worked fine or not.
		If $System.Status.IsError(tSC) 
		{ 
			Do $System.Status.DisplayError(tSC) // Show error message before exiting 
			Do $zu(4,$j,1)  // exit status 1
		} 
		Else 
		{ 
			Do $zu(4,$j,0) // exit status 0
		}
}

ClassMethod ConfigureAutoStart(pNamespace As %String, pClassName As %String) As %Status
{
		Set tSC = $$$OK
		Try
		{
			Quit:pClassName="" 
				
			ZN pNamespace
			
			Set tSC = $classmethod("Ens.Director", "SetAutoStart", pClassName, 0)
		}
		Catch (oException)
		{
			Set tSC = oException.AsStatus()
		}
		
		ZN "%SYS"
		
		Quit tSC
}

ClassMethod CSPAppConfigureAsREST(pCSPAppName, pDispatcherClassName As %String) As %Status
{
		Set tSC = $System.Status.OK()
		Try
		{
			Set oCSPApp = ##class(Security.Applications).%OpenId(pCSPAppName, , .tSC)
	
			Set oCSPApp.DispatchClass=pDispatcherClassName
			Set oCSPApp.UseCookies=1
			Set tSC = oCSPApp.%Save()
			Quit:$System.Status.IsError(tSC)
		}
		Catch (oException)
		{
			Set tSC = oException.AsStatus()
		}
	
		Quit tSC
}

ClassMethod DisableJournalSystemWide() As %Status
{
		Set tSC = $System.Status.OK()
		
		Try
		{
			Set tNS=$Namespace
			Set $Namespace="%SYS"
			
			Set err=0
			
			Do INT^JRNSTOP(.err,0)
			
			If err'=0 
			{
				Set tSC = $System.Status.Error(5001,"Error when trying to disable journal system wide. INT^JRNSTOP returned err: "_err)
			}
		}
		Catch (oException)
		{
			Set tSC = oException.AsStatus()
		}
		
		Set $Namespace=tNS
		
		Quit tSC
}

ClassMethod AddRoleToUser(pUserName As %String, pRole As %String) As %Status
{
		Quit ##class(Security.Users).AddRoles(pUserName, pRole)
}

ClassMethod CSPAppEnableAnalytics(pCSPAppName) As %Status
{
		Set tSC = $System.Status.OK()
		Try
		{
			Set pCSPAppName=pCSPAppName_"/"
			Do EnableDeepSee^%SYS.cspServer(pCSPAppName)
			Do EnableIKnow^%SYS.cspServer(pCSPAppName)
		}
		Catch (oException)
		{
			Set tSC = oException.AsStatus()
		}
	
		Quit tSC
}

XData Install [ XMLNamespace = INSTALLER ]
{
<Manifest>

</Manifest>
}

}
