from distutils.core import setup

setup(
    # Application name:
    name="device",

    # Version number (initial):
    version="0.1.311",

    # Application author details:
    author="Kali",
    author_email="horse",

    # Packages
    packages=["RaspiDucky"],

    # Details
    url="",

    description="A Keyboard emulator like Rubber Ducky build over Raspberry Pi Zero W",

    data_files=[
        ('/usr/bin', ['raspiducky.py']),
        ('/usr/bin', ['duckyd.py'])
    ],
    requires=['pybluez']
)
