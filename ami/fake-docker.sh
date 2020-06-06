#! /bin/bash

if [ -z "$1" ] ;
then
    echo Please specify a folder
    exit
fi

cd $1
if [ ! -f "Dockerfile" ] ; 
then
    echo "Could not find Dockerfile"
    exit
fi

egrep '^FROM|^COPY|^RUN' < Dockerfile | sed -e 's/^COPY/cp -r/' -e 's/^RUN //' -e 's/FROM/echo FROM/' | bash -vx

