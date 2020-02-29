param (
	[string]$Configuration='Debug'
)

$ProjectName = 'PowerShellBuilder'
$ProjectFolder = $PSScriptRoot
$solutionFolder = (Get-Item $projectFolder\..).FullName
$toolsFolder = "$solutionFolder\BuildTools"
$templateFolder = "$solutionFolder\Template"
. $ProjectFolder\Scripts\Get-ProjectFunctionIncludes.ps1
. $ProjectFolder\Scripts\Get-ProjectFunctionText.ps1
. $ProjectFolder\Scripts\Compress-ScriptsToModule.ps1
. $ProjectFolder\Scripts\Publish-LocalModule.ps1
$outputFolder = "$ProjectFolder\bin\$Configuration"

try {
	Compress-ScriptsToModule -ProjectName $ProjectName -ProjectFolder $ProjectFolder -ModuleName "$ProjectName.psm1" -Configuration $Configuration
	Copy-Item $ProjectFolder\$ProjectName.psd1 $outputFolder\$projectName
	if (Test-Path $toolsFolder) {
		Remove-Item $toolsFolder\$projectName.* -Recurse -Force 
	} else {
		mkdir $toolsFolder | Out-Null
	}
	Copy-Item $outputFolder\$projectName\* $toolsFolder -Recurse -Force
	Copy-Item $templateFolder\* $toolsFolder -Recurse -Force
} catch {
	throw $_.Exception
} finally {
	Remove-Item function:\Publish-LocalModule
	Remove-Item function:\Compress-ScriptsToModule
	Remove-Item function:\Get-ProjectFunctionText
	Remove-Item function:\Get-ProjectFunctionIncludes
}
