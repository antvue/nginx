# !/bin/bash

cd /usr/local/openresty/nginx/logs
if [ $? -ne 0  ]; then
  echo "directory not exists! cd /usr/local/openresty/nginx/logs"
  exit
fi
IS_SYMBOLLINK=`ls -al access.log  | grep -e '/dev/stdout' | wc -l`
if [ ${IS_SYMBOLLINK} -ne 0 ]; then
    echo "stdout! ignore backup."
    exit
fi
file=`date +"access%Y%m%d%H%M%S.log"`
echo ${file}
echo mv access.log ${file}
sleep 10
nginx -s reload
sleep 1
nginx -s reload

