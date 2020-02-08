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
			// This is not required any longer. 
			// Set oCSPApp = ##class(Security.Applications).%OpenId(pCSPAppName, , .tSC)
	
			// Set oCSPApp.DeepSeeEnabled=1
			// Set oCSPApp.iKnowEnabled=1
			// Set tSC = oCSPApp.%Save()
			// Quit:$System.Status.IsError(tSC)

			// This will do all the work for us.
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

ClassMethod AddWFRole(pNamespace As %String, pRoleName As %String) As %Status
{
		Set tSC = $System.Status.OK()
		Try
		{
			Set tNS = $Namespace
			Set $Namespace = pNamespace
			
			Set tSC = ##class(EnsLib.Workflow.RoleDefinition).CreateRole(pRoleName)
		}
		Catch (oException)
		{
			Set tSC = oException.AsStatus()
		}
		
		ZN tNS
		
		Quit tSC
}

ClassMethod AddWFUser(pNamespace As %String, pUserName As %String, pFullName As %String, pRoleName As %String) As %Status
{
		Set tSC = $System.Status.OK()
		Try
		{
			Set tNS = $Namespace
			Set $Namespace = pNamespace
			
			Set tSC = ##class(EnsLib.Workflow.UserDefinition).CreateUser(pUserName,pFullName)
			Quit:$System.Status.IsError(tSC)
			
			Set tSC = ##class(EnsLib.Workflow.RoleDefinition).AddUserToRole(pRoleName,pUserName,1,"")
		}
		Catch (oException)
		{
			Set tSC = oException.AsStatus()
		}
		
		ZN tNS
		
		Quit tSC
}

ClassMethod AddUserToWFRole(pNamespace As %String, pUserName As %String, pRoleName As %String) As %Status
{
		Set tSC = $System.Status.OK()
		Try
		{
			Set tNS = $Namespace
			Set $Namespace = pNamespace
			
			Set tSC = ##class(EnsLib.Workflow.RoleDefinition).AddUserToRole(pRoleName,pUserName,0,"")
		}
		Catch (oException)
		{
			Set tSC = oException.AsStatus()
		}
		
		ZN tNS
		
		Quit tSC
}

ClassMethod FixPMML() As %Status
{
		Set tSC = $System.Status.OK()
		Try
		{
			Set tNS=$Namespace
			ZN "%SYS"
			
			Set oDBSYS = ##class(SYS.Database).%OpenId("/usr/irissys/mgr/irislib")
			Set oDBSYS.ReadOnly=0

			Set tSC = oDBSYS.%Save()
			Quit:$System.Status.IsError(tSC)
						
			Set tSC = $System.OBJ.Load("/tmp/PMML.xml", "cku")
			Quit:$System.Status.IsError(tSC)

		}
		Catch (oException)
		{
			Set tSC = oException.AsStatus()
		}
		
		If $IsObject(oDBSYS)
		{
			Set oDBSYS.ReadOnly=1
	
			Do oDBSYS.%Save()
		}
		
		ZN tNS
		
		Quit tSC
}

XData Install [ XMLNamespace = INSTALLER ]
{
<Manifest>

	</Manifest>
}

}
