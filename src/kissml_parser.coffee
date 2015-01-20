_ = require 'underscore'
TreeNode = require './kissml_treenode'
TYPE = require './kissml_constants'


# if we match the end token, return it, otherwise continue
Handle_END = (current, token) ->
	if token is "END" then [current, 'END'] else [current, null]


# if we match a new line, process and return next token, otherwise continue
Handle_Newline = (current, token) ->
	return [current, null] unless token.data is "\n"
	return [current, token.next]


# if we match an indent (i.e. newline followed by space), update tree pointer
# accordingly, and return next token
Handle_Indent = (current, token) ->
	return [current, null] unless token.next
	return [current, null] unless token.data.match /^\s+$/
	return [current, null] unless token.prev.type is 'newline'
	indent = token.data.length

	# if indent is less than current indent, then we should
	# fall back to a suitable parent node.
	while indent < current.indent
		current = current.parent

	# if indent is same, make current the parent node as we'll
	# add a child next (sibling)
	if indent is current.indent
		current = current.parent

	# if not, add a child (children)
	current = current.addChild()
	current.indent = indent

	return [ current, token.next ]


Handle_TextSwitch = (current, token) ->
	return [current, null] unless token.data is ':'
	if current.tag isnt TYPE.NONE
		current = current.addChild()

	current.tag = TYPE.TEXT
	current.state = 'text'

	if current.tag is TYPE.TEXT and current.parent and current.parent.tag is TYPE.TEXT
		current = current.promote()

	return [current, token.next]


Handle_Text = (current, token) ->
	return [current, null] unless current.state is 'text'

	if token.prev.data is ':' and token.data.match /^\s+$/
		current.text.push token.data.substr 1
		return [current, token.next]

	if current.parent and current.parent.tag is TYPE.NONE and current.text.length is 0
		current.text.push " "

	current.text.push token.data
	return [current, token.next]


Handle_CommentSwitch = (current, token) ->
	return [current, null] unless token.data is '#'
	current.state = 'comment'
	return [current, token.next]


Handle_Comment = (current, token) ->
	return [current, null] unless current.state is 'comment'
	return [current, token.next]


Handle_ID = (current, token) ->
	return [current, null] unless token.data.match /^\#(?!\#)/
	current.attributes.id = [ token.data.replace /^\#/, '' ]
	return [current, token.next]


Handle_Class = (current, token) ->
	return [current, null] unless token.data.match /^\.(?!\.)/
	current.attributes.class or= []
	current.attributes.class.push token.data.replace /^\./, ''
	return [current, token.next]


Handle_Href = (current, token) ->
	return [current, null] unless token.data.match /^\@(?!\@)/
	current.attributes.href = [ token.data.replace /^\@/, '' ]
	return [current, token.next]


Handle_AttributeName = (current, token) ->
	return [current, null] unless token.data.match /^\+(?!\+)/
	unless current.tag
		child = current
		current = current.parent
		current.delChild child
	token.data = token.data.replace /^\+/, ''
	token.type = 'attribute_name'
	current.state = 'attribute'
	current.attributeName = token.data
	current.attributes[current.attributeName] = []
	return [current, token.next]


Handle_Space = (current, token) ->
	return [current, null] unless token.data.match /^\s+$/
	return [current, token.next]


Handle_AttributeValue = (current, token) ->
	return [current, null] unless current.state is 'attribute'
	current.attributes[current.attributeName].push token.data
	return [current, token.next]


Handle_Tag = (current, token) ->
	if current.tag
		current = current.addChild()
	current.tag = token.data
	current.token = token

	if current.tag.match /\:$/
		current.tag = current.tag.replace /\:$/, ''
		current = current.addChild()
		current.tag = TYPE.TEXT
		current.state = 'text'
		if token.next and token.next.type is 'space'
			token = token.next

	return [current, token.next]


Create = ->
	self = {}
	self.handlers = []

	self.organize = (token, current) ->
		current or= TreeNode.Create()
		while token and token isnt 'END'
			for handler in self.handlers
				[newCurrent, newToken] = handler.func current, token
				if newToken
					current = newCurrent
					token = newToken
					break
		return current.root()


	self.extend = (opts) ->
		if opts.after
			newHandlerList = []
			_.each self.handlers, (item) ->
				newHandlerList.push item
				if item.name is opts.after
					newHandlerList.push opts
			self.handlers = newHandlerList
		else
			self.handlers.push opts


	self.extend name: 'Handle_END', func: Handle_END
	self.extend name: 'Handle_Newline', func: Handle_Newline
	self.extend name: 'Handle_Indent', func: Handle_Indent
	self.extend name: 'Handle_TextSwitch', func: Handle_TextSwitch
	self.extend name: 'Handle_Text', func: Handle_Text
	self.extend name: 'Handle_CommentSwitch', func: Handle_CommentSwitch
	self.extend name: 'Handle_Comment', func: Handle_Comment
	self.extend name: 'Handle_ID', func: Handle_ID
	self.extend name: 'Handle_Class', func: Handle_Class
	self.extend name: 'Handle_Href', func: Handle_Href
	self.extend name: 'Handle_AttributeName', func: Handle_AttributeName
	self.extend name: 'Handle_Space', func: Handle_Space
	self.extend name: 'Handle_AttributeValue', func: Handle_AttributeValue
	self.extend name: 'Handle_Tag', func: Handle_Tag

	return self

module.exports.Create = Create