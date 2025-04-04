# Adds new variables to terraform variable file.
import json
import os

## Appends new variables for resource group, container and database to .tfvars.json file
def write_json(new_data, resource):
    with open("./terraform/infrastruktur/terraform.tfvars.json",'r+') as file:
        # Load existing data into a dict.
        file_data = json.load(file)
        
        # Update
        if (resource == "rg_dynamic"):
            file_data[resource].update(new_data)
        elif (resource == "container"):
            file_data["container"].update(new_data)
        elif (resource == "db"):
            file_data["postdb"].update(new_data)
        # Sets file's current position at offset.
        file.seek(0)
        # convert back to json and save.
        json.dump(file_data, file, indent = 4)


studentFolderName = os.environ["STUDENT_FOLDER"]
imageName = os.environ["DOCKER_IMAGE_NAME"]
db = os.environ["DATABASE"]

newResourceGroup = {"rg_"+studentFolderName: {
    "name": "rg-"+studentFolderName,
    "location": "westeurope"
    }
}

# Add new container to .tfvars.json
# First create new container object
with open("./terraform/infrastruktur/templates/containerObj.json",'r+') as file:

    # Load data from container template into a dict.
    containerObj = json.load(file)

    # Set values
    containerObj[studentFolderName] = containerObj["container"]
    del containerObj["container"]
    containerObj[studentFolderName]["name"] = studentFolderName
    containerObj[studentFolderName]["image"] = imageName
    containerObj[studentFolderName]["rg"] = "rg-"+studentFolderName

# Append the new variables to .tfvars.json
write_json(newResourceGroup,"rg_dynamic")
write_json(containerObj,"container")
# Only add database resource if student program has a database
if (db == "true"):

    with open("./terraform/infrastruktur/templates/databaseObj.json",'r+') as file:

        # Load data from database template into a dict.
        databaseObj = json.load(file)

        # Set values
        dbName = studentFolderName+"-db"
        databaseObj[dbName] = databaseObj["db"]
        del databaseObj["db"]
        databaseObj[dbName]["name"] = dbName
      
    write_json(databaseObj, "db")


    
