chai = require 'chai'
assert = chai.assert
_ = require 'underscore'
kiss = require '../lib/kissml'

# SHOULD PRODUCE:
# <hello></hello>
# <world></world>
string = """
hello
world
"""


describe 'no root elem', ->
	result = kiss.smack string
	lines = result.split "\n"
	console.log result
	it 'first line',  -> assert.equal lines[0], '<hello></hello>'
	it 'second line', -> assert.equal lines[1], '<world></world>'