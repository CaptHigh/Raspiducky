import configparser
from sys import exit


class Config:
    _config_file = '/etc/raspiducky/bluetooth.conf'
    _uuid = None

    def __init__(self):
        try:
            config = configparser.ConfigParser()
            config.read(self._config_file)
            self._uuid = config.get('service', 'uuid')
        except configparser.NoOptionError:
            print("Error reading config file.")
            exit(2)

    def get_uuid(self):
        return self._uuid
