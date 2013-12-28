#!/usr/bin/expect

set timeout 3

spawn ssh localhost hostname
expect "Are you sure you want to continue connecting (yes/no)?"
exec sleep 1
send "yes\r"
expect "#"


set pw [lindex $argv 0]
expect "password:"
exec sleep 1
send  "$pw\r"
expect "#"

exit

