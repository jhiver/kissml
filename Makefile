PATH := ./node_modules/.bin:${PATH}

.PHONY : init clean-docs clean build test dist publish

init:
	npm install

build:
	rm lib/*
	rmdir lib
	mkdir lib
	coffee -o lib/ -c src/

clean:
	rm lib/*
	rmdir lib
	rm test/*.js

test:
	rm lib/*
	rmdir lib
	mkdir lib
	coffee -o lib/ -c src/
	coffee -c test/*.coffee
	mocha
	rm test/*.js

publish: dist build
	npm publish