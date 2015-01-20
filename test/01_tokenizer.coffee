chai = require 'chai'
assert = chai.assert

Tokenizer = require '../lib/kissml_tokenizer'
tokenizer = Tokenizer.Create()


describe 'tokenizer', ->
	it 'should exist', -> assert.ok Tokenizer
	it 'should have a Create() constructor', -> assert.ok Tokenizer.Create

	describe 'constructor', ->
		t = Tokenizer.Create()
		it 'should return an object', ->
			assert.ok t
			assert.equal typeof(t), 'object'
		it 'should have a frack() method', ->
			assert.ok t.frack
			assert.equal typeof(t.frack), 'function'


string = """
html
  : Hello, World
"""
describe 'simple example', ->
	describe "token #1", ->
		token = tokenizer.frack string
		it "html", -> assert.equal token.data, "html"
		it "has next", -> assert.ok token.next

	describe "token #2", ->
		token = tokenizer.frack string
		token = token.next
		it "new line", -> assert.equal token.data, "\n"
		it "has next", -> assert.ok token.next

	describe "token #3", ->
		token = tokenizer.frack string
		token = token.next.next
		it "indentation space", -> assert.match token.data, /^\s+$/
		it "has next", -> assert.ok token.next

	describe "token #4", ->
		token = tokenizer.frack string
		token = token.next.next.next
		it "colon", -> assert.equal token.data, ":"
		it "has next", -> assert.ok token.next

	describe "token #5", ->
		token = tokenizer.frack string
		token = token.next.next.next.next
		it "single space", -> assert.equal token.data, " "
		it "has next", -> assert.ok token.next

	describe "token #6", ->
		token = tokenizer.frack string
		token = token.next.next.next.next.next
		it "hello", -> assert.equal token.data, "Hello,"
		it "has next", -> assert.ok token.next

	describe "token #7", ->
		token = tokenizer.frack string
		token = token.next.next.next.next.next.next
		it "single space", -> assert.equal token.data, " "
		it "has next", -> assert.ok token.next

	describe "token #8", ->
		token = tokenizer.frack string
		token = token.next.next.next.next.next.next.next
		it "world", -> assert.equal token.data, "World"
		it "has next", -> assert.ok token.next
		it "is last token", -> assert.equal token.next, "END"