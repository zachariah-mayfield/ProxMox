import testinfra

def test_ssh_service_running(host):
    sshd = host.service("ssh")
    assert sshd.is_running
    assert sshd.is_enabled
