#!/bin/bash

###############################################################################
# To run a hash function, uncomment the block of code that you would like to
# run.
#
# To cleanup directory, run clean.sh.
# 
# Author: Jemmy Gazhenko
# Date: Dec. 1 2014
# Version: 1
###############################################################################

#echo 'Testing Jenkins Hash Assembly'
#echo '-----------------------------'

#harptool -A -o boot.out boot.s
#harptool -A -o lib.out lib.s
#harptool -A -o jenkins_hash.out jenkins_hash.s
#harptool -L -o jenkins_hash.HOF boot.out lib.out jenkins_hash.out
#harptool -E -c jenkins_hash.HOF

#echo ' '
#echo 'Testing MurMur Hash Assembly'
#echo '----------------------------'

#harptool -A -o boot.out boot.s
#harptool -A -o lib.out lib.s
#harptool -A -o murmur_hash.out murmur_hash.s
#harptool -L -o murmur_hash.HOF boot.out lib.out murmur_hash.out
#harptool -E -c murmur_hash.HOF

#echo 'Testing Jenkins Hash Assembly library'
#echo '-----------------------------'

#harptool -A -o boot.out boot.s
#harptool -A -o lib.out lib.s
#harptool -A -o jenkins_hash_lib.out jenkins_hash_lib.s
#harptool -A -o jenkins_hash_program.out jenkins_hash_program.s
#harptool -L -o jenkins_hash_program.HOF boot.out lib.out jenkins_hash_lib.out jenkins_hash_program.out
#harptool -E -c jenkins_hash_program.HOF

#echo 'Testing Murmur Hash Assembly library'
#echo '-----------------------------'

#harptool -A -o boot.out boot.s
#harptool -A -o lib.out lib.s
#harptool -A -o murmur_hash_lib.out murmur_hash_lib.s
#harptool -A -o murmur_hash_program.out murmur_hash_program.s
#harptool -L -o murmur_hash_program.HOF boot.out lib.out murmur_hash_lib.out murmur_hash_program.out
#harptool -E -c murmur_hash_program.HOF

echo 'Testing Hashmap library'
echo '-----------------------------'

harptool -A -o boot.out boot.s
echo 'Finished with boot'
harptool -A -o lib.out lib.s
echo 'Finished with lib'
harptool -A -o hashmap.out hashmap.s
echo 'Finished with hashmap'
harptool -A -o hashmap_program.out hashmap_program.s
echo 'Finished with hashmap_program'

harptool -A -o print-stack-lib.out print-stack-lib.s
echo 'Finished with print-stack-lib'

harptool -L -o hashmap_program.HOF boot.out lib.out print-stack-lib.out hashmap_program.out hashmap.out
#harptool -L -o hashmap_program.HOF boot.out lib.out hashmap_program.out hashmap.out
harptool -E -c hashmap_program.HOF
