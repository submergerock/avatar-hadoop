#!/usr/bin/expect

set timeout 3

spawn ssh [lindex $argv 0] hostname
expect "Are you sure you want to continue connecting (yes/no)?"
exec sleep 1
send "yes\r"
expect "#"


set pw [lindex $argv 1]
expect "password:"
exec sleep 1
send  "$pw\r"
expect "#"

exit

