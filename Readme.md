# Virtual Pages plugin for Metalsmith

This is a plugin for [Metalsmith][] that takes a JSON input a generates pages from its contents. It's useful if you have a set of pages you'd like to create/edit at single place (e.g. YAML file), but generate separate pages.

Unlike [metalsmith-json-to-files][], it works with a variable, not a file path, which is useful if the JSON data come from elsewhere, or were loaded from other format and transformed before running Metalsmith.

[metalsmith]: http://metalsmith.io
[metalsmith-json-to-files]: https://www.npmjs.com/package/metalsmith-json-to-files

##  Usage

This plugin is meant to be used with the API version — possibly works with CLI, but that wasn't tested yet (one of the reasons why it's `0.*` version). Just add it to the metalsmith pipeline, as soon as possible — so the rest of your plugins can work over the generated virtual pages as well.

```js
var virtualPages = require('metalsmith-virtual-pages');
var vpSource = require('virtual-pages-source.json');

require('metalsmith')(__dirname)
  .use(virtualPages(vpSource, opts))
  // …
  .build();
```

## Data format

The first argument is an associative array consisting of `path: {metadata/content/options}` pairs:

``` json
{ "path/to/page-to-build.md" : {
    "title": "Page title",
    "moremeta": "Metadata",
    "contents": "# Headline\n\nThis is a first paragraph.",
    "specials": {
        "markdown_this_": "[Google](http://www.google.com)",
        "evaluate_this?": "s.title == 'Page title'",
        "lodash_template_this$": "${s.title} is the title",
        "chain_$": "# ${s.title}"
    },
    "/child-of-this-page.md" : {
        "title": "Child of Page Title",
        "contents": "use-as-source.html",
        "ignore": "true"
    }
}}
```

## Control characters and special keys

* If the key ends with one of the following characters: `_`, `?` or `$`, it will be processed before passing on:
  * `_` will be processed with `markdown-it`
  * `?` will be evaluated as JS code.
  * `$` will be parsed as a [Lodash template](https://lodash.com/docs#template)
* If the key starts with forwards slash `/something`, it will add a child to previous page. This child has access to parent's data (mentioned in previous bullet points)
* `contents` is a special key: Its contents are passed to metalsmith as a content, not metadata. What the content might be is decided in following order:
  a. a path in `files` (the file contents is copied and removed from `files`)
  b. a path relative to metalsmith root directory: the file is loaded.
  c. neither: value of the `contents` key is transformed to `Buffer` and passed on
* `ignore` is another special key. If it's there, and is set to true, this file (and all of its possible descendats will be skipped)

Both evaluation (`?`) and Lodash templates (`$`) have access to following:
* `s.*` — self, loaded up until this point
* `p.*` — parent, if applicable (e.g. for child pages)
* [Lodash](https://lodash.com) as `_`

All control characters are stackable, so you can first interpolate and then run markdown over it — like in the example. The `specials.chain` will be first given the `title` and then `markdown`-ed, so its value will be:

``` html
<h1>Page title</h1>
```

## Options

Options is optional second argument. Any object given will merged with defaults:

``` coffeescript
defaults = {
  keepSources: false # keep sources used as base for virtual pages
  markdown: {        # markdown-it settings
    html: true
    breaks: true
    linkify: true
    typographer: true
  }
}
```

Additionally, `markdown-it` has the `markdown-it-footnote` plugin enabled.

`options.keepSources`: Default setting is `false`, which means that any file used for `contents` of any virtual page will be removed from `files` after all virtual pages have been generated. If you wish to keep the original file as well, set it to `true`.

## Limitations

- it's synchronous
- at any given time, the only metadata known to evaluated and templated fields are the data above it. It's parsed as it goes, with the order that is set in json

## License

ISC

## Author
[Adam Kiss](http://adamkiss.com)

## Changelog

### v0.3.0
- Added a readme. This is such a big accomplishment, there's a new minor version for it.

### v0.2.0
- it works for a single object.