param (
	[string]$Configuration='Debug'
)

$toolsFolder = $PSScriptRoot
$solutionFolder = (Get-Item $toolsFolder\..).FullName
$solutionPath = (Get-ChildItem $solutionFolder\*.sln | Select-Object -First 1).FullName
$Global:ConfigPath = "$toolsFolder\BuildTools.config"
$templateFolder = "$solutionFolder\Template"
$nugetFolder = "$solutionFolder\NuGet"
$nugetToolsFolder = "$nugetFolder\BuildTools"
if (Get-Module NugetShared -All) {
	Remove-Module NugetShared
}
Import-Module "$solutionFolder\PowerShell\NugetShared.psd1" -Global -DisableNameChecking

#Write-Host "toolsFolder : $toolsFolder"
#Write-Host "solutionFolder : $solutionFolder"
#Write-Host "solutionPath : $solutionPath"
#Write-Host "ConfigPath : $Global:ConfigPath"
#Write-Host "templateFolder : $templateFolder"
#Write-Host "nugetFolder : $nugetFolder"
#Write-Host "nugetToolsFolder : $nugetToolsFolder"

if (Test-Path $nugetFolder) {
	Remove-Item $nugetFolder\* -Recurse -Force
}
if (-not (Test-Path $nugetToolsFolder)) {
	mkdir $nugetToolsFolder | Out-Null
}

Get-PowerShellProjects -SolutionPath $solutionPath | ForEach-Object {
	$project = $_.Project
	$projectPath = "$solutionFolder\$($_.ProjectPath)"
	$projectFolder = Split-Path $projectPath
	$outputFolder = "$projectFolder\bin\$Configuration\$project"
	Copy-Item $outputFolder\* $nugetToolsFolder -Force -Recurse
}
Copy-Item $templateFolder\* $nugetToolsFolder -Force -Recurse

[xml]$nuspec = Get-Content $toolsFolder\Package.nuspec
[string]$id = $nuspec.package.metadata.id
[string]$version = $nuspec.package.metadata.version

if (-not (Test-NuGetVersionExists -Id $id -Version $version)){
	# takeown /F "$solutionFolder\BuildTools\Package.nuspec"
	Write-Host "NuGet pack `"$toolsFolder\Package.nuspec`" -BasePath `"$nugetFolder`" -OutputDirectory $solutionFolder"
	NuGet pack "$toolsFolder\Package.nuspec" -BasePath "$nugetFolder" -OutputDirectory $solutionFolder
}
