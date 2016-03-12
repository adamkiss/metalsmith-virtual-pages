# Generate pages from JSON source.

This plugin accepts a generator(s), which is an object of one or more generators in following format:

``` JSON
{ "generator-title": { "generator content" }}
```

Generator itself is an object (well, associative array) of pages to build:

``` JSON
{ "path/to/page-to-build.md" : {
    "title": "Page title",
    "moremeta": "Metadata",
    "contents": "# Headline\n\nThis is a first paragraph.",
    "specials": {
      "markdown_this_": "[Google](http://www.google.com)"
      "evaluate_this$": "self.title == 'Page title'"
      "lodash_template_this^": "${ self.title } is the title"
    }
}}
```

    module.exports = plugin

Now, the plugin function

    plugin = (options)->

Yah.