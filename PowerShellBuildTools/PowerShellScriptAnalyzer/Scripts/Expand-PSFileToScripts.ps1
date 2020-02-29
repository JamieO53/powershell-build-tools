function Expand-PSFileToScripts {
	param (
		[string]$Path,
		[string]$OutputDir,
		[string]$ModuleName
	)
	$moduleDir = "$OutputDir\$ModuleName"
	$scriptDir = "$moduleDir\Scripts"
	$myPath = (Get-Item $Path).FullName
	$moduleExtension = [io.path]::GetExtension($myPath)

	if (-not (Test-Path $scriptDir)) {
		mkdir -Path $scriptDir | Out-Null
	}

	$functions = [Executables]::new($myPath)
	$scriptName = $functions.ScriptName
	$functions.ex.Values |
		Where-Object { @('FunctionDefinitionAst', 'TypeDefinitionAst') -contains $_.TypeName } |
		ForEach-Object {
			$outputPath = "$scriptDir\$($_.Name).ps1"
			$_.Ast.Extent.Text | Out-File $outputPath -Encoding utf8
		}

	$fnMinOffset=0
	$fnMaxOffset=0

	$functions.ex.Values |
		Where-Object { @('FunctionDefinitionAst', 'TypeDefinitionAst') -contains $_.TypeName } |
		ForEach-Object { $_.Ast.Extent } |
		Measure-Object -Property 'StartOffset','EndOffset' -min -max |
		ForEach-Object {
			if ( $_.Property -eq 'StartOffset' ) {
				$fnMinOffset = $_.Minimum
			}
			elseif ( $_.Property -eq 'EndOffset' ) {
				$fnMaxOffset = $_.Maximum
			}
		}

	$script = $functions.GetExecutable($scriptName).Ast.Extent.Text

	if ($moduleExtension -eq '.ps1'){
		$script.Substring(0,$fnMinOffset) + '## <Scripts> ##' + $script.Substring($fnMaxOffset) |
			Out-File "$moduleDir\$scriptName" -Encoding utf8
	}
}