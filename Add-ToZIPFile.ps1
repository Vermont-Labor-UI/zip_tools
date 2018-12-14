[CmdletBinding()]
Param(
    [string]$zipFileNamePattern,
    [string]$newFileToAddPattern
)

function ResolveFilePattern {
    param (
        [string]$fileNamePattern
    )

    return $fileNamePattern | Resolve-Path
}

function AddFileToZipAtPath {
    param (
        [string]$zipFileName,
        [string]$newFileToAdd,
        [string]$pathInZip
    )

    try {
        [Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null
        $zip = [System.IO.Compression.ZipFile]::Open($zipFileName, "Update")
        $fileName = [System.IO.Path]::GetFileName($newFileToAdd)
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $newFileToAdd, $fileName, "Optimal") | Out-Null
        $Zip.Dispose()
        Write-Host "Successfully added $newFileToAdd to $zipFileName "
    }
    catch {
        Write-Warning "Failed to add $newFileToAdd to $zipFileName . Details : $_"

    }
    
}

ResolveFilePattern($zipFileNamePattern) | ForEach-Object {
    $zipFileName = $_
    ResolveFilePattern($newFileToAddPattern) | ForEach-Object {
        $newFileName = $_
        Write-Host "Found $zipFileName and $newFileName"
    }
}