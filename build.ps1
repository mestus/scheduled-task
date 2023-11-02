$token = $args[0]
$project = "ScheduledTask"
$packageVersion = $args[1] ?? ""
$repositoryUrl = "https://github.com/$env:GITHUB_REPOSITORY"
$owner = "$env:GITHUB_REPOSITORY_OWNER"
$feedUrl = "https://nuget.pkg.github.com/$owner/index.json"
$configuration = "Release"
$output = "output"
$runtime = "win-x64"

Write-Host "Repository owner: [$($env:GITHUB_REPOSITORY_OWNER)]"

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
dotnet tool restore
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

dotnet publish --configuration $configuration -p:PackageVersion=$packageVersion -o $output -r $runtime --self-contained true -p:RepositoryType=git -p:RepositoryUrl="$repositoryUrl"  $project.csproj
if ($LASTEXITCODE -eq 1)
{
    throw "publish FAILED"
}

if ($packageVersion -ne "--no-pack")
{
    dotnet dotnet-octo pack --id=$project --version=$packageVersion --basePath=$output
    if ($LASTEXITCODE -eq 1)
    {
        throw "dotnet-octo pack FAILED"
    }

    dotnet nuget push *.nupkg -k $token -s $feedUrl
    if ($LASTEXITCODE -eq 1)
    {
        throw "dotnet nuget push FAILED"
    }
}