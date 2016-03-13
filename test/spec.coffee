should = require('chai').should()
equal  = require 'assert-equal-dir'
smith = require 'metalsmith'
smithInPlace = require 'metalsmith-in-place'

virtualPages = require '../src/'
virtualPagesJson = require './fixtures/source.json'

newMetalsmith = (site)->
  new smith "#{__dirname}/fixtures/#{site}"

describe 'Virtual Pages', ()->
  it 'should generate simple page correctly', (done)->
    newMetalsmith 'simple'
      .source 'src'
      .destination 'dist'
      .use virtualPages(virtualPagesJson.simple)
      .use smithInPlace 'handlebars'
      .build (err, files)->
        done(err) if err
        Object.keys(files).should.have.lengthOf(2)

        index = files['index.html']
        index.should.be.a 'object'
        index.should.contain.all.keys ['contents', 'title']

        gen   = files['simple.html']
        gen.should.be.a 'object'
        gen.should.contain.all.keys ['title', 'tags', 'author', 'contents']
        gen.tags.should.have.lengthOf(2)
        Object.keys(gen.author).should.have.lengthOf(3)

        equal 'fixtures/simple/dist', 'fixtures/simple/expected'
        do done

  it 'should generate features correctly', (done)->
    newMetalsmith 'features'
      .source 'src'
      .destination 'dist'
      .use virtualPages(virtualPagesJson.features)
      .use smithInPlace 'handlebars'
      .build (err, files)->
        done(err) if err
        Object.keys(files).should.have.lengthOf(2)

        index = files['index.html']
        index.should.be.a 'object'
        index.should.contain.all.keys ['contents', 'title']

        gen   = files['simple.html']
        gen.should.be.a 'object'
        gen.should.contain.all.keys ['title', 'tags', 'author', 'contents']
        gen.tags.should.have.lengthOf(2)
        Object.keys(gen.author).should.have.lengthOf(3)

        equal 'fixtures/simple/dist', 'fixtures/simple/expected'
        do done


  it 'should skip files with ignore: true', (done)->
    newMetalsmith 'ignore'
      .source 'src'
      .destination 'dist'
      .use virtualPages(virtualPagesJson.ignore, { keepSource: true })
      .use smithInPlace 'handlebars'
      .build (err, files)->
        done(err) if err
        Object.keys(files).should.have.lengthOf(3)

        index = files['index.html']
        index.should.be.a 'object'
        index.should.contain.all.keys ['contents', 'title']

        gen   = files['notignored.html']
        gen.should.be.a 'object'
        gen.should.contain.all.keys ['title', 'tags', 'author', 'contents']
        gen.tags.should.have.lengthOf(3)
        Object.keys(gen.author).should.have.lengthOf(3)


        equal 'fixtures/ignore/dist', 'fixtures/ignore/expected'
        do done

  it 'should generate tree of pages', (done)->
    newMetalsmith 'tree'
      .source 'src'
      .destination 'dist'
      .use smithInPlace 'handlebars'
      .use virtualPages(virtualPagesJson.tree)
      .build (err, files)->
        done(err) if err
        pages = [
          'index.html', 'grandparent.html', 'grandparent/parent.htm',
          'grandparent/parent/child.html'
        ]

        Object.keys(files).should.have.lengthOf(4)
        Object.keys(files).should.contain.all.keys pages

        pages.forEach (target)->
          files[target].should.be.a 'object'
          files[target].contents.should.be.equal files['index.html'].contents

        equal 'fixtures/tree/dist', 'fixtures/tree/expected'

        do done

  it 'should handle multiple sources', (done)->
    newMetalsmith 'multiple'
      .source 'src'
      .destination 'dist'
      .use smithInPlace 'handlebars'
      .use virtualPages({
        'simple': virtualPagesJson.simple
        'features': virtualPagesJson.features
        'ignore': virtualPagesJson.ignore
        'tree': virtualPagesJson.tree
      })
      .build (err, files)->
        done(err) if err
        pages = [
          'index.html', 'grandparent.html', 'grandparent/parent.htm',
          'grandparent/parent/child.html'
        ]

        Object.keys(files).should.have.lengthOf(4)
        Object.keys(files).should.contain.all.keys pages

        pages.forEach (target)->
          files[target].should.be.a 'object'
          files[target].contents.should.be.equal files['index.html'].contents

        equal 'fixtures/multiple/dist', 'fixtures/multiple/expected'

        do done


  # it 'is not working', ->
  #   1.should.be.equal(2)