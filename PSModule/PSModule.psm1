[CmdletBinding()]
param (
  [Parameter()]
  $Root = (Get-Item -Path $PSScriptRoot -Force),

  [Parameter()]
  [string]$ModuleName = $Root.Name
)

Write-Output "RUNNING"

# Setup
$ManifestPath = Join-Path $Root "$ModuleName.psd1"
$PublicPath = Join-Path $Root "public"
$PrivatePath = Join-Path $Root "private"
$ClassesPath = Join-Path $Root "classes"
$Manifest = Test-ModuleManifest $ManifestPath -ErrorAction Stop

# Get Everything for import/export
$aliases = @()
$public  = Get-ChildItem -Path $PublicPath  -Recurse -Force | Where-Object {$_.Extension -eq ".ps1"}
$private = Get-ChildItem -Path $PrivatePath -Recurse -Force | Where-Object {$_.Extension -eq ".ps1"}
$classes = Get-ChildItem -Path $ClassesPath -Recurse -Force | Where-Object {$_.Extension -eq ".ps1"}

# Dot source into session
$public | ForEach-Object { . $_.FullName }
$private | ForEach-Object { . $_.FullName }
$classes | ForEach-Object { . $_.FullName }

# Export 'public' functions (w/ aliases if present)
$public | ForEach-Object {
  $alias = Get-Alias -Definition $_.BaseName -ErrorAction SilentlyContinue
  if ($alias) {
    # Export defined aliases
    $aliases += $alias
    Write-Output $_.BaseName
    Export-ModuleMember -Function $_.BaseName -Alias $alias
  } else {
    # Export with no alias
    Write-Output $_.BaseName
    Export-ModuleMember -Function $_.BaseName
  }
}

# Update the module manifest on changes
$Added = $public | Where-Object {$_.BaseName -notin $Manifest.ExportedFunctions.Keys}
$Removed = $Manifest.ExportedFunctions.Keys | Where-Object {$_ -notin $public.BaseName}
$aliasesAdded = $aliases | Where-Object {$_ -notin $Manifest.ExportedAliases.Keys}
$aliasesRemoved = $Manifest.ExportedAliases.Keys | Where-Object {$_ -notin $aliases}
if ($Added -or $Removed -or $aliasesAdded -or $aliasesRemoved) {
  try {
    $updateModuleManifestParams = @{}
    $updateModuleManifestParams.Add("Path", $ManifestPath)
    $updateModuleManifestParams.Add("ErrorAction", "Stop")
    if ($aliasesAdded.Count -gt 0) { $updateModuleManifestParams.Add("AliasesToExport", $aliases) }
    if ($Added.Count -gt 0) { $updateModuleManifestParams.Add("FunctionsToExport", $public.BaseName) }

    Update-ModuleManifest @updateModuleManifestParams
  }
  catch {
    $_ | Write-Error
  }
}

function Get-ModuleRoot { # Get the root path of this module, useful for relative paths for extra things like 'resources'
  return Resolve-path $PSScriptRoot
}
