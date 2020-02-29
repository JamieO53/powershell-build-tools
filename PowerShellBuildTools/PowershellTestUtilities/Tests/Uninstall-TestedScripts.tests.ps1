$moduleName = "PowershellTestUtilities"
if (Get-Module $moduleName -All) {
	Get-Module $moduleName -All
	Remove-Module $moduleName -ErrorAction Continue
}
$moduleFileName = "$moduleName.psm1"
$modulePath = (Get-Item "$PSScriptRoot\..\..\BuildTools\$moduleFileName").FullName
Import-Module $modulePath

Describe "Uninstall-TestedScripts" {
	Context "Exists" {
		It "Runnable" {
			Test-Path Function:\Expand-PSFileToScripts | Should -BeTrue
		}
	}
}