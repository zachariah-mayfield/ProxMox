#cloud-config
hostname: ${vm_name}
manage_etc_hosts: true

users:
  - name: "${cloud_init_user}"
    gecos: Ubuntu User
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash
    lock_passwd: false
    passwd: "${cloud_init_password}"
    ssh_authorized_keys:
      - "${cloudinit_ssh_key}"
  - name: "${cloud_init_root}"
    lock_passwd: false
    passwd: "${cloud_init_password}"
    ssh_authorized_keys:
      - "${cloudinit_ssh_key}"

ssh_pwauth: true
disable_root: false

write_files:
  - path: /etc/ssh/sshd_config.d/99-cloud-init.conf
    content: |
      Port 22
      PermitRootLogin yes
      PasswordAuthentication yes
      PubkeyAuthentication yes
      KexAlgorithms +diffie-hellman-group14-sha1,diffie-hellman-group-exchange-sha256,curve25519-sha256,curve25519-sha256@libssh.org
      Ciphers +aes256-ctr,aes192-ctr,aes128-ctr,chacha20-poly1305@openssh.com
      MACs +hmac-sha2-256,hmac-sha2-512,hmac-sha1

packages:
  - qemu-guest-agent
  - docker.io
  - docker-compose
  - git
  - ca-certificates
  - curl

runcmd:
  - systemctl start qemu-guest-agent
  - systemctl enable --now docker
  - echo "ttyS0" >> /etc/securetty
