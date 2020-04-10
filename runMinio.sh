#!/usr/bin/env bash
#todo: use a launch script/daemon 
/minio/minio server /data &> /tmp/minio.log &
