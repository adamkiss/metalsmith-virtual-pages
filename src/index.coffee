#
# Metalsmith: Virtual pages plugin
#
_    = require 'lodash'
path = require 'path'

module.exports = (generators, opts)->
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
    [dir, parsed.name, '/', childSlug, parsed.ext].join ''

  #
  # Path processing
  #
  processPath = (filePath, content, parent)->
    children = {}
    metadata = {}
    for key, value of content
      # if key starts with /, it's a child page
      if key[0..1] is '/'
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

    # Add to processed, process children and return
    unless metadata.ignore?
      processed = { "#{filePath}": metadata }
      for childPath, childContent of children
        _.extend(processed, processPath(childPath, childContent, metadata))
      processed
    else
      {}

  #
  # metalsmith pluggin (wrapper)
  #
  (files, ms, done)->
    for name, content of generators
      _.extend files, processPath(name, content)
    console.log Object.keys files
    done()