[CmdletBinding()]
Param(
    [string]$zipFileNamePattern,
    [string]$newFileToAddPattern,
    [string]$pathInZip
)

function ResolveFilePattern {
    param (
        [string]$fileNamePattern
    )

    return $fileNamePattern | Resolve-Path
}

function Add-FileToZipAtPath {
    param (
        [string]$zipFileName,
        [string]$newFileToAdd
    )

    try {
        [Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null
        $zip = [System.IO.Compression.ZipFile]::Open($zipFileName, "Update")
        $fileName = Join-Path $pathInZip [System.IO.Path]::GetFileName($newFileToAdd)
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
        Add-FileToZipAtPath -zipFileName $zipFileName -newFileToAdd $newFileName
        Write-Host "Found $zipFileName and $newFileName in path $pathInZip"
    }
}