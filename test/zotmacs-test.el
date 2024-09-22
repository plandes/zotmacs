;;; package --- Summary
;;; Commentary:
;;
;; Unit tests of zotmacs-test.el
;;
;;; Code:

(require 'ert)
(require 'dash)
(require 'zotmacs)

(ert-deftest test-load ()
  "Test successful evaluation of zotmacs."
  (should (> (length (zotmacs-get-better-bibtex-ids)) 0))
  (should (> (length (zotmacs-get-paths)) 0)))

(provide 'zotmacs-test)

;;; zotmacs-test.el ends here
