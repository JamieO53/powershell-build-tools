param (
	[string]$Configuration='Debug'
)

function BuildProject {
    param (
        [string]$Configuration,
        [string]$SolutionFolder,
        [string]$ProjectName
    )
    $prjFolder = "$SolutionFolder\$ProjectName"
    Push-Location $prjFolder
    & $SolutionFolder\BuildTools\Build.ps1 -Configuration $Configuration -SolutionFolder $SolutionFolder -ProjectFolder $prjFolder -ProjectName $ProjectName
    Pop-Location
}
$slnFolder = Split-Path $PSScriptRoot
$toolsFolder = "$slnFolder\BuildTools"
if (Test-Path $toolsFolder) {
    Remove-Item $toolsFolder\* -Recurse -Force
} else {
    mkdir $toolsFolder | Out-Null
}
& .\PowerShellBuilder\Build.ps1 -Configuration $Configuration 
BuildProject -Configuration $Configuration -SolutionFolder $slnFolder -ProjectName PowerShellPackage
BuildProject -Configuration $Configuration -SolutionFolder $slnFolder -ProjectName PowerShellScriptAnalyzer
BuildProject -Configuration $Configuration -SolutionFolder $slnFolder -ProjectName PowershellTestUtilities
