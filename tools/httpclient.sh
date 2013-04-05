#!/bin/sh -f
POSTFIX_ENV_FILE=$1

. $POSTFIX_ENV_FILE
RAILS_ROOT=$1
shift 1
RUBY=/usr/bin/ruby
#echo $1 $2 $3

umask 002

cd $RAILS_ROOT
$RUBY bin/httpclient.rb $*

