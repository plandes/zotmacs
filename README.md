# Link to Zotsite and automate publishing Org Mode files

[![MELPA badge][melpa-badge]][melpa-link]
[![MELPA stable badge][melpa-stable-badge]][melpa-stable-link]
[![Build Status][build-badge]][build-link]

Link / browse to [Zotsite] and automate publishing Org Mode files.


## Usage

Add the following to your `~/.emacs` initialization file:
```lisp
;; Zotero and `zotsite' cross functionality
(require 'zotmacs)

;; deployed `zotsite' website
(setq zotmacs-zotsite-url "https://example.com/path/to/exported/zotite")

;; initialize the package
(zotmacs-init)
```


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

[Zotsite]: https://github.com/plandes/zotsite
