import re

def get_grub_parameters():
    grub_parameters_file = open("/etc/default/grub", "r")

    grub_parameters = {}
    
    for line in grub_parameters_file.readlines(): 
        if(line.startswith('#')) :
            continue

        m = re.search('([a-zA-Z_]+)=(.+)', line)
        if m:
            grub_parameters[m.group(1)] = m.group(2)
    
    return grub_parameters

if __name__ == "__main__":
    print(get_grub_parameters())