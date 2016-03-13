smith = require 'metalsmith'

virtualPages = require './src/'
virtualPagesJson = require './test/fixtures/source.json'

Metasmith = new smith __dirname + '/test/fixtures/site'
  .source 'src'
  .destination 'dist'
  .clean false
  .use virtualPages(virtualPagesJson.simple)
  .build (err, files)->
    throw err if err