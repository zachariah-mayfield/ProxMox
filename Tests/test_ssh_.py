import paramiko

def test_ssh_connection(ssh_key):
    host = "192.168.1.250"
    username = "root"

    key = paramiko.RSAKey.from_private_key_file(ssh_key)
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname=host, username=username, pkey=key)

    _, stdout, _ = client.exec_command("echo ✅ SSH connection successful")
    output = stdout.read().decode().strip()

    client.close()
    assert "✅ SSH connection successful" in output
