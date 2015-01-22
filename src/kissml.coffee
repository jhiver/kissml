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

Constants = -> return constants

TreeNode = -> return treenode.Create()

smack = (string, opts) ->
	opts or= {}
	theTokenizer = opts.tokenizer or Tokenizer()
	thePrinter = opts.printer   or Printer()
	theParser = opts.parser    or Parser()

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