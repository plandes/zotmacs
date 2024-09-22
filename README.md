# Link to Zotsite and automate publishing Org Mode files

[![MELPA badge][melpa-badge]][melpa-link]
[![MELPA stable badge][melpa-stable-badge]][melpa-stable-link]
[![Build Status][build-badge]][build-link]

Link / browse to [Zotsite] and automate publishing [Org Mode] files.  This
package replaces [Zotero] links inserted by [zotxt-emacs].


## Install

Add the following to your `~/.emacs` initialization file:
```lisp
;; Zotero and `zotsite' cross functionality
(require 'zotmacs)

;; deployed `zotsite' website
(setq zotmacs-zotsite-url "https://example.com/path/to/exported/zotite")

;; initialize the package
(zotmacs-init)
```

The `https://example.com/path/to/exported/zotite` URL is where the [Zotsite]
website was [exported] and [deployed] (see [usage](#usage)).


## Usage

1. Use a functions such as `org-zotxt-insert-reference-link` to insert Zotero
   citations in Emacs [Org Mode] files.
1. Create the [exported] and [deployed] website.
1. Follow/open a link in [Org Mode] to open the content in a web browser.
1. Use `zotmacs-publish` to export/publish the Org Mode as a website.  The
   published website's links will redirect to [Zotsite].


## Changelog

An extensive changelog is available [here](CHANGELOG.md).


## License

Copyright (c) 2024 Paul Landes

GNU Lesser General Public License, Version 2.0


<!-- links -->
[melpa-link]: https://melpa.org/#/zotsite
[melpa-stable-link]: https://stable.melpa.org/#/zotsite
[melpa-badge]: https://melpa.org/packages/zotsite-badge.svg
[melpa-stable-badge]: https://stable.melpa.org/packages/zotsite-badge.svg
[build-badge]: https://github.com/plandes/zotsite/workflows/CI/badge.svg
[build-link]: https://github.com/plandes/zotsite/actions

[Zotero]: https://www.zotero.org
[zotxt-emacs]: https://github.com/egh/zotxt-emacs
[Zotsite]: https://github.com/plandes/zotsite
[Org Mode]: https://orgmode.org

[exported]: https://github.com/plandes/zotsite#usage)
[deployed]: https://github.com/plandes/zotsite/blob/master/src/sh/zotsync.sh
