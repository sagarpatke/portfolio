variable "debian-netinst-iso-url" {
  type = string
  default = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.9.0-amd64-netinst.iso"
}

variable "debian-netinst-iso-checksum" {
  type = string
  default = "sha512:47d35187b4903e803209959434fb8b65ead3ad2a8f007eef1c3d3284f356ab9955aa7e15e24cb7af6a3859aa66837f5fa2e7441f936496ea447904f7dddfdc20"
}

variable "vagrant-cloud-token" {
  type = string
  default = "abc"
}

variable "build-version" {
  type = string
}

variable "no-release" {
  type = bool
  default = true
}

source "virtualbox-iso" "stable-64" {
  guest_os_type = "Debian_64"
  http_directory = "."
  iso_checksum = var.debian-netinst-iso-checksum
  iso_url = var.debian-netinst-iso-url
  disk_size = "10000"
  ssh_username = "debian"
  ssh_password = "debian"
  ssh_wait_timeout = "1500s"
  boot_wait = "5s"
  cpus = 4
  memory = 4096
  boot_command = [
    "<esc><wait>",
    "install ",
    "locale=en_US.UTF-8 ",
    "keymap=us ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/stable-64.seed.cfg ",
    "hostname=localhost domain=localdomain",
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
    "--description", "A stable-64 vagrant box created from official netinst ISO",
  ]

  shutdown_command = "echo 'debian' | sudo -S shutdown -P now"
  output_directory = "target/stable-64"
  output_filename = "packer_stable_64_virtualbox"
}

source "virtualbox-ovf" "stable-64" {
  source_path = "target/stable-64/packer_stable_64_virtualbox.ovf"
  ssh_username = "debian"
  ssh_password = "debian"
  shutdown_command = "echo 'debian' | sudo -S shutdown -P now"
}

source "vagrant" "stable-64-lightdm-mate" {
  communicator = "ssh"
  source_path = "target/stable-64/packer_stable_64_virtualbox.box"
  provider = "virtualbox"
  output_dir = "target/stable-64-lightdm-mate/"
}

build {
  sources = [
    "sources.virtualbox-iso.stable-64"
  ]
}

build {
  sources = [
    "sources.virtualbox-ovf.stable-64"
  ]

  provisioner "shell" {
    inline = ["echo 'debian' | sudo -S apt-get install -y python3"]
  }

  provisioner "ansible" {
    playbook_file = "playbook.yaml"
    user = "vagWe have to remind Sanak that the URLs will change rant"
    extra_arguments = [
      "--extra-vars", "ansible_python_interpreter=/usr/bin/python3 ansible_sudo_pass=debian"
    ]
  }

  provisioner "ansible" {
    playbook_file = "playbook-minimize.yaml"
    user = "vagrant"
    extra_arguments = [
      "--extra-vars", "ansible_python_interpreter=/usr/bin/python3 ansible_sudo_pass=debian"
    ]
  }

  post-processors {
    post-processor "vagrant" {
      keep_input_artifact = true
      provider_override = "virtualbox"
      compression_level = 9
      output = "target/stable-64/packer_stable-64_virtualbox.box"
    }

    post-processor "vagrant-cloud" {
      no_release = "${var.no-release}"
      access_token = "${var.vagrant-cloud-token}"
      box_tag = "sagarpatke/stable-64"
      version = "${var.build-version}"
    }
  }
}

build {
  sources = [
    "sources.vagrant.stable-64-lightdm-mate" # requires virtualbox-iso.stable-64 to be run first
  ]

  provisioner "ansible" {
    playbook_file = "posts/00003-vagrant-box-for-stable-64/playbook-lightdm-mate.yaml"
    extra_arguments = [
      "--extra-vars", "ansible_python_interpreter=/usr/bin/python3 ansible_sudo_pass=debian"
    ]

  }

  provisioner "ansible" {
    playbook_file = "posts/00003-vagrant-box-for-stable-64/playbook-minimize.yaml"
    extra_arguments = [
      "--extra-vars", "ansible_python_interpreter=/usr/bin/python3 ansible_sudo_pass=debian"
    ]
  }

  post-processor "vagrant-cloud" {
    no_release = "${var.no-release}"
    access_token = "${var.vagrant-cloud-token}"
    box_tag = "sagarpatke/bullseye64-lightdm-mate"
    version = "${var.build-version}"
  }
}
