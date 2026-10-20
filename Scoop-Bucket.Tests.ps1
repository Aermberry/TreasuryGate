if (!$env:SCOOP_HOME) { $env:SCOOP_HOME = Resolve-Path (scoop prefix scoop) }
. "$env:SCOOP_HOME\test\Import-Bucket-Tests.ps1"

Describe 'Snitch manifest' {
    BeforeAll {
        $manifest = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'bucket\snitch.json') -Raw |
            ConvertFrom-Json
    }

    It 'uses a Windows backend release URL matching the manifest version' {
        $releaseUrlMatch = [regex]::Match(
            $manifest.url,
            '^https://github\.com/aixisstudio/Snitch/releases/download/v(?<version>[^/]+)/snitch-backend-windows-latest\.tar\.gz$'
        )
        $releaseUrlMatch.Success | Should -Be $true
        $releaseUrlMatch.Groups['version'].Value | Should -Be $manifest.version
    }

    It 'provides an autoupdate URL for versioned Windows backend releases' {
        $manifest.autoupdate.url | Should -Be 'https://github.com/aixisstudio/Snitch/releases/download/v$version/snitch-backend-windows-latest.tar.gz'
        $manifest.autoupdate.url.Replace('$version', $manifest.version) | Should -Be $manifest.url
    }

    It 'has a SHA-256 hash' {
        $manifest.hash | Should -Match '^[a-fA-F0-9]{64}$'
    }

    It 'points Scoop to the backend executable inside the extracted release directory' {
        $manifest.extract_dir | Should -Be 'snitch-backend'
        $manifest.bin | Should -Be 'snitch-backend.exe'
    }
}
