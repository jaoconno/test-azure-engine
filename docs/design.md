# Design of the ManageEngine AssetExplorer POC Pipeline

This document will include design decisions, implementation details, and declare assumptions that were made during the
poc process.

## High Level Design

1. Application Pipeline is kicked off via a commit
2. Generate Version for NuGet Package
3. Pipeline runs `choco pack` to build NuGet package (`*.nupkg`).
4. Publish NuGet Package to Azure DevOps NuGet Feed

## Detailed Design

### Nuget Package Version Generation

The pipeline needed a way to create a unique version for NuGet. If the NuGet package version isn't unique then the
the `nuget push` command will fail. There is also a need for the version to be available during the Terraform tasks
later in the pipeline. The best way to manage both is to generate a unique version using the version in the nuspec file
and appending the first 6 of the git commit hash. The PowerShell below generates the variable for us:

```powershell
  [xml]$nuXML = Get-Content .\assetexplorer.nuspec
  $OriginalVersion = $nuXML.package.metadata.version
  $gitHash = "$(Build.SourceVersion)"
  $shortHash = $gitHash.Substring(0,6)
  $NuVersion = "$OriginalVersion-G$shortHash"

  #update version
  $nuXML.package.metadata.version = $NuVersion
  $nuXML.Save(".\assetexplorer.nuspec")
  echo "NuVersion $NuVersion"
```

The PowerShell above will read in the `assetexplorer.nuspec` file as XML. `$NuVersion` will be created by taking the
version from the `*.nuspec` and the first 6 chars of the commit id. A keen observer will notice the hardcoded `*-G*` in
the `$NuVersion`. This is in order to align to the NuGet Package version rules. Finally, the PowerShell script will
updated the version and save the `*.nuspec` back to the directory being used for the `choco pack` task to use. 

Terraform can use this version in the future to create the VM Scale Set. Since this is currently all one job, the
Terraform task can simply call `$NuVersion` in order to deploy the correct version.

### Choco Pack

We are going to use [Chocolatey](https://chocolatey.org/) as the package manager of choice. Chocolatey works on Windows
and build [NuGet](https://www.nuget.org/) packages. In order to do this we needed to have Chocolatey installed on the
build agent. The Windows 2016 and Windows 2019 agent pools have Chocolatey installed. Since these are Microsoft hosted
there is no need to do anything special. _note: The same build agent will be used for publishing later_

The only requirement to get this working is Chocolatey installed and having a nuspec file available for chocolatey to
use. Once you have that then you can set up the `azure-pipelines.yml` file looks like so:

```yaml
# bare minimum pipeline file
pool:
  vmImage: 'windows-2019'

steps:
- task: PowerShell@2
  inputs:
    targetType: 'inline'
    script: 'choco pack'
```

Some helpful links:

* [Windows 2016 Agent Pool Installed Software](https://github.com/actions/virtual-environments/blob/master/images/win/Windows2016-Readme.md)
* [Windows 2019 Agent Pool Installed Software](https://github.com/actions/virtual-environments/blob/master/images/win/Windows2019-Readme.md)

### NuGet Push

Since a `choco pack` generates a `*.nupkg` we are able use the [NuGetCommand](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/package/nuget)
with the `push` option. This will use the NuGet Package created earlier and publish to a NuGet Feed in Azure DevOps.
This feed follows standard NuGet requirements (i.e. package version, name, etc). Once available in the feed, the
provision script can use this artifact during deployment.
