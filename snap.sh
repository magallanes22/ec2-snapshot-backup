#! /bin/bash


# Variable to get the time.
tim=$(date +%F)
# Set the days to delete snapshots.
erase=3

# Create Array with ID from its Volumes.
# Add other volume if you want create other spanshot.
snap=(vol-c4280705 vol-a5bd7652 vol-8e1eb579 vol-78a64a8f vol-9ae7186d vol-319242c6)

# Name of the instance in order with snap variable.
instance=(vpc-prod-app-01 vpc-prod-app-02 vpc-prod-web-01 vpc-prod-eventbus-01 vpc-prod-eventbus-02 vpc-prod-db-01)
loop=0

snapComp=($(aws ec2 describe-snapshots --filter Name=description,Values="Snapshot created*" | grep -i starttime | awk '{print $2}' |cut -d, -f1 | sed 's/"//g' | cut -c-10))
snapId=($(aws ec2 describe-snapshots --filter Name=description,Values="Snapshot created*" | grep -i snapshotid | awk '{print $2}' |cut -d, -f1 | sed 's/"//g'))
verification=($(aws ec2 describe-snapshots --filter Name=description,Values="Snapshot created at $tim *" | grep -i snapshotid | awk '{print $2}' |cut -d, -f1 | sed 's/"//g'))

# Variables Snapshot.
month=$(echo $snapComp | cut -c6,7)
# sort -n| tail -n1
day=$(echo $snapComp | cut -c9,10 | sort -n| tail -n1)

# System Variables.
monthSystem=$(date +%F| cut -c6,7)
daySystem=$(date +%F| cut -c9,10)

# Subtract Snapshot day to system day.
# If is biggest than "erase" variable (3 days)

# CREATE SNAPSHOTS.
# Conditional, if one snapshot is created this day, so don't repeat the action again.
if [ "$verification" == "" ]; then
        for i in ${snap[@]}; do
                # Start create the snapshots.
                echo "Start create snapshot $snap from ${instance[loop]}"
                aws ec2 create-snapshot --volume-id $i --description "Snapshot created at $tim from volume ${snap[loop]} and instance name ${instance[loop]}."
                let "loop++"
        done
fi

# DELETE SNAPSHOTS.
it=0
# If syetem month system is diferent to snapshot month.
# Is necessary other kind of operation than if it was the same month.
if [ "$day" != "" ]; then
	snapMont=$(date -d "$month/1 + 1 month - 1 day" "+%b - %d" | awk '{print $3}')
	if [ "$month" != "$monthSystem" ]; then
		days=$(expr $snapMont - $day + $daySystem)
	fi
	if [ "$month" == "$monthSystem" ]; then
		days=$(expr $daySystem - $day)
	fi
fi

# If is on the same month, only check system time and snapshots time and compare if the time set in "Erase" is equals or bigger than.
if [ $days -gt  $erase ]; then
		for a in ${snapComp[@]}; do
                        echo "Delete Snapshot: ${snapId[it]}"
                        aws ec2 delete-snapshot --snapshot-id ${snapId[it]}
                        let "it++"
                done
fi
