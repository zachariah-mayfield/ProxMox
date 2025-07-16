def pytest_addoption(parser):
    parser.addoption(
        "--ssh-key", action="store", default=None, help="Path to SSH private key"
    )

import pytest

@pytest.fixture
def ssh_key(request):
    return request.config.getoption("--ssh-key")
