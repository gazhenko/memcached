echo 'Testing Stack Concepts'
echo '-----------------------------'

harptool -A -o boot.out boot.s
echo 'Finished with boot'
harptool -A -o lib.out lib.s
echo 'Finished with lib'
harptool -A -o test_stack.out test_stack.s
echo 'Finished with test_stack'
harptool -A -o print-stack-lib.out print-stack-lib.s
echo 'Finished with print-stack-lib'

harptool -L -o test_stack.HOF boot.out lib.out print-stack-lib.out test_stack.out
harptool -E -c test_stack.HOF