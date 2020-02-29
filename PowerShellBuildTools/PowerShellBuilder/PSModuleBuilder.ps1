param(
	[string]$project,
	[string]$path,
	[string]$Configuration='Debug'
)
param(
	[string]$Project,
	[string]$Path,
	[string]$OutputPath,
	[string]$Configuration = 'Debug'
)

if (-not (Get-Module PowerShellBuilder)) {
	Import-Module "$PSScriptRoot\PowerShellBuilder.psd1"
}

Compress-ScriptsToModule -ProjectName $project -ProjectFolder $path -ModuleName "$project.psm1" -Configuration $Configuration
