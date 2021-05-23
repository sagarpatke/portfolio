variables {
  cpus = ""
}

source "virtualbox-iso" "buster64" {
  guest_os_type = "Debian_64"
  http_directory = "../../unattended"
  iso_checksum = "sha512:af1717bd1601b575969b5445407bc0104c8930b64a98ca409cecbdc0b896d10a7df174d1882df8ab3eac435e95b1d94c9bb0cdf0cf64cc33fd468c0a55125d72"
  iso_url = "debian-10.9.0-amd64-DVD-1.iso"
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
    "--product", "creativee-ngineering",
    "--vendor", "creative-programming",
    "--version", "0.1.0",
    "--description", "A buster64 vagrant box created from scratch",
  ]

  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"
  output_directory = "target"
}

build {
  sources = [
    "sources.virtualbox-iso.buster64"
  ]

  provisioner "ansible" {
    playbook_file = "./playbook.yaml"
    user = "vagrant"
  }

  post-processor "vagrant" {
    keep_input_artifact = true
    provider_override = "virtualbox"
    compression_level = 9
    output = "target/packer_{{.BuildName}}_{{.Provider}}.box"
  }
}
