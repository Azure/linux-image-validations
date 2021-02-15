import os
import datetime 
import dateutil.parser
import argparse
from azure.cosmosdb.table.tableservice import TableService
from azure.cosmosdb.table.models import Entity

class AzureTableData:
    def __init__(self, args):
        connect_str = args.connection_str
        self.table_service = TableService(connection_string=connect_str)

    def select_images_to_validate(self, args):
        max_vms_to_validate_at_a_time = int(os.environ['MAX_VM_TO_VALIDATE'])
        print("max vm", max_vms_to_validate_at_a_time)

        allimages = open(args.all_image_list, 'r')
        Lines = allimages.readlines()
        
        imagequeryresult = self.table_service.query_entities(args.table_name, accept='application/json;odata=minimalmetadata')
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

                    if image.ValidationResult == 'NA' or (current_date_time - image.Timestamp).days > 4:
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
        table_name = args.table_name
        image_name = args.image_name
        validation_time = args.validation_time
        validation_result = args.validation_result
        validation_epoch = args.validation_epoch

        validationResult = {
            'PartitionKey': image_name,
            'RowKey': "1", 
            'ValidationResult': validation_result
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

    parser.add_argument('--all-image-list', '-in', help = "connection string for the storage account")
    parser.add_argument('--filtered-image-list', '-out', help = "connection string for the storage account")

    return parser.parse_args()

if __name__ == "__main__":
    args = parse_arguments()
    tabledata = AzureTableData(args)

    if args.method == "insert_data":
        tabledata.insert_data(args)
    elif args.method == "select-images-to-validate":
        tabledata.select_images_to_validate(args)