_ = require 'underscore'
TYPE = require './kissml_constants'


Create = ->
	self = {}
	self.LeadingWhitespaceNeeded = null
	
	self.startHandle = []
	self.textHandles = []
	self.stopHandles = []
	
	self.encodeString = (str) ->
		String(str)
			.replace(/^\#\#/, '#')
			.replace(/^\.\./, '.')
			.replace(/^\:\:/, ':')
			.replace(/^\@\@/, '@')
			.replace(/^\+\+/, '+')
			.replace(/\ \#\#/, " #")
			.replace(/\ \.\./, " .")
			.replace(/\ \:\:/, " :")
			.replace(/\ \@\@/, " @")
			.replace(/\ \+\+/, " +")
			.replace(/\t\#\#/, "\t#")
			.replace(/\t\.\./, "\t.")
			.replace(/\t\:\:/, "\t:")
			.replace(/\t\@\@/, "\t@")
			.replace(/\t\+\+/, "\t+")
			.replace(/&/g, '&amp;')
			.replace(/"/g, '&quot;')
			.replace(/'/g, '&#39;')
			.replace(/</g, '&lt;')
			.replace(/>/g, '&gt;')
			.replace(/__NBSP__/g, '&nbsp;') # surely, a little hack can't hurt once in a while?


	# pretty print start
	self.startPrettyPrintIndent = (node) ->
		if node.parent
			string = "\n"
			depth = node.depth()
			while depth > 0
				string += ' '
				depth--
		else
			string = ''
		return string


	# Self-closing XML / XHTML tag, i.e <hr/>
	self.startSelfClosingTag = (node, string) ->
		nodeTag = node.tag.replace /\/$/, ''
		string += ' ' if self.LeadingWhitespaceNeeded and self.LeadingWhitespaceNeeded.tag and self.LeadingWhitespaceNeeded.tag is TYPE.TEXT
		string += '<'
		string += nodeTag
		_.each node.attributes, (v, k) -> string += " #{k}=\"#{self.encodeString v.join(' ')}\""
		string += " />"
		self.LeadingWhitespaceNeeded = null
		return string

	# Void element TML tag, i.e <br>
	self.startVoidElementTag = (node, string) ->
		nodeTag = node.tag.replace /\!$/, ''
		string += ' ' if self.LeadingWhitespaceNeeded and self.LeadingWhitespaceNeeded.tag and self.LeadingWhitespaceNeeded.tag is TYPE.TEXT
		string += '<'
		string += nodeTag
		_.each node.attributes, (v, k) -> string += " #{k}=\"#{self.encodeString v.join(' ')}\""
		string += ">"
		self.LeadingWhitespaceNeeded = null
		return string

	# Normal tag
	self.startNormalTag = (node, string) ->
		string += ' ' if self.LeadingWhitespaceNeeded and self.LeadingWhitespaceNeeded.tag and self.LeadingWhitespaceNeeded.tag is TYPE.TEXT
		string += '<'
		string += node.tag
		_.each node.attributes, (v, k) -> string += " #{k}=\"#{self.encodeString v.join(' ')}\""
		string += ">"
		self.LeadingWhitespaceNeeded = null
		return string


	self.start = (node) ->
		if node.type is TYPE.RAW
			return if node.start then self.startPrettyPrintIndent(node) + node.start else ''

		return '' unless node.tag
		return '' if node.tag is TYPE.TEXT
		return '' if node.tag is TYPE.COMMENT
		return '' if node.skipStart or node.skipAll

		string = self.startPrettyPrintIndent node

		if node.tag.match /\/$/
			return self.startSelfClosingTag node, string

		# self-closing HTML tag, i.e. <hr>
		else if node.tag.match /\!$/
			return self.startVoidElementTag node, string

		# normal tag
		else
			return self.startNormalTag node, string


	self.text = (node) ->
		if node.type is TYPE.RAW
			return node.text or ''

		return '' unless node.tag is TYPE.TEXT
		return '' if node.skipText or node.skipAll

		string = ''
		prevSibling = node.previousSibling()
		string += "\n" if prevSibling and prevSibling.tag is TYPE.TEXT
		string += self.encodeString node.text.join ''
		LastNodePrinted = node
		self.LeadingWhitespaceNeeded = node
		return string


	# Self-closing XML / XHTML tag, i.e <hr/>
	self.stopSelfClosingTag = (node, string) ->
		self.LeadingWhitespaceNeeded = null
		return ''


	# Void element TML tag, i.e <br>
	self.stopVoidElementTag = (node, string) ->
		self.LeadingWhitespaceNeeded = null
		return ''


	# Normal tag
	self.stopNormalTag = (node, string) ->
		string += '</'
		string += node.tag
		string += ">"
		self.LeadingWhitespaceNeeded = node
		return string


	# pretty print
	self.stopPrettyPrintIndent = (node) ->
		if node.children[0] and node.children[0].tag is TYPE.TEXT
			string = ''
		else if node.children and node.children.length is 0
			string = ''
		else
			string = "\n"
			depth = node.depth()
			while depth > 0
				string += ' '
				depth--
		return string


	self.stop = (node) ->
		if node.type is TYPE.RAW
			return if node.stop then self.stopPrettyPrintIndent(node) + node.stop else ''

		return '' unless node.tag
		return '' if node.tag is TYPE.TEXT
		return '' if node.tag is TYPE.COMMENT
		return '' if node.skipStop or node.skipAll

		# self-closing XML / XHTML tag, i.e <hr/>
		if node.tag.match /\/$/
			self.LeadingWhitespaceNeeded = null
			return ''

		# self-closing HTML tag, i.e. <hr>
		else if node.tag.match /\!$/
			self.LeadingWhitespaceNeeded = null
			return ''

		string = self.stopPrettyPrintIndent node
		return self.stopNormalTag node, string


	self.extensions = []
	self.extend = (cb) -> self.extensions.push cb 


	self.runHandles = (node, handles) ->
		return '' if handles is undefined
		return '' if handles is null
		return '' unless _.isArray handles
		return '' unless handles.length
		[ head, tail... ] = handles
		return handles[0] node tail


	self.walk = (node) ->
		res = []

		_.each self.extensions, (extend) -> extend node
		res.push self.start node
		res.push self.text node
		_.each node.children, (child) -> res.push self.walk child
		res.push self.stop node

		return res.join ''

	return self

module.exports.Create = Create