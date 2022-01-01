#!/bin/sh -xe

rmhost=192.168.193.3
# Authorized key file already uploaded
# Static lease for wifi
scp -o StrictHostKeyChecking=no templates/*.png root@$rmhost:/usr/share/remarkable/templates

# Merge templates.json file
## Download current
scp -o StrictHostKeyChecking=no root@$rmhost:/usr/share/remarkable/templates/templates.json /tmp/templates.json

# Merge
jq  -as '{ templates: map(.templates[]) }' /tmp/templates.json mytemplates.json > merged.json

if [ ! -f "merged.json" ];
then
    echo "Failed to crate merged template file"
    exit 1
fi

if [ ! -s "merged.json" ]
then
    echo "Created empty merged template file"
    exit 1
fi

# Upload
## Original
now=$(date +"%m_%d_%Y")
rand=$(echo $RANDOM | md5sum | head -c 20)
scp -o StrictHostKeyChecking=no /tmp/templates.json root@$rmhost:/home/root/templates_${now}_$rand.json
scp -o StrictHostKeyChecking=no merged.json root@$rmhost:/usr/share/remarkable/templates/templates.json

ssh -t -o StrictHostKeyChecking=no root@$rmhost "systemctl restart xochitl"
