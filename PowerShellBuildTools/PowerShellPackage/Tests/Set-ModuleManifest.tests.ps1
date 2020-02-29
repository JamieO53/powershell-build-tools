$moduleName = "PowerShellTestUtilities"
if (Get-Module $moduleName) {
	Remove-Module $moduleName
}
$moduleFileName = "$moduleName.psm1"
$modulePath = (Get-Item "$PSScriptRoot\..\..\BuildTools\$moduleFileName").FullName
Import-Module $modulePath

$dummyModule = Install-TestedScripts -ProjectFolder "$PSScriptRoot\.."

$scriptFileName = "$moduleName.ps1"
Describe "Set-ModuleManifest" {
	Context "Exists" {
		It "Runable" {
			Test-Path function:\Set-ModuleManifest
		}
	}
}
#Remove-Module $dummyModule