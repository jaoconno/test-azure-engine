# App Pipeline Tenets and Behaviors

This document contains the basic tenets and behaviors we expect to see in an app pipeline. This document is not a
design doc.

## POC Description

Building a proof of concept for an app pipeline. We will not be building/unit testing an application but rather
creating a release artifact of [ManageEngineer AssetExplorer](https://www.manageengine.com/products/asset-explorer/).
The pipeline will use chocolatey to build an artifact and push to a NuGet feed. Once successfully published, the
pipeline will use an [Azure VM Scale Set](https://azure.microsoft.com/en-us/services/virtual-machine-scale-sets/) to
spin up a set of VMs. Those VMs will deploy the application using Chocolatey. The app pipeline _should not_ reach in to
the VMs to install. The VMs should live behind a firewall.

A later step should have a blue-green component. The application pipeline will spin up a full set of VMs and place them
behind a temporary load balancer. There will need to be smoke tests of some sort to verify that everything is working
appropriately then the pipeline can move forward and set the VMs behind the "production" load balancer.

## High Level Tenets/Behavior

* Should use Chocolatey to package AssetManager
* Should launch VMs through autoscaling - [VM Scale Sets](https://azure.microsoft.com/en-us/services/virtual-machine-scale-sets/)
* Load Balancer in front of the VM Scale Sets
  * "Production" load balancer that
  * A temporary load balancer that comes up with the pipeline then scales down
* Pipeline should manage credentials
* Smoke testing
  * hit some HTTP endpoint
  * load balancer should use that as a health check endpoint
* How do you do updates to the app?
  * Use a blue/green deployment
  * Use a new VM scale set
  * Add to test load balancer to check everything is good
  * Then switch vm scale set to prod load balancer
  * _The above bullets are AWS. Look at Azure specific options it._
  * Blue green is the most important concept we want to include.
* For Deployment
  * Pipeline shouldn’t reach in to instances
  * Look at some sort of init script
  * Look at cloud-init support
* Pipelines
  * Golden Image - create golden image
  * App pipeline - build, publish, deploy
