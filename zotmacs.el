;;; zotmacs.el --- Zotsite and Zotero Integration  -*- lexical-binding: t; -*-

;; Copyright (C) 2021 - 2024 Paul Landes

;; Version: 0.1
;; Author: Paul Landes
;; Maintainer: Paul Landes
;; Keywords: outlines wp
;; URL: https://github.com/plandes/zotmacs
;; Package-Requires: ((emacs "26") (dash "2.17.0") (zotxt "5.0.5"))

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Link to Zotsite and automate publishing Org Mode files.

;;; Code:

(require 'org)
(require 'browse-url)
(require 'dash)
(require 'ox-publish)
(require 'org-zotxt)

(defgroup zotmacs nil
  "Compile Helper Functions."
  :group 'zotmacs
  :prefix "zotmacs-")

(defcustom zotmacs-zotsite-url "http://example.com"
  "The deployed `zotsite' website is deployed."
  :group 'zotmacs
  :type 'string)

(defcustom zotmacs-better-bibtex-enabled t
  "Whether or not to use BetterBibtex key -> citekey link replacements."
  :group 'zotmacs
  :type 'boolean)

(defcustom zotmacs-better-bibtex-debug nil
  "Debug BetterBibtex functionality using `message`."
  :group 'zotmacs
  :type 'boolean)

(defcustom zotmacs-program (executable-find "zotsite")
  "The path to the `zotsite' Python program."
  :group 'zotmacs
  :type 'file)

(defvar zotmacs-better-bibtex-cache nil
  "The cache BetterBibtex key -> citekey values.")

(defvar zotmacs-paths-cache nil
  "The cache of item attachment document paths values.")

(defun zotmacs-invoke (action format)
  "Run ACTION using `zotmacs-program' with output FORMAT."
  (let ((zotmacs-program zotmacs-program))
    (unless zotmacs-program
      (error "Missing '%s' progam; use 'pip install zotsite'" zotmacs-program))
    (let ((cmd (list zotmacs-program action "-f" format "-k" "all")))
      (with-temp-buffer
	(unless (eq 0 (apply 'call-process (car cmd) nil (current-buffer)
			     zotmacs-better-bibtex-debug
			     (cdr cmd)))
	  (error "Could not get better bibtex IDs: %s" (buffer-string)))
	(goto-char (point-min))
	(insert "(")
	(goto-char (point-max))
	(insert ")")
	(goto-char (point-min))
	(condition-case err
	    (read (current-buffer))
	  (error (error "Can not read as lisp: %S <%s>"
			err (buffer-string))))))))

(defun zotmacs-get-better-bibtex-ids ()
  "Return all BetterBibtex key to citekey mappings.
If cached, return that, otherwise use ARGS with
`zotmacs-read-better-bibtex-ids'."
  (when zotmacs-better-bibtex-enabled
    (unless zotmacs-better-bibtex-cache
      (setq zotmacs-better-bibtex-cache
	    (->> "(\"{libraryID}_{itemKey}\" . \"{citationKey}\")"
		 (zotmacs-invoke "citekey"))))
    zotmacs-better-bibtex-cache))

(defun zotmacs-clear-better-bibtex-ids ()
  "Clear any cached BetterBibtex IDs."
  (setq zotmacs-better-bibtex-cache nil))

(defun zotmacs-get-paths ()
  "Return all BetterBibtex key to citekey mappings.
If cached, return that, otherwise use ARGS with
`zotmacs-read-paths'."
  (unless zotmacs-paths-cache
    (setq zotmacs-paths-cache
	  (->> "(\"{libraryID}_{itemKey}\" . \"{path}\")"
	       (zotmacs-invoke "docpath"))))
  zotmacs-paths-cache)

(defun zotmacs-clear-paths ()
  "Clear any cached BetterBibtex IDs."
  (setq zotmacs-paths-cache nil))

(defun zotmacs-clear ()
  "Clear all library cached data."
  (zotmacs-clear-better-bibtex-ids)
  (zotmacs-clear-paths))

(defun zotmacs-zotsite-url (lib-item-key)
  "Return a `zotsite' URL to a paper in Zotsite with key LIB-ITEM-KEY.
LIB-ITEM-KEY is a unique entry ID prefixed with the library ID such as
`1_JRTSFSSG'.  If LIB-ITEM-KEY is nil, then initialize the bibliography keys."
  (->> (zotmacs-get-better-bibtex-ids)
       (assoc lib-item-key)
       cdr
       (format "%s/site/zotero/?id=%s&isView=1" zotmacs-zotsite-url)))

(defun zotmacs-item-path (lib-item-key)
  "Return a item's document, such as a PDF, identified by LIB-ITEM-KEY."
  (->> (zotmacs-get-paths)
       (assoc lib-item-key)
       cdr))

(defun zotmacs-zotxt-path-to-item (path)
  "Convert `zotxt' PATH to an item."
  (substring path 15))

(defun zotmacs-browse-item (path)
  "Browse a Zotero website paper identified by the item PATH."
  (browse-url (zotmacs-zotsite-url (zotmacs-zotxt-path-to-item path))))

(defun zotmacs-zotero-filter-link-function (text backend info)
  "Replace links TEXT with Zotero Zotsync links.
BACKEND the backend, which is usually `twbs'.
INFO is optional information about the export process."
  (ignore backend)
  (ignore info)
  (set-text-properties 0 (length text) nil text)
  (when zotmacs-better-bibtex-debug
    (message "Remapping %s" text))
  (let ((prev-link text)
	(regex "^<a href=\"//select/items/\\(.*?\\)\">\\(.*\\)</a>\\([ ]*\\)$")
	(bb-ids (zotmacs-get-better-bibtex-ids)))
    (unless bb-ids
      (message "Warning: no better bibtex IDs found"))
    (when zotmacs-better-bibtex-debug
      (message "Recomposing link %s using %d mappings" text (length bb-ids)))
    (if (null (string-match regex text))
	(when zotmacs-better-bibtex-debug
	  (message "Link does not match: {{%s}}--skipping" text))
      (let* ((lib-item-key (match-string 1 text))
	     (link-text (match-string 2 text))
	     (some-buggy-whitesapce (match-string 3 text))
	     (lib-key (cdr (assoc lib-item-key bb-ids))))
	(unless lib-key
	  (message "Missing item key %s--skipping" lib-item-key))
	(when lib-key
	  (setq text (format "<a href=\"%s\">%s</a>%s"
			     (zotmacs-zotsite-url lib-item-key)
			     link-text
			     some-buggy-whitesapce))
	  (message "Replacing link %s -> %s" prev-link text)))
      text)))

(defun zotmacs-publish (output-directory &optional publish-fn betterbibtexp
					 includes excludes)
  "Publish an Org Mode project in to a website.

This first sets `org-publish-project-alist', and then calls
`org-publish-current-project' with FORCE set to t.

OUTPUT-DIRECTORY is the directory where the output files are generated and/or
copied.

BETTERBIBTEXP is non-nil to indicate to use BetterBibtex cite keys.

PUBLISH-FN is the function that is used for the `:publishing-function' and
defaults to `org-html-publish-to-html'.

INCLUDES is either a string (which is split on whitespace) or a list of strings
used as additional resource directories that are copied to the OUTPUT-DIRECTORY.

EXCLUDES is used in the `:exclude' property, which is a regular expression of
files, that if matches, is excluded from the list of files to copy."
  (message "Remember to close the Zotero application")
  (setq excludes (or excludes "^\\(.gitignore\\|.*\\.org\\)$"))
  (setq publish-fn (or publish-fn #'org-html-publish-to-html))
  (when (stringp includes)
    (setq includes (split-string (string-trim includes))))
  ;; set cache of item key to BetterBibtex keys if the script is available
  (let* ((bb-ids (when betterbibtexp
		   (condition-case nil
		       (zotmacs-get-better-bibtex-ids)
		     (error nil))))
	 (zotmacs-better-bibtex-enabled (if bb-ids t nil)))
    (when zotmacs-better-bibtex-debug
      (message "BetterBibtex mapping (enable=%S, link count=%d)"
	       zotmacs-better-bibtex-enabled
	       (length bb-ids))))
  (->> includes
       (-map (lambda (dir)
	       (cons dir (replace-regexp-in-string "[/\\.]" "-" dir))))
       (-map (lambda (dir-name)
	       (let ((dir (car dir-name)))
		 `(,(cdr dir-name)
		   :base-directory ,dir
		   :base-extension ".*"
		   :publishing-function org-publish-attachment
		   :publishing-directory ,(expand-file-name dir output-directory)
		   :exclude ,excludes
		   :recursive t))))
       (funcall (lambda (forms)
		  (append forms
			  `(("website" :components
			     ,(cons "orgfiles" (-map 'cl-first forms)))))))
       (append `(("orgfiles"
		  :base-directory "."
		  :base-extension "org"
		  :publishing-function ,publish-fn
		  :publishing-directory ,output-directory
		  :recursive t)))
       (setq org-publish-project-alist))
  (org-publish-current-project t))

;;;###autoload
(defun zotmacs-init ()
  "Initialize the package.
The initialization process includes configuring Org Mode to publish and
`org-zotxt' to use `zotmacs' push and attachment viewing."
  (interactive)
 ;; hook to substitute `zotero' protocols with zotsite links
 (add-hook 'org-export-filter-link-functions
	   'zotmacs-zotero-filter-link-function)

 ;; create the Org Mode export/publish and follow hooks
 (org-zotxt--define-links)

 ;; override the `org-zotxt' Org Mode follow function for opening Zotero links
 (eval (list 'defalias (quote 'org-zotxt--link-follow)
	     (quote 'zotmacs-browse-item))))

(provide 'zotmacs)

;;; zotmacs.el ends here
