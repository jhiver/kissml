KissML
======

KissML is a little markup language that compiles into HTML and XML. You can also extend it to compile into templating languages such as RactiveJS.

The goal of KissML is to focus on making well structured, readable documents.


Installation
------------

	npm install -g kissml


Getting started
---------------

With KissML, instead of writing tags, you write words and indent them properly, i.e.

	html
		head
			title : My First KissML document
		body
			h1 : KissML
			p
				: This is my first KissML document
				: It's nicely formatted and well structured!

You can then use the kissml utility to turn this document into HTML:

	kissml mydoc.kis > mydoc.html

Which produces the following file:

	<html>
	 <head>
	  <title>My First KissML document</title>
	 </head>
	 <body>
	  <h1>KissML</h1>
	  <p>This is my first KissML document
	It&#39;s nicely formatted and well structured!</p>
	 </body>
	</html>


You can also do this programmatically, by importing kissml and using the smack() function.

	#!/usr/bin/env coffee
	kissml = require 'kissml'
	string = myKissMLString()
	html = kissml.smack string


syntax rules
------------


**text**

Each line of text must start with colon then space, i.e.

	p : I am some text

Or

	p
		: I am some
		: multiline
		: text


**tags**

Tags are simply written by writing the tag name and indenting properly.

	html
		body
			ul
				li
					p : first item
				li
					p : second item


**attributes**

Attributes are written using +attribute expression syntax, i.e.

	a +id myID +class foo bar +href http://example.com +title "example"
		: An example link

If you have many attributes and the line is getting too long, you can stick them on the next line provided they are indented to show that they "belong" to the parent element:

	a
		+id myID
		+class foo bar
		+href http://example.com
		+title Example
		: An example link

For commonly used "id", "class", and "href", you can use "#", "." and "@" respectively, so this is equivalent as above:
	
	a #id .foo .bar @http://example.com +title Example : An example link
