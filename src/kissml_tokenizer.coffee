_ = require 'underscore'

Create = ->
	self = {}

	self.frack = (aString) ->
		lines  = aString.split "\n"
		token =
			prev: null
			next: null
			data: null

		result = []
		while lines.length
			line = lines.shift()
			tokens = line.match /\S+|\s+/g
			_.each tokens, (data) ->
				token.next =
					prev: token
					next: null
					data: data
					type: 'text'
				token = token.next
				if data.match /^\s+$/
					token.type = 'space'
			if lines.length
				token.next =
					prev: token
					next: null
					data: "\n"
					type: "newline"
				token = token.next

		token.next = "END"
		while token.prev
			token = token.prev
		return token.next

	return self

module.exports.Create = Create