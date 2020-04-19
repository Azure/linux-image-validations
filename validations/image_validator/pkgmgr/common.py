class Validation(object):

    def __init__(self):
        self.info = dict()

    def get_repos(self):
        pass

    def get_vars(self):
        pass

    def get_update_info(self):
        self.get_vars()
        self.get_repos()


def get_package_manager_info(package_manager):
    package_manager.get_update_info()
