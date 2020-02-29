param (
	[string]$Configuration='Debug',
	[string]$SolutionFolder=''
)

$buildFolder = $PSScriptRoot
if (-not $SolutionFolder -or -not (Test-Path $SolutionFolder)) {
    $SolutionFolder = Split-Path $buildFolder
}
[string]$solutionPath = Get-ChildItem $SolutionFolder\*.sln |
    Select-Object -First 1 |
    ForEach-Object { $_.FullName }
if (-not (Test-Path $solutionPath)) {
    Write-Error "[BuildAll] Unable to locate solution in $SolutionFolder"
    exit 1
}
$powerShellFolder = "$SolutionFolder\PowerShell"
$nuGetSharedPackerPath = "$powerShellFolder\NuGetSharedPacker.psd1"
$Global:ConfigPath = "$buildFolder\BuildTools.config"
if (-not (Get-Module NuGetSharedPacker)) {
    if (-not (Test-Path $nuGetSharedPackerPath)) {
        Write-Error "[BuildAll] Unable to locate NuGetSharedPacker module"
        exit 1
    }
    Import-Module $nuGetSharedPackerPath
}
Get-PowerShellProjects -SolutionPath $solutionPath | ForEach-Object {
    $projectName = $_.Project
    $projectPath = "$SolutionFolder\$($_.ProjectPath)"
    $projectFolder = Split-Path $projectPath
    $buildCommand = "$projectFolder\Build.ps1"
    if (-not (Test-Path $buildCommand)) {
        $buildCommand = "$buildFolder\Build.ps1"
    }
    & $buildCommand `
        -Configuration $Configuration `
        -SolutionFolder $SolutionFolder `
        -ProjectName $projectName `
        -ProjectFolder $projectFolder
}