def pytest_addoption(parser):
    parser.addoption(
        "--ssh-key", action="store", default=None, help="Path to SSH private key"
    )
