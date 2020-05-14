import re

def get_grub_parameters():
    grubParametersFile = open("/etc/default/grub", "r")

    grubParameters = {}
    
    for line in grubParametersFile.readlines(): 
        if(line.startswith('#')) :
            continue

        m = re.search('([a-zA-Z_]+)=(.+)', line)
        if m:
            grubParameters[m.group(1)] = m.group(2)
    
    return grubParameters

if __name__ == "__main__":
    print(get_grub_parameters())