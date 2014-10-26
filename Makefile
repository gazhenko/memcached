all:

	gcc -o memcached memcached.c murmur.c jenkins.c memcached.h

clean:

	rm memcached
