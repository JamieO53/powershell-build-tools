function Import-NuGetSharedPackerModule {
	param (
		[string]$SolutionFolder
	)
	[xml]$config = Get-Content $Global:ConfigPath
	if (Test-IsRunningBuildAgent) {
		$nugetSource = "$env:USERPROFILE\.nuget\packages"
	} else {
		$nugetSource = $config.tools.nuget.source
	}
	$config.tools.packages.package | ForEach-Object {
		$package = $_.name
		$version = $_.version
		$subFolder = $_.subFolder
		$importModule = $_.importModule
		try {
			$BootstrapFolder = "$SolutionFolder\Bootstrap"
			if (Test-Path $BootstrapFolder) {
				Remove-Item $BootstrapFolder\* -Recurse -Force
			} else {
				mkdir $BootstrapFolder | Out-Null
			}

			if ($version) {
				nuget install $package -Source $nugetSource -OutputDirectory $BootstrapFolder -ExcludeVersion -Version $version
			} else {
				nuget install $package -Source $nugetSource -OutputDirectory $BootstrapFolder -ExcludeVersion
			}

			Get-ChildItem $BootstrapFolder -Directory | ForEach-Object {
				Get-ChildItem $_.FullName -Directory | ForEach-Object {
					if (-not (Test-Path "$SolutionFolder\$($_.Name)")) {
						mkdir "$SolutionFolder\$($_.Name)" | Out-Null
					}
					Copy-Item "$($_.FullName)\*" "$SolutionFolder\$($_.Name)" -Recurse -Force
				}
			}
			if (Get-Module $package -All) {
				Remove-Module $package
			}
			if (Test-Path "$SolutionFolder\$subFolder\$importModule.psd1") {
				Import-Module "$SolutionFolder\$subFolder\$importModule.psd1" -Global -DisableNameChecking
			}
		} catch {
			Write-Error $_
			Exit 0
		} finally {
			Remove-Item $BootstrapFolder -Include '*' -Recurse
		}
	}
}

function Test-IsRunningBuildAgent {
	if ($env:USERNAME -eq 'Builder') {
		$true
	} elseif ($env:USERNAME -eq 'VssAdministrator') {
		$true
	} else {
		$buildAgent = (
			get-service | Where-Object {
				($_.Status -eq 'Running') -and ($_.Name -like 'vstsagent.*')
			} | ForEach-Object {
				$_.Name
			}
		)
		-not ([string]::IsNullOrEmpty($buildAgent))
	}
}

$solutionFolder = (Get-Item "$PSScriptRoot\..").FullName
$Global:ConfigPath = "$PSScriptRoot\BuildTools.config"
Import-NuGetSharedPackerModule -SolutionFolder $solutionFolder
