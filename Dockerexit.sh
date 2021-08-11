#!/bin/bash

cd /home/webadmin/dtmp/

echo "Passed Parameters : $1 , $2 , $3 , $4 , $5"

# Remove dangling images 
# dang_images=`docker rmi $(docker images | grep "^<none>" | awk "{print $3}")`

# Remove existing build image before creating a new one
img_exists=`docker rmi ubuntu_email`
# Remove the stopped containers
# del_cont=`docker rm -f $(docker ps -qa)`

if [ $img_exists == *"help"* ]
then
   echo "Image does not exists already so building it"
else 
   echo "Existing Image has been deleted..Rebuilding it...Please Wait!!!"
fi

# Start building the image

url=`echo git@gitlab.ins.risk.regn.net:laravelweb/sbfe.git`
branch=`echo develop`
env=`echo dev`

time docker build -t ubuntu_email --build-arg gurl=$url --build-arg bch=$branch --build-arg envt=$env --build-arg CACHEBUST=$(date +%s) .
pid_status=`echo $?`

# The Docker process will return the code 0 on successful execution and a non zero code in case of any failure

if [ $pid_status = 0 ] 
then
    echo "*******************************************************"
    echo "Docker executed successfully"
    echo "*******************************************************"
    
else
    echo "*******************************************************"
    echo "                                                       "
    echo "The Docker container has exited improperly             "
    echo "                                                       "
    export REPLYTO="DEEPA.AKELLA@lexisnexisrisk.com"
    EMAILS="DEEPA.AKELLA@lexisnexisrisk.com"
    TODAY=$(date +%F)
    text=`echo -e "CI_JOB : $4 \nCI_JOB_STAGE : $5 \nCI_JOB_URL : $3 \nGIT_REPO : $1 \nGIT_BRANCH : $2"`
    MBODY="$text"
    echo "$MBODY" | mail -s "The Docker service running on GIT was aborted" -- $EMAILS
fi
