should = require('chai').should()
smith = require 'metalsmith'

virtualPages = require '../src/'
virtualPagesJson = require './fixtures/source.json'

describe 'Virtual Pages', ()->
  beforeEach ()->
    @metalsmith = new smith __dirname + '/fixtures/site'
      .source 'src'
      .destination 'dist'
      .clean false

  it 'should generate simple page correctly', (done)->
    @metalsmith
      .use virtualPages(virtualPagesJson.simple)
      .build (err, files)->
        done(err) if err
        Object.keys(files).should.have.lengthOf(2)

        index = files['index.html']
        index.should.be.a 'object'
        index.should.contain.all.keys ['contents', 'title']

        gen   = files['generated.html']
        gen.should.be.a 'object'
        gen.should.contain.all.keys ['title', 'contents']

        index.contents.should.be.equal(gen.contents)
        do done

  # it 'is not working', ->
  #   1.should.be.equal(2)