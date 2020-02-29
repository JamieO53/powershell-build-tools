if (Test-Path function:\Build-PowerShellProject) {
	Remove-Item function:\Build-PowerShellProject
}
. $PSScriptRoot\..\Scripts\Build-PowerShellProject

Describe "Build-PowerShellProject" {
	Context "Exists" {
		It "Runable" {
			Test-Path function:\Build-PowerShellProject | Should -BeTrue
		}
	}
}