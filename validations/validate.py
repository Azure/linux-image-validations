import json
import os
import socket
from datetime import datetime

from image_validator.ASR.loaddriver import invoke_load_driver
from image_validator.os_information.grub_info import get_grub_parameters
from image_validator.pkgmgr.common import get_package_manager_info
from image_validator.system import get_sysinfo, sysinfo


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
            return {}

    get_package_manager_info(package_manager)
    return package_manager.info


if __name__ == "__main__":
    release_notes = {
        "version": "1.0.0",
        "name": "ImageBuild Validator",
        "date": str(datetime.now()),
        "hostname": socket.gethostname(),
    }

    try:
        release_notes["updateInformation"] = package_manager_validation()
    except Exception as e:
        release_notes["updateInformation"] = str(e)

    get_sysinfo()
    release_notes["systemInformation"] = sysinfo
    release_notes["grubParameters"] = get_grub_parameters()
    release_notes["ASR"] = invoke_load_driver()

    try:
        hostname_parts = release_notes["hostname"].split('-')
        release_notes["generation"] = hostname_parts[-1]
        release_notes["imageName"] = hostname_parts[0]
    except:
        pass

    with open("/tmp/logs.json", "w") as f:
        json.dump(release_notes, f, indent=4)
