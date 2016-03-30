#
# Metalsmith: Virtual pages plugin
#
_    = require 'lodash'
path = require 'path'
fs   = require 'fs'

module.exports = (generator, opts)->
  defaults = {
    keepSources: false
    markdown: {
      html: true
      breaks: true
      linkify: true
      typographer: true
    }
  }
  options = if opts? then _.extend(defaults, opts) else defaults
  sourceFiles = []

  #
  # Setup / plugins
  #
  markdownOptions = options.markdown

  markdown = require('markdown-it')(markdownOptions)
    .use(require('markdown-it-footnote'))

  evaluate = (expression, s, p)->
    'use strict'
    eval expression

  #
  # Helpers
  #
  childPath = (filePath, childSlug)->
    parsed = path.parse filePath
    dir = if parsed.dir then parsed.dir+'/' else ''
    if parsed.name.indexOf('.') isnt -1
      name = parsed.name.substr 0, parsed.name.indexOf '.'
    else
      name = parsed.name
    [dir, name, '/', childSlug].join ''

  sourceExists = (filePath, rootPath)->
    try
      (fs.statSync path.join rootPath, filePath)?
    catch error
      false

  #
  # Path processing
  #
  processPath = (rootPath, files, filePath, content, parent)->
    children = {}
    metadata = {}
    for key, value of content
      # if key starts with /, it's a child page
      if key[0] is '/'
        children[childPath filePath, key[1..]] = value
      else
        # While last letter is control character (= multipass)
        while key[-1..] in ['_', '$', '?']
          switch key[-1..] # Last letter might be a control char
            when '_' then value = markdown.render value
            when '$'
              tpl = _.template value
              value = tpl {s: metadata, p: parent}
            when '?'
              value = evaluate value, metadata, parent
          key = key[0..-2]
        metadata[key] = value

        # get contents;
        if key is 'contents'
          # is contents a file in metalsmith files?
          if files[value]?
            sourceFiles.push(value) if sourceFiles.indexOf(value) is -1
            metadata[key] = files[value].contents
          # is contents an existing file in ms root?
          else if sourceExists(value, rootPath)
            metadata[key] = fs.readFileSync path.join rootPath, value
          # just buffer it
          else
            metadata[key] = new Buffer value

    # Add to processed, process children and return
    unless metadata.ignore?
      processed = { "#{filePath}": metadata }
      for childFilePath, childContent of children
        _.extend(processed, processPath(rootPath, files, childFilePath, childContent, metadata))
      processed
    else
      {}

  #
  # metalsmith pluggin (wrapper)
  #
  (files, ms, done)->
    # if multple generators, merge them into one
    if _(generator).isArray()
      generator.unshift {}
      generator = _.merge.apply(_, generator)

    # let's go
    for name, content of generator
      _.extend(
        files,
        processPath(ms._directory, files, name, content)
      )

    # cleanup
    unless options.keepSources
      delete files[sourceFile] for sourceFile in sourceFiles

    # done
    done()