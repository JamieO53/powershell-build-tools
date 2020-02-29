function Clear-LocalModule {
    param (
        [string]$Instance,
        [string]$ModuleLibraryName,
        [string]$ProjectName,
        [string]$ModuleVersion
    )
    $moduleFolder = "$HOME\Documents\$instance\Modules"
    if ($ModuleLibraryName) {
        $moduleFolder += "\$ModuleLibraryName"
        if ((Test-Path $moduleFolder) -and -not (Test-Path $moduleFolder\$moduleVersion)) {
            Remove-Item $moduleFolder\* -Recurse -Force
            $moduleFolder += "\$ModuleVersion\$ProjectName"
        }
    }
    if (Test-Path $moduleFolder) {
        Remove-Item $moduleFolder\* -Recurse -Force
    }
}