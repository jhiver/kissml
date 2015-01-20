constants = require './kissml_constants'
parser    = require './kissml_parser'
printer   = require './kissml_printer'
tokenizer = require './kissml_tokenizer'
treenode  = require './kissml_treenode'
fs        = require 'fs'
_ = require 'underscore'


Parser = -> return parser.Create()

Printer = -> return printer.Create()

Tokenizer = -> return tokenizer.Create()

Constants = -> return constants.Create()

TreeNode = -> return treenode.Create()

smack = (string, opts) ->
	opts or= {}
	tokenizer = opts.tokenizer or Tokenizer()
	printer   = opts.printer   or Printer()
	parser    = opts.parser    or Parser()

	token  = tokenizer.frack string
	tree   = parser.organize token
	result = printer.walk tree

	return result

run = ->
	string = fs.readFileSync process.argv.pop(), encoding: 'utf8'
	console.log smack string

module.exports =
	Parser: Parser
	Printer: Printer
	Tokenizer: Tokenizer
	Constants: Constants
	TreeNode: TreeNode
	smack: smack
	run: run