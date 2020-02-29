function Build-PSProject {
	param (
		# The folder containing the solution and PowerShell project
		[string]$SolutionFolder,
		# The location of the configuration for the the PowerShell project build
		[string]$BuildConfigPath,
		# The build configuration
		[string]$Configuration,
		# The project name
		[string]$ProjectName,
		# The project folder
		[string]$ProjectFolder
	)
	[string]$outputFolder = "$projectFolder\bin\$Configuration\$projectName"
	[bool]$isModule = -not (Test-Path $projectFolder\$projectName.ps1)
	[string]$ModuleName = if ($isModule) { "$projectName.psm1" } else { "$projectName.ps1" }
	[string]$MandateName = "$projectName.psd1"
	Compress-ScriptsToModule -ProjectName $projectName -ProjectFolder $projectFolder -ModuleName $ModuleName -Configuration $Configuration

	if (Test-Path $projectFolder\$projectName.psd1) {
		Copy-Item $projectFolder\$projectName.psd1 $outputFolder
	}

	if ($BuildConfigPath -and (Test-Path $BuildConfigPath)) {
		$cfg = Import-PowerShellDataFile $BuildConfigPath
		$cfgPath = @{}
		$cfg.Dependencies | ForEach-Object {
			$cfgPath.Add($_, "$SolutionDir\$_\bin\$Configuration\$_\*")
		}
		$cfg.Extensions | ForEach-Object {
			$cfgPath.Add($_, "$SolutionDir\NuGetSharedPacker\Extensions\$_\bin\$Configuration\$_\*")
		}

		$cfgPath.Keys | ForEach-Object {
			$name = $_
			$path = $cfgPath[$name]
			if (Test-Path $path) {
				Copy-Item $path "$ProjectDir\bin\$Configuration\$ProjectName"
			}
		}
		$cfg.Dependents | ForEach-Object {
			if (Test-Path "$SolutionDir\$_\bin\$Configuration\$_") {
				Copy-Item "$ProjectDir\bin\$Configuration\$ProjectName\*" "$SolutionDir\$_\bin\$Configuration\$_"
			}
		}
	}
	if ($isModule -and (Test-Path $projectFolder\$MandateName)) {
		Copy-Item $projectFolder\$MandateName $outputFolder
	}
}

