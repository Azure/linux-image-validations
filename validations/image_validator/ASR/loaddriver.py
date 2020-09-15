import os
import json

def load_driver_involflt():
    return os.system('sripts/LoadDriver.sh')

def process_information(status):
    return json.dumps(
        {
            'name' : 'ASR Module Test',
            'version' : '1.0.0',
            'type' : 'Involflt Driver load',
            'status' : 'Passed' if status==0 else 'Failed'    
        },
        indent = 4
    )

def invoke_load_driver():
    status = load_driver_involflt()
    return process_information(status)
