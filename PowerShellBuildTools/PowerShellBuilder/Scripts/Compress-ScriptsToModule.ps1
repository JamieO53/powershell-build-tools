function Compress-ScriptsToModule {
    param (
        [string]$ProjectName,
        [string]$ProjectFolder,
		[string]$ModuleName,
		[string]$Configuration
    )
    $projFile = "$ProjectFolder\$ProjectName.pssproj"
    $outputPath = "$ProjectFolder\bin\$Configuration"

    if (Test-Path $projFile) {
		[xml]$proj = Get-Content $projFile
		$body = Get-ProjectFunctionText -proj $proj -ModuleName $ModuleName
		$moduleTemplate = "$ProjectFolder\$ModuleName"
		$moduleOutputPath = "$outputPath\$ProjectName"
		$moduleFile = "$moduleOutputPath\$ModuleName"
		
		if (Test-Path $moduleOutputPath) {
			Remove-Item -Path $moduleOutputPath -Recurse -Force
		}
		
		if (-not (Test-Path $moduleOutputPath)) {
			mkdir $moduleOutputPath | Out-Null
		}
		if (Test-Path $moduleTemplate) {
			[string]$moduleBody = Get-Content $moduleTemplate | Out-String
		} else {
			[string]$moduleBody = ''
		}
		if ($moduleBody.Contains('## <Scripts> ##')) {
			$moduleBody.Replace('## <Scripts> ##', $body) | Set-Content $moduleFile -Encoding utf8
		} else {
			"$moduleBody
$body".Trim() | Set-Content $moduleFile -Encoding utf8
		}
    } else {
        throw "Unable to find PowerShell project $ProjectName.pssproj in ProjectFolder"
    }
}