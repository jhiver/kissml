TYPE      = require './kissml_constants'
parser    = require './kissml_parser'
printer   = require './kissml_printer'
tokenizer = require './kissml_tokenizer'
treenode  = require './kissml_treenode'
fs        = require 'fs'
_ = require 'underscore'


# IF:
# -------------------------------------------------------------------
# IF expression               {{#if expression}}
#  foo             ----->       <foo>
#	   bar                          <bar></bar>
#                               </foo>
#                             {{/if}}
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
	current.type = TYPE.RAW
	current.start = '{{#if ' + expr + '}}'
	current.stop  = '{{/if}}'
	return [current, token]


# UNLESS: very similar to IF...
Handle_UNLESS = (current, token) ->
	return [current, null] unless token.data is 'UNLESS'

	# Fast-forward to next newline to find out expression
	expr = []
	while token isnt 'END' and token.data isnt "\n"
		token = token.next
		expr.push token.data

	# Looks like this node is an "IF" node, let's constantsruct it
	expr = expr.join('').replace(/^\s+/, '').replace(/\s+$/, '')
	current.type = TYPE.RAW
	current.start = '{{#unless ' + expr + '}}'
	current.stop  = '{{/unless}}'
	return [current, token]


# FOR:
# -------------------------------------------------------------------
# FOR expression              {{#for expression}}
#  foo             ----->       <foo>
#	   bar                          <bar></bar>
#                               </foo>
#                             {{/for}}
# -------------------------------------------------------------------
Handle_FOR = (current, token) ->
	return [current, null] unless token.data is 'FOR'

	# Fast-forward to next newline to find out expression
	expr = []
	while token isnt 'END' and token.data isnt "\n"
		token = token.next
		expr.push token.data

	# Looks like this node is an "IF" node, let's constantsruct it
	expr = expr.join('').replace(/^\s+/, '').replace(/\s+$/, '')
	current.type = TYPE.RAW
	current.start = '{{#each ' + expr + '}}'
	current.stop  = '{{/each}}'
	return [current, token]


# Allows to write things like:
# ----------------------------
# body
#  IF results && results.length
#   dl
#    FOR results
#     dt : {{key}}
#     dd : {{val}}
#  ELSE
#   div .alert .alert-info
#    : No results for your search.
Handle_ELSE = (current, token) ->
	return [current, null] unless token.data is 'ELSE'

	parent = current.parent
	previousSibling = current.previousSibling()
	current.type = TYPE.RAW

	if previousSibling.isRASH
		current.start = previousSibling.start.replace /\#/, '^'
		current.stop  = previousSibling.stop
		current.text  = previousSibling.text
	else
		current.start = '{{#else}}'
		parent.delChild current
		previousSibling.addChild current
		current.depth = ->
			return 0 unless current.parent
			return current.parent.depth()

	return [current, token.next]


# Allows to write standard Ractive hash syntax, i.e.
# This is discouraged but supported nonetheless.
# -------------------------------------------------------------------
# {{#foo}}
# {{/foo}}
# -------------------------------------------------------------------
Handle_RASH = (current, token) ->
	return [current, null] unless token.data is 'RASH'

	# Fast-forward to next newline to find out expression
	expr = []
	while token isnt 'END' and token.data isnt "\n"
		token = token.next
		expr.push token.data

	# Looks like this node is an "IF" node, let's constantsruct it
	expr = expr.join('').replace(/^\s+/, '').replace(/\s+$/, '')
	current.type = TYPE.RAW
	current.start = '{{#' + expr + '}}'
	if expr.match /\s|\(|\)/
		current.stop = '{{/end}}'
	else
		current.stop = '{{/' + expr + '}}'

	current.isRASH = true
	return [current, token]


# -------------------------------------------------------------------
# {{foo}}
# -------------------------------------------------------------------
Handle_VAR = (current, token) ->
	return [current, null] unless token.data is 'VAR'

	# Fast-forward to next newline to find out expression
	expr = []
	while token isnt 'END' and token.data isnt "\n"
		token = token.next
		expr.push token.data

	# Looks like this node is an "IF" node, let's constantsruct it
	expr = expr.join('').replace(/^\s+/, '').replace(/\s+$/, '')
	current.type = TYPE.RAW
	current.start = ' {{' + expr + '}} '

	return [current, token]


# -------------------------------------------------------------------
# {{>foo}}
# -------------------------------------------------------------------
Handle_INCLUDE = (current, token) ->
	return [current, null] unless token.data is 'INCLUDE'

	# Fast-forward to next newline to find out expression
	expr = []
	while token isnt 'END' and token.data isnt "\n"
		token = token.next
		expr.push token.data

	# Looks like this node is an "IF" node, let's constantsruct it
	expr = expr.join('').replace(/^\s+/, '').replace(/\s+$/, '')
	current.type = TYPE.RAW
	current.start = ' {{>' + expr + '}} '

	return [current, token]


Printer = -> return printer.Create()

Tokenizer = -> return tokenizer.Create()

Constants = -> return TYPE

TreeNode = -> return treenode.Create()

Parser = ->
	p = parser.Create()
	p.extend Handle_IF
	p.extend Handle_UNLESS
	p.extend Handle_FOR
	p.extend Handle_ELSE
	p.extend Handle_RASH
	p.extend Handle_VAR
	p.extend Handle_INCLUDE
	return p


smack = (string, opts) ->
	opts or= {}
	theTokenizer = opts.tokenizer or Tokenizer()
	thePrinter   = opts.printer   or Printer()
	theParser    = opts.parser    or Parser()

	token  = theTokenizer.frack string
	tree   = theParser.organize token
	result = thePrinter.walk tree

	return result


run = ->
	string = fs.readFileSync process.argv.pop(), encoding: 'utf8'
	string = string.replace /\r\n/g, "\n"
	string = string.replace /\n\r/g, "\n"
	console.log smack string

module.exports =
	Parser: Parser
	Printer: Printer
	Tokenizer: Tokenizer
	Constants: Constants
	TreeNode: TreeNode
	smack: smack
	run: run