_ = require 'underscore'
CONST = require './kissml_constants'


Create = (opts) ->
	self =
		indent: 0
		attributes: {}
		tag: CONST.NONE
		children: []
		text: []
		state: 'default'

	_.each opts, (v, k) -> self[k] = v

	self.addChild = (child) ->
		self.children or= []
		child or= Create()
		
		if child.indent < self.indent + 1
			child.indent = self.indent + 1 
		child.parent = self
		self.children.push child
		return child

	self.delChild = (child) ->
		newChildren = []
		_.each self.children, (item) ->
			return if child is item
			newChildren.push item
		self.children = newChildren
		return self

	self.promote = ->
		return self unless self.parent
		return self unless self.parent.parent
		indent = self.parent.indent
		self.parent.delChild self
		self.parent.parent.addChild self
		self.indent = indent
		return self

	self.previousSibling = ->
		return null unless self.parent
		previous = null
		for child in self.parent.children
			if previous
				if child is self
					return previous
				else
					previous = child
			else
				previous = child
		return null

	self.root = ->
		return self unless self.parent
		return self.parent.root()

	self.depth = ->
		return 0 unless self.parent
		return 1 + self.parent.depth()

	return self

module.exports.Create = Create