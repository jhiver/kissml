chai = require 'chai'
assert = chai.assert

Tokenizer = require '../lib/kissml_tokenizer'
tokenizer = Tokenizer.Create()

Parser = require '../lib/kissml_parser'
parser = Parser.Create()


string = """
html
  : Hello, World
"""
describe 'simple example', ->
	describe "root node", ->
		token = tokenizer.frack string
		tree   = parser.organize token
		it "exists", -> assert.ok tree