def get_os_kernel_version():
    cmdlineProcFile = open("/proc/cmdline", "r")
    return cmdlineProcFile.read()

if __name__ == "__main__":
    print(get_os_kernel_version())