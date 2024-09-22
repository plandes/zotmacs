;;; package --- Summary
;;; Commentary:
;;
;; Unit tests of zotmacs-test.el
;;
;;; Code:

(require 'ert)
(require 'dash)
(require 'zotmacs)

;; use configuration that points to zotsite test database
(setenv "ZOTSITERC" "test/zotmacs-zotsite-test.conf")

(ert-deftest test-better-bibtex-fetch ()
  "Test BetterBibtex ID fetch."
  (should (= (length (zotmacs-get-better-bibtex-ids)) 4)))

(ert-deftest test-path-fetch ()
  "Test content paths fetch."
  (should (= (length (zotmacs-get-paths)) 4)))

(provide 'zotmacs-test)

;;; zotmacs-test.el ends here
