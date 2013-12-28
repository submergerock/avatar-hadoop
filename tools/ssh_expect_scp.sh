#!/usr/bin/expect

set timeout 3

spawn  scp [lindex $argv 3]/.ssh/id_dsa.pub [lindex $argv 0]:[lindex $argv 3]/.ssh/[lindex $argv 1].pub

expect "Are you sure you want to continue connecting (yes/no)?"
exec sleep 1
send "yes\r"
expect "#"
set pw [lindex $argv 2]
expect "password:"
exec sleep 1
send  "$pw\r"
expect "#"

#interact

exit


