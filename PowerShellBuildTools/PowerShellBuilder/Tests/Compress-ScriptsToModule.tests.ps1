if (Test-Path function:\Compress-ScriptsToModule) {
	Remove-Item function:\Compress-ScriptsToModule
}
if (Test-Path function:\Get-ProjectFunctionText) {
	Remove-Item function:\Get-ProjectFunctionText
}
if (Test-Path function:\Get-ProjectFunctionIncludes) {
	Remove-Item function:\Get-ProjectFunctionIncludes
}
. $PSScriptRoot\..\Scripts\Get-ProjectFunctionIncludes
. $PSScriptRoot\..\Scripts\Get-ProjectFunctionText
. $PSScriptRoot\..\Scripts\Compress-ScriptsToModule

$projectName = 'PowerShellBuilder'
$testScript = @'
param(
	[string]$Project,
	[string]$Path,
	[string]$OutputPath,
	[string]$Configuration = 'Debug'
)

## <Scripts> ##

Compress-ScriptsToModule -ProjectName $project -ProjectFolder $path -ModuleName "$project.psm1" -Configuration $Configuration
'@
Describe "Compress-ScriptsToModule" {
	Context "Exists" {
		It "Runable" {
			Test-Path function:\Compress-ScriptsToModule | Should -BeTrue
		}
	}
	Context "Build module" {
		$projectFolder = "$testDrive\Solution\$projectName"
		mkdir $projectFolder\Scripts
		Copy-Item $PSScriptRoot\..\$projectName.pssproj,$PSScriptRoot\..\$projectName.ps*1 $projectFolder -Force
		Copy-Item $PSScriptRoot\..\Scripts\* $projectFolder\Scripts -Recurse -Force
		$moduleName = "$projectName.psm1"

		Compress-ScriptsToModule -ProjectName $projectName -ProjectFolder $projectFolder -ModuleName $moduleName -Configuration Debug
		It "$moduleName exists" {
			Test-Path $projectFolder\bin\Debug\$projectName\$moduleName | Should -BeTrue
		}
		if (Test-Path $projectFolder\bin\Debug\$projectName\$moduleName) {
			$actualModuleText = Get-Content $projectFolder\bin\Debug\$projectName\$moduleName | Out-String
			$expectedModuleText = Get-Content $projectFolder\$projectName.psm1
			Get-ChildItem $projectFolder\Scripts\*.ps1 | ForEach-Object {
				$text = (Get-Content $_.FullName | Out-String).Trim()
				$expectedModuleText += "

$text"
			}
			It "Module text" {
				$actualModuleText.Trim() | Should -Be $expectedModuleText.Trim()
			}
		}
	}
	Context "Build script" {
		$scriptName = 'PSModuleBuilder.ps1'
		$projectFolder = "$testDrive\Solution\$projectName"
		mkdir $projectFolder\Scripts
		Copy-Item $PSScriptRoot\..\$projectName.pssproj,$PSScriptRoot\..\$projectName.ps*1 $projectFolder -Force
		Copy-Item $PSScriptRoot\..\Scripts\* $projectFolder\Scripts -Recurse -Force
		$testScript | Set-Content -Path "$projectFolder\$scriptName" -Encoding UTF8
		$moduleName = $scriptName

		Compress-ScriptsToModule -ProjectName $projectName -ProjectFolder $projectFolder -ModuleName $moduleName -Configuration Debug
		It "$moduleName exists" {
			Test-Path $projectFolder\bin\Debug\$projectName\$moduleName | Should -BeTrue
		}
		if (Test-Path $projectFolder\bin\Debug\$projectName\$moduleName) {
			$actualScriptText = Get-Content $projectFolder\bin\Debug\$projectName\$moduleName | Out-String
			$body = ''
			Get-ChildItem $projectFolder\Scripts\*.ps1 | ForEach-Object {
				$text = (Get-Content $_.FullName | Out-String).Trim()
				$body += "

$text"
			}
			$body = $body.Trim()
			$expectedScriptText = @"
param(
	[string]`$Project,
	[string]`$Path,
	[string]`$OutputPath,
	[string]`$Configuration = 'Debug'
)

$body

Compress-ScriptsToModule -ProjectName `$project -ProjectFolder `$path -ModuleName `"`$project.psm1`" -Configuration `$Configuration
"@
			It "Script text" {
				$actualScriptText.Trim() | Should -Be $expectedScriptText.Trim()
			}
		}
	}
}