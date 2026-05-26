# tf-cicd-githubapi

The aim is to use terraform to build a cicd pipeline that uses a github API to copy data.
We will also implement cicd here using workflows 
The exact API I want to use here is not decided yet but I will zero it down as soon as I am done with creating the basic infrastructure


#### Flow
- create a resource group `rg-tfstate` that contains the tfstate files for both staging and prod environments
- create app registrations for staging and prod env
- give all the necessary permissions to these apps
- create groups (if required) with required roles and assign members to it

^^^^^^ the flow for basic infra that will be created using shell files and will be executed manually once with the `az login` command 