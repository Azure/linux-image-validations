import os
import datetime 
import dateutil.parser
import argparse

from os import path
from azure.cosmosdb.table.tableservice import TableService
from azure.cosmosdb.table.models import Entity
from azure.cosmosdb.table.tablebatch import TableBatch

class AzureTableData:
    """
    This class handles the functionality of getting data from
    Azure Table Storage cleaning it.
    """
    def __init__(self, args):
        connect_str = args.connection_str
        self.table_service = TableService(connection_string=connect_str)

    def clean_up_table(self, args):
        """
        Fetches all the images from Azure Table Storage.
        Marks the images as deleted if the image is not present
        in Azure Marketplace
        """
        allimages = open(args.all_image_list, 'r')
        images_in_marketplace = allimages.readlines()
        
        imagequeryresult = self.table_service.query_entities(args.table_name, 
            filter="IsDeleted eq 0",
            accept='application/json;odata=minimalmetadata')
        
        print("Creating list of images")
        list_of_images_to_clean_up = []
        for image in imagequeryresult:
            disk_version = image.PartitionKey.split('-')[-1]
            
            l = [image_name for image_name in images_in_marketplace if disk_version in image_name]
            if l == None or len(l) is 0:
                list_of_images_to_clean_up.append(image)            

        print("Updating", len(list_of_images_to_clean_up))
        self.mark_deleted(list_of_images_to_clean_up, args.table_name)

    def mark_deleted(self, images, table_name):
        """
        Updates Azure Table Storage record by marking it as deleted
        """
        i = 1
        for image in images:
            image.IsDeleted = 1
            self.table_service.update_entity(table_name, image)
            print(i)
            i += 1

def parse_arguments():
    parser = argparse.ArgumentParser(description= "Build Template Generator Arguments")

    parser.add_argument('--connection-str', '-c', help = "connection string for the storage account")
    parser.add_argument('--all-image-list', '-in', help = "connection string for the storage account")
    parser.add_argument('--table-name', '-t', help = "Table name")

    return parser.parse_args()

if __name__ == "__main__":
    args = parse_arguments()
    tabledata = AzureTableData(args)
    
    tabledata.clean_up_table(args)