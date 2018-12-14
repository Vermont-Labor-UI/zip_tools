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
    $zip 
    try {
        $fileName = ([io.path]::Combine($pathInZip, [System.IO.Path]::GetFileName($newFileToAdd) ) | Out-String).Trim()
        $newFileToAddString = ($newFileToAdd | Out-String).Trim()
        Write-Host "Adding File $newFileToAddString to $zipFileName at location $fileName"

        [Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null
        $zip = [System.IO.Compression.ZipFile]::Open($zipFileName, "Update")
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $newFileToAddString, $fileName) | Out-Host
        Write-Host "Successfully added $newFileToAdd to $zipFileName at location $fileName"
    }
    catch {
        Write-Warning "Failed to add $newFileToAdd to $zipFileName . Details : $_"
    }
    finally {
        if ($null -ne $zip) {
            $zip.Dispose()
        }
    }
    
}

ResolveFilePattern($zipFileNamePattern) | ForEach-Object {
    $zipFileName = $_
    ResolveFilePattern($newFileToAddPattern) | ForEach-Object {
        $newFileName = $_
        Write-Host "Found $zipFileName and $newFileName in path $pathInZip"
        Add-FileToZipAtPath -zipFileName $zipFileName -newFileToAdd $newFileName
    }
}