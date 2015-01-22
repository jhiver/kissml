_      = require 'underscore'
kiss   = require '../lib/kissml'
chai   = require 'chai'
assert = chai.assert

console.log kiss.Parser.toString()

describe 'Parser',    ->
	it 'has Parser',    -> assert.ok kiss.Parser
	it 'works',         -> assert.ok kiss.Parser()

describe 'Printer',   ->
	it 'has Printer',   -> assert.ok kiss.Printer
	it 'works',         -> assert.ok kiss.Printer()

describe 'Tokenizer', ->
	it 'has Tokenizer', -> assert.ok kiss.Tokenizer
	it 'works',         -> assert.ok kiss.Tokenizer()

describe 'Constants', ->
	it 'has Constants', -> assert.ok kiss.Constants
	it 'works',         -> assert.ok kiss.Constants()

describe 'TreeNode',  ->
	it 'has TreeNode',  -> assert.ok kiss.TreeNode
	it 'works',         -> assert.ok kiss.TreeNode()