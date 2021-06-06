variable "debian-netinst-iso-url" {
  type = string
  default = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.9.0-amd64-netinst.iso"
}

variable "debian-netinst-iso-checksum" {
  type = string
  default = "sha512:47d35187b4903e803209959434fb8b65ead3ad2a8f007eef1c3d3284f356ab9955aa7e15e24cb7af6a3859aa66837f5fa2e7441f936496ea447904f7dddfdc20"
}

source "virtualbox-iso" "buster64" {
  guest_os_type = "Debian_64"
  http_directory = "unattended"
  iso_checksum = var.debian-netinst-iso-checksum
  iso_url = var.debian-netinst-iso-url
  disk_size = "10000"
  ssh_username = "vagrant"
  ssh_password = "vagrant"
  ssh_wait_timeout = "1500s"
  boot_wait = "10s"
  cpus = 4
  memory = 4096
  boot_command = [
    "<esc><wait>",
    "install ",
    "locale=en_US.UTF-8 ",
    "keymap=us ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/buster64.cfg<wait> ",
    "hostname=localhost domain=localdomain ",
    "<wait><enter>"
  ]

  vboxmanage_post = [
    ["modifyvm", "{{.Name}}", "--memory", "512"],
    ["modifyvm", "{{.Name}}", "--cpus", "1"]
  ]

  export_opts = [
    "--manifest",
    "--vsys", "0",
    "--product", "creative-engineering",
    "--vendor", "creative-programming",
    "--version", "0.1.0",
    "--description", "A buster64 vagrant box created from official netinst ISO",
  ]

  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"
  output_directory = "target"
  output_filename = "packer_buster64_virtualbox"
}

source "vagrant" "buster64-lightdm-mate" {
  source_path = "target/packer_buster64_virtualbox.box"
  output_dir = "target/packer_buster64-lightdm-mate_virtualbox"
  skip_add = true
}

build {
  sources = [
    "sourvices.virtualbox-iso.buster64"
  ]

  provisioner "ansible" {
    playbook_file = "posts/00003-vagrant-box-for-buster64/playbook.yaml"
    user = "vagrant"
  }
}

build {
  sources = [
    "sources.vagrant.buster64-lightdm-mate" # requires virtualbox-iso.buster64 to be run first
  ]

  provisioner "ansible" {
    playbook_file = "posts/00003-vagrant-box-for-buster64/playbook-lightdm-mate.yaml"
    user = "vagrant"
  }

  post-processor "vagrant" {
    keep_input_artifact = true
    provider_override = "virtualbox"
    compression_level = 9
    output = "target/packer_buster64_virtualbox-lightdm-mate.box"
  }
}
