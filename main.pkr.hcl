variable "ami_name" {
  type    = string
  default = "replicated"
}

variable "subnet_id" {
  type = string
  default = null
}

variable "region" {
  type    = string
  default = null
}

variable "root_volume_size_gb" {
  type = number
  default = 8
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "kots-packer" {
  ami_name      = "${var.ami_name}-${local.timestamp}"
  ami_virtualization_type = "hvm"
  ssh_username = "ec2-user"
  ssh_timeout = "2h"
  ebs_optimized = true
  instance_type = "t3.micro"
  region        = "${var.region}"
  subnet_id = "${var.subnet_id}"
  ssh_interface = "session_manager"
  aws_polling {
    delay_seconds = 60
    max_attempts = 60
  }
  launch_block_device_mappings {
    device_name = "/dev/xvda"
    volume_size = "${var.root_volume_size_gb}"
    volume_type = "gp3"
    iops = 3000
    throughput = 125
    delete_on_termination = true
  }
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-2.0.20220426.0-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  temporary_iam_instance_profile_policy_document {
    Version = "2012-10-17"
    Statement {
      Effect = "Allow"
      Action = [
        "ssm:DescribeAssociation",
        "ssm:GetDeployablePatchSnapshotForInstance",
        "ssm:GetDocument",
        "ssm:DescribeDocument",
        "ssm:GetManifest",
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:ListAssociations",
        "ssm:ListInstanceAssociations",
        "ssm:PutInventory",
        "ssm:PutComplianceItems",
        "ssm:PutConfigurePackageResult",
        "ssm:UpdateAssociationStatus",
        "ssm:UpdateInstanceAssociationStatus",
        "ssm:UpdateInstanceInformation"
      ]
      Resource = ["*"]
    }
    Statement {
      Effect = "Allow"
      Action = [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ]
      Resource = ["*"]
    }
    Statement {
      Effect = "Allow"
      Action = [
        "ec2messages:AcknowledgeMessage",
        "ec2messages:DeleteMessage",
        "ec2messages:FailMessage",
        "ec2messages:GetEndpoint",
        "ec2messages:GetMessages",
        "ec2messages:SendReply"
      ]
      Resource = ["*"]
    }
  }
}
build {
  name    = "replicated"
  sources = ["source.amazon-ebs.kots-packer"]
  # upload the kots-install script to a non root directory
  provisioner "file" {
    destination = "/tmp/"
    source      = "./install-kots.sh"
  }
  # move the kots-install script to be executed on initial instance launch
  # use '/var/lib/cloud/scripts/per-boot' to run at every startup
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/install-kots.sh /var/lib/cloud/scripts/per-instance/",
      "sudo chmod 744 /var/lib/cloud/scripts/per-instance/install-kots.sh"
    ]
  }
}
