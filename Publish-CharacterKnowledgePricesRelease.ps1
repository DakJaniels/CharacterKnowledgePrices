# Packs CharacterKnowledgePrices/ and publishes the matching changelog section.
# Local:  .\Publish-CharacterKnowledgePricesRelease.ps1
#         .\Publish-CharacterKnowledgePricesRelease.ps1 -Tag v1.0.0
# GitHub: push a tag v1.0.0. .github/workflows/release.yml runs this script.
param(
    [string] $Tag,
    [switch] $SkipTag
)

$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repositoryRoot

function Get-AddonVersion {
    $addonPath = Join-Path $repositoryRoot "CharacterKnowledgePrices\CharacterKnowledgePrices.addon"
    $addonText = Get-Content -Path $addonPath -Raw
    $versionMatch = [regex]::Match($addonText, "(?m)^## Version:\s*(\S+)\s*$")
    $addonVersionMatch = [regex]::Match($addonText, "(?m)^## AddOnVersion:\s*(\d+)\s*$")
    if (-not $versionMatch.Success -or -not $addonVersionMatch.Success) {
        throw "CharacterKnowledgePrices.addon is missing ## Version or ## AddOnVersion."
    }
    return $versionMatch.Groups[1].Value
}

function Get-ChangelogSection {
    param([string] $Version)
    $changelogPath = Join-Path $repositoryRoot "changelog.md"
    $lines = Get-Content -Path $changelogPath
    $sectionLines = New-Object System.Collections.Generic.List[string]
    $inSection = $false
    foreach ($line in $lines) {
        if ($line -match "^## \[$([regex]::Escape($Version))\]") {
            $inSection = $true
            continue
        }
        if ($inSection -and $line -match "^## \[") {
            break
        }
        if ($inSection) {
            $sectionLines.Add($line)
        }
    }
    $sectionText = ($sectionLines -join "`n").Trim()
    if (-not $sectionText) {
        throw "changelog.md has no section ## [$Version]."
    }
    return $sectionText
}

$addonVersion = Get-AddonVersion
if (-not $Tag) {
    $Tag = "v$addonVersion"
}
$tagVersion = $Tag -replace "^v", ""
if ($tagVersion -ne $addonVersion) {
    throw "Tag $Tag does not match addon version $addonVersion."
}

$releaseNotes = Get-ChangelogSection -Version $addonVersion
$notesPath = Join-Path $repositoryRoot "CharacterKnowledgePrices-$Tag-notes.md"
$zipPath = Join-Path $repositoryRoot "CharacterKnowledgePrices-$Tag.zip"
Set-Content -Path $notesPath -Value $releaseNotes -Encoding utf8
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}
Compress-Archive -Path (Join-Path $repositoryRoot "CharacterKnowledgePrices") -DestinationPath $zipPath

if (-not $SkipTag) {
    $existingTag = git tag --list $Tag
    if (-not $existingTag) {
        git tag $Tag
    }
    git push origin $Tag
}

gh release create $Tag $zipPath --title "Version $addonVersion" --notes-file $notesPath
Remove-Item $notesPath -Force
Write-Output "Published $Tag with $zipPath"
