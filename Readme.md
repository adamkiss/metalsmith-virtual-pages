# Metalsmith-virtual-pages

Generates pages from page tree defined inside JSON.

## How to use

## JSON source format

This plugin accepts JSON (in a string, so the source doesn't matter) — generator(s) — which is an object of one or more generators in following format:

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
