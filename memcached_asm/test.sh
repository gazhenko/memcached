harptool -A -o boot.out boot.s
echo 'Finished with boot'
harptool -A -o lib.out lib.s
echo 'Finished with lib'
harptool -A -o print-stack-lib.out print-stack-lib.s
echo 'Finished with print-stack-lib'
harptool -A -o test_print_stack_lib.out test_print_stack_lib.s
echo 'Finished with test_print_stack_lib'

harptool -L -o test_print_stack_lib.HOF boot.out lib.out print-stack-lib.out test_print_stack_lib.out
harptool -E -c test_print_stack_lib.HOF