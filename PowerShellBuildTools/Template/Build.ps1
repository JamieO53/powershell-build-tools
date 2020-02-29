param (
	[string]$Configuration='Debug',
	[string]$SolutionFolder='',
	[string]$ProjectFolder='',
	[string]$ProjectName=''
)

$ProjectFolder = if ($ProjectFolder) { $ProjectFolder.TrimEnd('\') } else { Get-Location }
$SolutionFolder = if ($SolutionFolder) { $SolutionFolder.TrimEnd('\') } else { Split-Path $ProjectFolder }
$ProjectName = if ($ProjectName) { $ProjectName } else { Split-Path $ProjectFolder -Leaf }
$buildFolder = "$solutionFolder\BuildTools"

#Write-Host " ProjectName: $ProjectName"

if (-not (Get-Module PowerShellBuilder)) {
	Import-Module $buildFolder\PowerShellBuilder -Global -DisableNameChecking
}

#Write-Host " ProjectName: $ProjectName"
#Write-Host " ProjectFolder: $ProjectFolder"
Build-PowerShellProject `
	 -Configuration $Configuration `
	 -SolutionFolder $solutionFolder `
	 -ProjectName $ProjectName `
	 -ProjectFolder $ProjectFolder