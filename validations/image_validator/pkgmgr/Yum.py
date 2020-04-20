#!/bin/python

from .common import Validation
import json
import yum

class YumValidation(Validation):
    '''
    Attributes of YUM
    repo.yumvar = Yum Variables that are enabled for each repo
    repo.sslclientcert: sslclientcert path for each repo
    yb.yumvar = global yum variables and custom added in /etc/yum/vars
    '''

    def __init__(self):
        self.yb = yum.YumBase()
        super(YumValidation, self).__init__()

    def get_repos(self):    
        repolist = list()
        for repoid, repo in self.yb.repos.repos.items():
            try:
                repo.verify()
                verify = True
            except:
                verify = False
            
            repolist.append({'id':repoid, 
                            'vars':repo.yumvar, 
                            'enabled': repo.isEnabled(), 
                            'baseurl':repo._urls, 
                            'sslclientcert': repo.sslclientcert,
                            'name': repo.name,
                            'verify': verify})
                            
        self.info['repos'] = repolist

    def get_vars(self):
        self.info['packageManagerVariables'] = self.yb.conf.yumvar
