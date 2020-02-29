function Publish-LocalModule {
	param (
		[string]$ProjectName,
		[string]$ProjectFolder,
		[string]$OutputFolder,
		[string]$ModuleVersion,
		[string]$ModuleLibraryName
	)
	Copy-Item -Path $ProjectFolder\$ProjectName.psd1 $OutputFolder
	if (Test-Path $OutputFolder\$ProjectName.psd1)
	{
		$psd = Import-PowerShellDataFile -Path $OutputFolder\$ProjectName.psd1
	} else {
		$psd = @{}
	}
	$psd.ModuleVersion = $ModuleVersion
	$psd.RootModule = "$ProjectName.psm1"
	$psdSave = "New-ModuleManifest -Path $OutputFolder\$ProjectName\$ProjectName.psd1"
	$psd.Keys | Sort-Object | ForEach-Object {
		$name = $_
		$value = $psd[$name]
		if ($value -and $value.Count -gt 0) {
			$val = ''
			$value | ForEach-Object {
				$val += "'$_',"
			}
			$val = $val.TrimEnd(',')
			if ($value.Count -gt 1) {
				$val = "@($val)"
			}
			$psdSave += " -$name $val"
		}
	}
	Invoke-Expression $psdSave
	'PowerShell','WindowsPowerShell' | ForEach-Object {
		$instance = $_
		$moduleFolder = "$HOME\Documents\$instance\Modules"
		if ($ModuleLibraryName) {
			$moduleFolder += "\$ModuleLibraryName"
			if ((Test-Path $moduleFolder) -and -not (Test-Path $moduleFolder\$moduleVersion)) {
				Remove-Item $moduleFolder\* -Recurse -Force
			} elseif (Test-Path $moduleFolder\$moduleVersion\$ProjectName) {
				Remove-Item $moduleFolder\$moduleVersion\$ProjectName\* -Recurse -Force
			}
			$moduleFolder += "\$ModuleVersion\$ProjectName"
		} else {
			$moduleFolder += "\$ProjectName"
			if ((Test-Path $moduleFolder) -and -not (Test-Path $moduleFolder\$moduleVersion)) {
				Remove-Item $moduleFolder\* -Recurse -Force
				$moduleFolder += "\$ModuleVersion"
			}
		}
		if (Test-Path $moduleFolder) {
			Remove-Item $moduleFolder\* -Recurse -Force
		} else {
			mkdir $moduleFolder | Out-Null
		}
		Copy-Item $OutputFolder\$ProjectName\* $moduleFolder -Recurse -Force
	}
}