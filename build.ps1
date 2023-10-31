$token = $args[0]
$packageVersion = $args[1] ?? ""
$repositoryUrl = "https://github.com/$env:GITHUB_REPOSITORY"
$owner = $env:GITHUB_REPOSITORY.Split('/')[0]
$feedUrl = "https://nuget.pkg.github.com/$owner/index.json"
$configuration = "Release"
$output = "output"

if ($packageVersion -eq "")
{
    $lastTag = git describe --tags --abbrev=0 --match 'v*'
    $lastVersion = $lastTag ? $lastTag.Substring(1) : "0.0.0"
    $versionParts = $lastVersion.Split('.')
    $major = [int]$versionParts[0]
    $minor = [int]$versionParts[1]
    $patch = [int]$versionParts[2]
    $range = $lastTag ? "$lastTag.." : ""

    if (git log $range --grep="BREAKING CHANGE")
    {
        $major++
    }
    elseif (git log $range --grep="^feat") {
        $minor++
    }
    else {
        $patch++
    }

    $now = [System.DateTime]::UtcNow.ToString("yyyyMMddHHmm")
    $packageVersion = "$major.$minor.$patch-ci$now"
}

dotnet restore
dotnet build --no-restore --configuration $configuration
if ($LASTEXITCODE -eq 1)
{
    throw "Build FAILED"
}
dotnet test --no-build --configuration $configuration --verbosity normal
if ($LASTEXITCODE -eq 1)
{
    throw "Tests FAILED"
}
if ($packageVersion -ne "--no-pack")
{
    dotnet pack --no-build --configuration $configuration -p:PackageVersion=$packageVersion -p:RepositoryType=git -p:RepositoryUrl="$repositoryUrl" -o $output
    dotnet nuget push output/*.nupkg -k $token -s $feedUrl
}