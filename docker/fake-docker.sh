#! /bin/bash

# This is a very simple way to convert the instructions in a
# Docker file into a script.  It is very simple, using egrep and sed
# and it will not handle multi-line docker commands *at all*

# So keep those Dockerfiles simple and do all the work in the 
# prepare and startup scripts to avoid breaking the ubuntu and
# ami processes

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

