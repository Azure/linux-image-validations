from .common import Validation
import dnf

class dnfValidation(Validation):

    def __init__(self):
        self.db = dnf.Base()
        self.db.read_all_repos()
        super(dnfValidation, self).__init__()

    def get_repos(self):
        repolist = list()
        repo_config = dict()
        for repoid, repo in self.db.repos.items():
            repo_config['id'] = repoid
            for optBind in repo._config.optBinds():
                repo_config[optBind.first] = optBind.second.getValueString()

            repolist.append(repo_config)

        self.info['repos'] = repolist

    def get_vars(self):
        self.info['yumvar'] = db.conf.__dict__['substitutions']
        
