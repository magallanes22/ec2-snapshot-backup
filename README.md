# ec2-snapshot-backup
Automated snapshots for AWS 

### The script is executed daily, snapshots are being deleted automatically after 3 days. 

The snapshot's life time is defined by a variable called **erase**. This can be modified anytime in the bash script. 


### Snapshots are created using volumene's ID and instance's ID###

Volumenes ID's are indicated under the "**snap**" variable in the bash script. Instance's ID under the "**instance**" variable. 

If another server need to be backed up, both, volume ID or IDS and instance ID need to be added on the script. It's important to follow the order according the volume ID. 
