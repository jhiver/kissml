chai = require 'chai'
assert = chai.assert
TreeNode = require '../lib/kissml_treenode'
_ = require 'underscore'

describe 'root node', ->
	tree = TreeNode.Create()
	it 'indent is 0', -> assert.equal 0, tree.indent
	it 'attributes exists', ->
		assert.ok tree.attributes
		assert.equal typeof(tree.attributes), 'object'
	it 'attributes empty', -> assert.ok _.isEmpty tree.attributes

describe 'addChild()', ->
	tree = TreeNode.Create()
	child = tree.addChild()
	it 'has parent', -> assert.ok child.parent
	it 'parent is root', -> assert.equal child.parent, tree

describe 'delChild()', ->
	tree = TreeNode.Create()
	child = tree.children[0]
	tree.delChild child
	it 'has no children', -> assert.equal tree.children.length, 0

describe 'promote()', ->
	tree = TreeNode.Create()
	grandChild = tree.addChild().addChild()
	grandChild.promote()
	it 'has two children', -> assert.equal tree.children.length, 2

describe 'previousSibling()', ->
	tree = TreeNode.Create()
	child1 = tree.addChild()		
	child2 = tree.addChild()		
	it 'works', -> assert.equal child2.previousSibling(), child1

describe 'root()', ->
	tree = TreeNode.Create()
	descendant = tree.addChild().addChild().addChild().addChild().addChild().addChild().addChild()
	it 'works', -> assert.equal descendant.root(), tree

describe 'depth()', ->
	tree = TreeNode.Create()
	descendant = tree.addChild().addChild()
	it 'is zero for root', -> assert.equal tree.depth(), 0
	it 'is positive for a descendant', -> assert.ok descendant.depth() > 0