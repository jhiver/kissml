chai = require 'chai'
assert = chai.assert
TreeNode = require '../lib/kissml_treenode'
_ = require 'underscore'

Tokenizer = require '../lib/kissml_tokenizer'
Parser = require '../lib/kissml_parser'
Printer = require '../lib/kissml_printer'

string = """
html +lang en
	head
		title : This is a test
	body
		div #content
			div #section1
				h1 : Test
				p .lead
					: This is a test, to make sure that
					: kissML has a reasonable chance of working.
			div #section2
				: This is another section.
"""
describe 'simple conversion test', ->
	tokenizer = Tokenizer.Create()
	printer   = Printer.Create()
	parser    = Parser.Create()

	token  = tokenizer.frack string
	tree   = parser.organize token
	result = printer.walk tree

	lines = result.split "\n"

	it '<html lang="en">', -> assert.equal lines[0], '<html lang="en">'
	it ' <head>', -> assert.equal lines[1], ' <head>'
	it '  <title>This is a test</title>', -> assert.equal lines[2], '  <title>This is a test</title>'
	it ' </head>', -> assert.equal lines[3], ' </head>'
	it ' <body>', -> assert.equal lines[4], ' <body>'
	it '  <div id="content">', -> assert.equal lines[5], '  <div id="content">'
	it '   <div id="section1">', -> assert.equal lines[6], '   <div id="section1">'
	it '    <h1>Test</h1>', -> assert.equal lines[7], '    <h1>Test</h1>'
	it '    <p class="lead">This is a test, to make sure that', -> assert.equal lines[8], '    <p class="lead">This is a test, to make sure that'
	it 'kissML has a reasonable chance of working.</p>', -> assert.equal lines[9], 'kissML has a reasonable chance of working.</p>'
	it '   </div>', -> assert.equal lines[10], '   </div>'
	it '   <div id="section2">This is another section.</div>', -> assert.equal lines[11], '   <div id="section2">This is another section.</div>'
	it '  </div>', -> assert.equal lines[12], '  </div>'
	it ' </body>', -> assert.equal lines[13], ' </body>'
	it '</html>', -> assert.equal lines[14], '</html>'