terraform {
    cloud {
      organization = "signalroom"

        workspaces {
            name = "iac-aws-private-vpc"
        }
    }

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "6.28.0"
        }
        tfe = {
            source = "hashicorp/tfe"
            version = "~> 0.73.0"
        }
    }
}
