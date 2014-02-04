{exec} = require "child_process"

task "test", "run tests", ->
  exec "mocha-phantomjs public/test.html", (err, output) ->
      throw err if err
      console.log output