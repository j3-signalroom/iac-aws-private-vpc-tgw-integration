locals {
    organization_name = "signalroom"
    workspace_name    = "iac-aws-private-vpc"
}

data "tfe_organization" "signalroom" {
  name = local.organization_name
}

data "tfe_workspace" "workspace" {
  name         = local.workspace_name
  organization = data.tfe_organization.signalroom.name
}

resource "tfe_workspace_settings" "workspace_settings" {
  workspace_id   = data.tfe_workspace.workspace.id
  execution_mode = "local"
}
