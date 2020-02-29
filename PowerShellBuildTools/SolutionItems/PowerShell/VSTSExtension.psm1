
function Test-IsRunningBuildAgent {
	return @('Builder', 'VssAdministrator') -contains $env:USERNAME
}


