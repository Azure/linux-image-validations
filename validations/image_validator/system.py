import re
import json
import subprocess
import platform
import os

sysinfo = dict()

'''
Libraries used
1. Platform: Used in getting platform and machine related details
'''

def get_os_kernel_version():
    sysinfo["os"] = ' '.join(platform.linux_distribution())
    sysinfo["machine"] = platform.machine()
    sysinfo["processor"] = platform.processor()
    sysinfo["kernel"] = platform.release()
    sysinfo["platform"] = platform.platform()

def is_efi_booted():
    sysinfo["isEfiBooted"] = os.path.isdir("/sys/firmware/efi")

def get_proc_commandline():
    sysinfo["procCmdline"] = open('/proc/cmdline').read().strip()

def get_command_output(command):
    return subprocess.Popen([command], stdout=subprocess.PIPE, shell=True)

def get_disk_info():
    """
    fdisk parsing for disk output
    List of columns:
        1. name = Disk name (sda, sdb)
        2. labelType = whether it is dos or gpt
        3. partitions = list of partitions and its usage in a dict
    """
    disk_json = list()
    disk_dict = dict()
    result = get_command_output('/usr/sbin/fdisk -l 2>/dev/null')
    for line in result.stdout.read().strip().splitlines():
        try:
            line = ' '.join(line.strip().split(' '))
            if line.startswith('Disk /'):
                disk_dict['name'] = line[5:].split(':')[0].split('/')[-1].strip()
            if line.startswith('Disk label type'):
                disk_dict['labelType'] = line.split(':')[1].strip()
            disk_dict['partitions'] = get_partition_information(disk_dict['name'])            
            
            if 'labelType' in disk_dict.keys() and 'name' in disk_dict.keys():
                disk_json.append(disk_dict)
                disk_dict = dict()
        except Exception as e:
            continue
    sysinfo["disk"] = disk_json

def get_partition_information(disk):
    part_json = list()
    try:
        result = get_command_output('/bin/lsblk -o name -n -s -l -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT | grep part')
        for line in result.stdout.readlines():
            info = ' '.join(line.strip().split(' ')).split()
            if info[0].startswith(disk):
                part_json.append({'name': info[0].strip(), 'fstype': info[2].strip(), 'mountpoint': info[-1].strip()})
        return partition_usage(part_json)
    except Exception as e:
        print(e)

def partition_usage(part_info):
    usage = dict()
    units = {'MB' : 2**20}
    for part in part_info:
        try:
            import shutil
            part["size"], part["used"], part["free"] = shutil.disk_usage(part["mountpoint"])
        except:
            stats = os.statvfs(part["mountpoint"])
            part["free"] = stats.f_bfree * stats.f_bsize
            part["size"] = stats.f_blocks * stats.f_bsize
            part["used"] = part["size"] - part["free"]

        part["size"], part["used"], part["free"] = part["size"]/units['MB'], part["used"]/units['MB'], part["free"]/units['MB']
        part["units"] = units
        
    return part_info

def get_sysinfo():
    get_os_kernel_version()
    is_efi_booted()
    get_proc_commandline()
    get_disk_info()

if __name__ == "__main__":
    main()
    print(json.dumps(sysinfo, indent=4))