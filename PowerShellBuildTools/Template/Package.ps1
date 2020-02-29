param (
	[string]$Configuration='Debug'
)

$toolsFolder = $PSScriptRoot
if (-not $toolsFolder) {
	$toolsFolder = Get-Location
	if (-not (Test-Path $toolsFolder\Package.ps1)) {
		Write-Error "[Package.ps1] Executing script from incorrect location: $toolsFolder"
		Exit 1
	}
}
$solutionFolder = (Get-Item $toolsFolder\..).FullName
$Global:ConfigPath = "$toolsFolder\BuildTools.config"
[xml]$config = Get-Content $Global:ConfigPath
if (Get-Module NugetSharedPacker -All) {
	Remove-Module NugetSharedPacker
}
Import-Module "$solutionFolder\PowerShell\NugetSharedPacker.psd1" -Global -DisableNameChecking

$solutionPath = (Get-ChildItem $solutionFolder\*.sln | Select-Object -First 1).FullName
$nugetFolder = "$solutionFolder\NuGet"
$nuspecPath = "$toolsFolder\Package.nuspec"
$branch = Get-Branch -Path $solutionFolder
if ($branch) {
	$branch = Split-Path ($branch) -Leaf
}
Write-Host "solutionFolder : $solutionFolder"
Write-Host "solutionPath : $solutionPath"
Write-Host "Global:ConfigPath : $Global:ConfigPath"
Write-Host "nugetFolder : $nugetFolder"
Write-Host "nuspecPath : $nuspecPath"
Write-Host "branch : $branch"

if (Test-Path $nugetFolder) {
	Remove-Item $nugetFolder\* -Recurse -Force
}
if (-not (Test-Path $nugetFolder)) {
	mkdir $nugetFolder | Out-Null
}

$targets = @{}
$config.tools.nuget.targetFolders.targetFolder | ForEach-Object {
	$target = $_.name
	[bool]$clear = $_.clear -eq 'true'
	$targetPath = "$nugetFolder\$target"
	Write-Host "targetPath : $targetPath"
	$targets[$target] = $targetPath
	if ($clear -and (Test-Path $targetPath)) {
		Remove-Item $targetPath\* -Recurse -Force
	}
	if (-not (Test-Path $targetPath)) {
		mkdir $targetPath | Out-Null
	}
}

$contentFolders = @{}
$config.tools.nuget.folders.folder | Where-Object -Property fromSolution -EQ 'true' | ForEach-Object {
	$name = $_.name
	$target = $_.target
	Write-Host "contentFolder : $name & target : $target"
	if (-not $targets.ContainsKey($target)) {
		Write-Host "Solution Content $name target folder $target is not specifid in BuildTools.config" -ForegroundColor Red
		exit 1
	}
	$contentFolders[$name] = $target
}

$projectContentFolders = @{}
$config.tools.nuget.folders.folder | Where-Object -Property fromProject -EQ 'true' | ForEach-Object {
	$name = $_.name
	$target = $_.target
	Write-Host "projectContentFolder : $name & target : $target"
	if (-not $targets.ContainsKey($target)) {
		Write-Host "Project Content $name target folder $target is not specifid in BuildTools.config" -ForegroundColor Red
		exit 1
	}
	$projectContentFolders[$name] = $target
}

Get-PowerShellProjects -SolutionPath $solutionPath | ForEach-Object {
	$projectPath = "$solutionFolder\$($_.ProjectPath)"
	$projectFolder = Split-Path $projectPath
	$projectContentFolders.Keys | Sort-Object | ForEach-Object {
		$content = $_
		$target = $projectContentFolders[$content]
		$nugetTargetFolder = "$nugetFolder\$target"
		$templateFolder = "$projectFolder\$content"
		if (Test-Path $templateFolder) {
			Write-Host "projectContentFolder : $templateFolder"
			Copy-Item $templateFolder\* $nugetTargetFolder -Force -Recurse
		}
	}
}

$contentFolders.Keys | Sort-Object | ForEach-Object {
	$content = $_
	$target = $contentFolders[$content]
	$nugetTargetFolder = "$nugetFolder\$target"
	$templateFolder = "$solutionFolder\$content"
	if (Test-Path $templateFolder) {
		Write-Host "contentFolder : $templateFolder"
		Copy-Item $templateFolder\* $nugetTargetFolder -Force -Recurse
	}
}

[xml]$nuspec = Get-Content $nuspecPath
[string]$id = $nuspec.package.metadata.id
[string]$version = $nuspec.package.metadata.version
Write-Host "assemblyVersion : $version"
if ($branch -and $branch -ne 'master') {
	 $version = "$version-$branch"
}
Write-Host "version : $version"

if ((Test-IsRunningBuildAgent) -or -not (Test-NuGetVersionExists -Id $id -Version $version)){
	# takeown /F "$solutionFolder\BuildTools\Package.nuspec"
	Write-Host "NuGet pack `"$toolsFolder\Package.nuspec`" -BasePath `"$nugetFolder`" -OutputDirectory $solutionFolder"
	NuGet pack $nuspecPath -BasePath "$nugetFolder" -OutputDirectory $solutionFolder
}
exit 1