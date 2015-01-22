PATH := ./node_modules/.bin:${PATH}

.PHONY : init clean-docs clean build test dist publish

init:
	npm install

build:
	mkdir -p lib
	rm -rf lib
	mkdir -p lib
	coffee -o lib/ -c src/

clean:
	mkdir -p lib
	rm -rf lib
	mkdir -p lib
	rm test/*.js

test:
	npm install
	mkdir -p lib
	rm -rf lib
	mkdir -p lib
	coffee -o lib/ -c src/
	coffee -c test/*.coffee
	mocha
	rm test/*.js

publish: dist build
	npm publish
