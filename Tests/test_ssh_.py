import sys
import paramiko

ssh_key_path = sys.argv[1]  # Gets the path from command line argument in Azure DevOps pipeline
host = "192.168.1.250"
username = "root"

def main():
    key = paramiko.RSAKey.from_private_key_file(ssh_key_path)
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname=host, username=username, pkey=key)
    _, stdout, _ = client.exec_command("echo ✅ SSH connection successful")
    output = stdout.read().decode().strip()
    print(output)
    assert "✅ SSH connection successful" in output
    client.close()

if __name__ == "__main__":
    main()
