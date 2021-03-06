import os
import datetime 
import dateutil.parser
import argparse

from os import path
from azure.cosmosdb.table.tableservice import TableService
from azure.cosmosdb.table.models import Entity

class AzureTableData:
    """
    This class handles the functionality of getting data from
    Azure Table Storage and generating the HTML report
    """
    def __init__(self, args):
        connect_str = args.connection_str
        self.table_service = TableService(connection_string=connect_str)

    def get_report_line(self, index, image, context):
        """
        This function generates a single row of resultant validation report
        """
        result_line = "\t<tr class='" + context + "'>\n"

        if hasattr(image, 'ErrorMessages'):
            err_msg = str(image.ErrorMessages).replace("\n", "</br>")
        else:
            err_msg = ""

        result_line = result_line + "\t\t<td>" + str(index) + "</td>\n"
        result_line = result_line + "\t\t<td>" + str(image.PartitionKey) + "</td>\n"
        result_line = result_line + "\t\t<td>" + str(image.ValidationResult) + "</td>\n"
        result_line = result_line + "\t\t<td>" + err_msg + "</td>\n"

        result_line = result_line + "\t</tr>\n"
        return result_line
        
    def generate_validation_report(self, args):
        """
        This functions generates the HTML report of validations
        """
        imagequeryresult = self.table_service.query_entities(args.table_name,
            filter="IsDeleted eq '0'",
            accept='application/json;odata=minimalmetadata')
        current_date_time = datetime.datetime.now(datetime.timezone.utc)

        index = 1
        result_line = """
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Marketplace Image Validation Report</title>
    <meta charset="utf-8">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
</head>
<body>
    <table class="table">
        <tr>
            <td> # </td>
            <td> VM Name </td>
            <td> Validation Result </td>
            <td> Error Messages </td>
        </tr>\n"""
        with open('./report/index.html', 'w') as report:
            context = "danger"
            for image in imagequeryresult:
                if image.ValidationResult == "Failed":
                    result_line = result_line + self.get_report_line(index, image, context)
                    index += 1
            
            context = "success"
            for image in imagequeryresult:
                if image.ValidationResult == "Success":
                    result_line = result_line + self.get_report_line(index, image, context)
                    index += 1

            context = "warning"
            for image in imagequeryresult:
                if image.ValidationResult == "NA":
                    result_line = result_line + self.get_report_line(index, image, context)
                    index += 1

                
            result_line = result_line + "</table></body></html>"
            report.write("%s\n" % result_line)
            

    def select_images_to_validate(self, args):
        """
        This function iterates over all the entries in the Azure Table Storage
        and selects at max 'args.max_vm_to_validate' images which should get validated 
        during this run.
        """
        max_vms_to_validate_at_a_time = int(args.max_vm_to_validate )
        validation_period = int(args.validation_period)

        allimages = open(args.all_image_list, 'r')
        Lines = allimages.readlines()
        
        imagequeryresult = self.table_service.query_entities(args.table_name,
            filter="IsDeleted eq '0'",
            accept='application/json;odata=minimalmetadata')

        entries = []
        list_of_images_to_validate = []
        current_date_time = datetime.datetime.now(datetime.timezone.utc)
        for image in imagequeryresult:
            entries.append(image)

        for line in Lines:
            publisher = line.split(':')[0]
            offer = line.split(':')[1]
            sku = line.split(':')[2]
            disk_version = line.split(':')[3].replace('\n', '')

            image_name = offer.replace("_", "-") + "-" + sku.replace("_", "-") + "-" + disk_version
            
            image_entry_exists = False
            for image in entries:
                # if the image entry exists and it was last validated 2 days ago,
                # add it to the list to be validated
                if image.PartitionKey == image_name:
                    image_entry_exists = True
                    if image.ValidationResult == 'NA' or (current_date_time - image.Timestamp).days > validation_period:
                            list_of_images_to_validate.append(line)                    
                    break

            if not image_entry_exists:
                list_of_images_to_validate.append(line)

                ## insert the entry as well
                args.image_name = image_name
                args.validation_result = 'NA'
                self.insert_data(args)

        i = 0
        with open(args.filtered_image_list, 'w') as filteredimagefile:
            filteredimagefile.write("")
            for image in list_of_images_to_validate:
                if i == max_vms_to_validate_at_a_time:
                    break
                filteredimagefile.write("%s" % image)
                i += 1

    def insert_data(self, args):
        """
        Inserts/updates the records in the Azure Table Storage
        """
        table_name = args.table_name
        image_name = args.image_name
        validation_time = args.validation_time
        validation_result = args.validation_result
        validation_epoch = args.validation_epoch

        print("error message path", args.err_msg_file)
        if args.err_msg_file != None and path.exists(args.err_msg_file):
            err_msgs = open(args.err_msg_file, "r").read()
        else:
            err_msgs = ""

        validationResult = {
            'PartitionKey': image_name,
            'RowKey': "1", 
            'ValidationResult': validation_result,
            "ErrorMessages": err_msgs,
            "IsDeleted": "0"
        }

        print(validationResult)

        self.table_service.insert_or_replace_entity(table_name, validationResult)


def parse_arguments():
    parser = argparse.ArgumentParser(description= "Build Template Generator Arguments")

    parser.add_argument('--method', '-m', help = "Method to execute")

    parser.add_argument('--connection-str', '-c', help = "connection string for the storage account")
    parser.add_argument('--container-name', '-n', help = "Container name")
    parser.add_argument('--table-name', '-t', help = "Table name")
    parser.add_argument('--image-name', '-i', help = "Image name which was validated")
    parser.add_argument('--validation-epoch', '-e', help = "Epoch value at the time of validation")
    parser.add_argument('--validation-time', help = "Time of validation")
    parser.add_argument('--validation-result', help = "Validation result")
    parser.add_argument('--err-msg-file', help = "File which contains error messages")

    parser.add_argument('--all-image-list', '-in', help = "connection string for the storage account")
    parser.add_argument('--filtered-image-list', '-out', help = "connection string for the storage account")

    parser.add_argument('--max-vm-to-validate', help = "Number of VMs to validate in a single run")
    parser.add_argument('--validation-period', help = "Number of days to wait before validating a VM again")

    return parser.parse_args()

if __name__ == "__main__":
    args = parse_arguments()
    tabledata = AzureTableData(args)

    if args.method == "insert-data":
        tabledata.insert_data(args)
    elif args.method == "select-images-to-validate":
        tabledata.select_images_to_validate(args)
    elif args.method == "generate-report":
        tabledata.generate_validation_report(args)