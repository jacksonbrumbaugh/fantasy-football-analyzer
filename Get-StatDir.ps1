function Get-StatDir {
	# $Home variable defaults to 'C:\Users\<current-user>'
	# You will need to update this to the directory you placed the stats CSV files
    $StatDir = $Home

    if (-not (Test-Path $StatDir)) {
        Write-Information "Creating stats folder $StatDir"
        New-Item -Path $StatDir -ItemType Directory | Out-Null
    }

    $StatDir
}
