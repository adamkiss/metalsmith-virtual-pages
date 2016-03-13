#
# Metalsmith: Virtual pages plugin
#
_    = require 'lodash'
path = require 'path'

module.exports = (options)->
  #
  # Setup / plugins
  #
  markdownOptions = _.extend {
    html: true
    breaks: true
    linkify: true
    typographer: true
  }, options.markdown

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
    [dir, parsed.name, '/', childSlug, parsed.ext].join ''

  #
  # Path processing
  #
  processPath = (filePath, content, parent)->
    children = {}
    metadata = {}
    for key, value of content
      switch key[-1..] # Last letter might be a control char
        when '/'
          children[childPath filePath, key[0..-2]] = value
        when '_'
          metadata[key[0..-2]] = markdown value
        when '$'
          tpl = _.template value
          metadata[key[0..-2]] = tpl {s: metadata, p: parent}
        when '?'
          metadata[key[0..-2]] = evaluate value, metadata, parent
        else metadata[key] = value

    processed = { "#{filePath}": metadata }

    for childPath, childContent of children
      _.extend(processed, processPath(childPath, childContent, metadata))

    processed

  #
  # metalsmith pluggin (wrapper)
  #
  (files, ms, done)->
    for name, content of options
      _.extend files, processPath(name, content)
    console.log files
    done()