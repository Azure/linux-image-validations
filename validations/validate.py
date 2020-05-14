from image_validator.pkgmgr.common import get_package_manager_info
from image_validator.system import sysinfo, get_sysinfo
from image_validator.os_information.grub_info import get_grub_parameters
from datetime import datetime as dt
import json
import os
import socket

release_notes = dict()

def package_manager_validation():
    try:
        import yum
        from image_validator.pkgmgr.Yum import YumValidation
        package_manager = YumValidation()
    except ImportError:
        try:
            import dnf
            from image_validator.pkgmgr.dnf import dnfValidation
            package_manager = dnfValidation()
        except ImportError:
            return dict()

    get_package_manager_info(package_manager)
    return package_manager.info

if __name__ == "__main__":

    try:
        release_notes["updateInformation"] = package_manager_validation()
    except Exception as e:
        release_notes["updateInformation"] = str(e)

    get_sysinfo()
    release_notes["systemInformation"] = sysinfo
    release_notes["grubParameters"] = get_grub_parameters()
    release_notes["version"] = "1.0.0"
    release_notes["name"] = "ImageBuild Validator"
    release_notes["date"] = str(dt.now())
    release_notes["hostname"] = socket.gethostname()

    try:
        release_notes["generation"] = release_notes["hostname"].split('-')[-1]
        release_notes["imageName"] = release_notes["hostname"].split('-')[0]
    except:
        pass

    with open("logs.json", 'w') as f:
        f.write(json.dumps(release_notes, indent=4))