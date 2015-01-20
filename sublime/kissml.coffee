_ = require 'underscore'
kissml = require 'kissml'

parser = require 'kissml_pa
printer = require './kissml_printer'
tokenizer = require './kissml_tokenizer'

module.exports.smack = (string, parser, printer) ->
	tokenizer = opts.tokenizer or tokenizer.Create()
	printer   = opts.printer   or printer.Create()
	parser    = opts.parser    or parser.Create()

	token  = tokenizer.frack string
	tree   = parser.organize token
	result = printer.walk tree

	return result