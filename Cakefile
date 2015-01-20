{exec} = require 'child_process'

findExecutable = (executable, callback) ->
  exec "test `which #{executable}` || echo 'Missing #{executable}'", (err, stdout, stderr) ->
    throw new Error(err) if err
    callback() if callback

build = (callback) ->
  exec 'mkdir -p lib', (err, stdout, stderr) ->
    throw new Error(err) if err
    exec "coffee --compile --output lib/ src/", (err, stdout, stderr) ->
      throw new Error(err) if err
      exec "coffee -c test/*.coffee", (err, stdout, stderr) ->
        throw new Error(err) if err
        callback() if callback
      
removeJS = (callback) ->
  exec 'rm -fr lib/', (err, stdout, stderr) ->
    exec 'rm -fr test/*.js', (err, stdout, stderr) ->
      throw new Error(err) if err
      callback() if callback

removeNodeModule = (callback) ->
  exec 'rm -fr node_modules/', ->
    exec 'rm npm-debug.log', ->
      callback() if callback

checkDependencies = (callback) ->
  findExecutable 'coffee', ->
    findExecutable 'mocha', (err, stdout) ->
      (callback or console.log) (stdout)
      
test = (callback = console.log) ->
  checkDependencies ->
    build ->
      exec "mocha", (err, stdout) ->
        callback(stdout)

publish = (callback = console.log) ->
  build ->
    findExecutable 'npm', ->
      exec 'npm publish', (err, stdout) ->
        callback(stdout)

task 'clean', 'Removing compiled JS', ->
  removeJS ->
    removeNodeModule()

task 'build', 'Build lib from src', -> build()
task 'test', 'Test project', -> test()
task 'publish', 'Publish project to npm', -> publish()
