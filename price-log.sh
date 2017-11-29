#!/bin/bash
now=`date +"%Y/%m/%d %H:%M:%S"`
price=`bundle exec ruby mid-price.rb`
echo "${now},${price}" >> ./log/price.log
