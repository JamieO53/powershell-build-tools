if (Test-Path function:\Clear-LocalModule) {
	Remove-Item function:\Clear-LocalModule
}
. $PSScriptRoot\..\Scripts\Clear-LocalModule

Describe "Clear-LocalModule" {
	Context "Exists" {
		It "Runable" {
			Test-Path function:\Clear-LocalModule | Should -BeTrue
		}
	}
	Context "Clear-OldModuleWithModuleLibrary" {
		$powerShellFolder = Split-Path $profile
		$instance = Split-Path $powerShellFolder -Leaf
		$moduleLibraryFolder = "$powerShellFolder\Modules\TestLibrary"
		if (Test-Path $moduleLibraryFolder) {
			Remove-Item $moduleLibraryFolder -Recurse -Force
		}
		$oldModuleFolder = "$moduleLibraryFolder\1.2.2\TestModule"
		mkdir $oldModuleFolder
		'' | Set-Content $oldModuleFolder\TestModule.psm1
		New-ModuleManifest -Path $oldModuleFolder\TestModule.psd1 -FunctionsToExport '*' -ModuleVersion '1.2.2' -RootModule TestModule.psm1
		It "Old module is available" {
			(Get-Module TestModule -ListAvailable).Version | Should -Be '1.2.2'
		}
		Clear-LocalModule -Instance $instance -ModuleLibraryName TestLibrary -ProjectName TestModule -ModuleVersion '1.2.3'
		It "Old module is no longer available" {
			Get-Module TestModule -ListAvailable | Should -BeNullOrEmpty
		}
	}
}