#!/bin/bash
cd /opt/docs.ukfast.co.uk
curl -XDELETE 'http://localhost:9200/documentation/'
make populate-index
