function Set-ModuleManifest {
<#
.SYNOPSIS
Set properties in a module manifest
.DESCRIPTION
Reads the specified manifest, sets the given properties, and rewrites the modified manifest.
It sets the RootModule if not already set, and the corresponding .psm1 file exists.
.EXAMPLE
Set-ModuleManifest -Path .\MyModule.psd1 -Values @{ModuleVersion = '1.0.1';Copyright = "(c) $((Get-Date).Year) Jamie Oglethorpe. All rights reserved."}
#>
    [CmdletBinding()]
    param (
        # The path of the manifest file (*.psd1) being modified
        [string]$Path,
        # The property values being set
        [Hashtable]$Values
    )
    if ([IO.Path]::GetExtension($Path) -eq '.psd1') {
        if (Test-Path $Path) {
            $psd = Import-PowerShellDataFile -Path $Path
            if (-not $psd.ContainsKey('RootModule')) {
                $modulePath = [IO.Path]::ChangeExtension($Path, '.psm1')
                if (Test-Path $modulePath) {
                    $moduleName = Split-Path $modulePath -Leaf
                    $psd.RootModule = $moduleName
                }
            }
	        $psdSave = "New-ModuleManifest -Path $Path"
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

        } else {
            throw "Module manifest not found: $Path"
        }
    } else {
        throw "Invalid extension for a module manifest: $Path"
    }
}