constants = require './kissml_constants'
parser    = require './kissml_parser'
printer   = require './kissml_printer'
tokenizer = require './kissml_tokenizer'
treenode  = require './kissml_treenode'
fs        = require 'fs'
_ = require 'underscore'


# -------------------------------------------------------------------
# IF, FOR, ELSE tag handlers
# -------------------------------------------------------------------
Handle_IF = (current, token) ->
	return [current, null] unless token.data is 'IF'

	# Fast-forward to next newline to find out expression
	expr = []
	while token isnt 'END' and token.data isnt "\n"
		token = token.next
		expr.push token.data

	# Looks like this node is an "IF" node, let's constantsruct it
	expr = expr.join('').replace(/^\s+/, '').replace(/\s+$/, '')
	current.type = constants.RAW
	current.start = '{{#if ' + expr + '}}'
	current.stop  = '{{/if}}'
	return [current, token]


Handle_FOR = (current, token) ->
	return [current, null] unless token.data is 'FOR'

	# Fast-forward to next newline to find out expression
	expr = []
	while token isnt 'END' and token.data isnt "\n"
		token = token.next
		expr.push token.data

	# Looks like this node is an "IF" node, let's constantsruct it
	expr = expr.join('').replace(/^\s+/, '').replace(/\s+$/, '')
	current.type = constants.RAW
	current.start = '{{#each ' + expr + '}}'
	current.stop  = '{{/each}}'
	return [current, token]


Handle_ELSE = (current, token) ->
	return [current, null] unless token.data is 'ELSE'
	current.type = constants.RAW
	current.start = '{{#else}}'

	parent = current.parent
	previousSibling = current.previousSibling()
	parent.delChild current
	previousSibling.addChild current

	return [current, token.next]
# -------------------------------------------------------------------



Printer = -> return printer.Create()

Tokenizer = -> return tokenizer.Create()

Constants = -> return constants.Create()

TreeNode = -> return treenode.Create()

Parser = ->
	p = parser.Create()
	p.extend
		after: 'Handle_AttributeValue'
		name: 'Handle_IF'
		func: Handle_IF
	p.extend
		after: 'Handle_IF'
		name: 'Handle_FOR'
		func: Handle_FOR
	p.extend
		after: 'Handle_FOR'
		name: 'Handle_ELSE'
		func: Handle_ELSE
	return p


smack = (string, opts) ->
	opts or= {}
	tokenizer = opts.tokenizer or Tokenizer()
	printer   = opts.printer   or Printer()
	parser    = opts.parser    or Parser()

	token  = tokenizer.frack string
	tree   = parser.organize token
	result = printer.walk tree

	return result


module.exports.run = ->
	string = fs.readFileSync process.argv.pop(), encoding: 'utf8'
	console.log smack string