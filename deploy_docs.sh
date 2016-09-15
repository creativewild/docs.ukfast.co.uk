#!/bin/bash
cd /var/www/vhosts/docs.ukfast.co.uk
git pull origin master
cd sekhmet && git pull origin master && cd -
make clean && make html
curl -XDELETE 'http://localhost:9200/documentation/'
make populate-index
