;;; package --- Script loading and interacting with Hamacs
;;; Commentary:
;;; Code:
(add-to-list 'load-path ".")
(require 'hamacs)
(let ((hint-customization
       (list "-no-user-package-db"
             "-package-env" "-"
             "-package-db" (getenv "NIX_GHC_LIBDIR"))
             ))
  (hamacs-load-package hint-customization "rectangular-shift"))

(with-temp-buffer
  (insert "hello")
  (push-mark)
  (rectangular-shift-exe)
  (cl-assert (equal (buffer-string) "     hello") t "increase indent of single line"))

(with-temp-buffer
  (insert "hello")
  (beginning-of-line)
  (push-mark)
  (insert "     ")
  (rectangular-shift-exe)
  (cl-assert (equal (buffer-string) "hello") t "decrease indent of single line"))

;;; test.el ends here
