;;; myrddin-mode.el --- Major mode for editing Myrddin source files -*- lexical-binding: t; -*-

;; Copyright (C) 2019 Jakob L. Kreuze

;; Author: Jakob L. Kreuze <zerodaysfordays@sdf.lonestar.org>
;; Version: 0.1
;; Keywords: faces files languages myrddin
;; URL: https://git.sr.ht/~jakob/myrddin-mode

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; myrddin-mode provides support for editing Myrddin, including automatic
;; indentation and syntactical font-locking.

;;; Code:

(defgroup myrddin-mode nil
  "Support for Myrddin code."
  :link '(url-link "https://git.sr.ht/~jakob/myrddin-mode")
  :group 'languages)

(defcustom myrddin-indent-offset 8
  "Indent Myrddin code by this number of spaces."
  :type 'integer
  :group 'myrddin-mode
  :safe #'integerp)


;;;
;;; Syntax tables.
;;;

(defvar myrddin-mode-syntax-table
  (let ((table (make-syntax-table)))
    ;; Operators.
    (dolist (i '(?+ ?- ?* ?/ ?% ?& ?| ?^ ?! ?< ?> ?~ ?@))
      (modify-syntax-entry i "." table))

    ;; Strings.
    (modify-syntax-entry ?\" "\"" table)
    (modify-syntax-entry ?\\ "\\" table)

    ;; Angle brackets.
    (modify-syntax-entry ?< "(>" table)
    (modify-syntax-entry ?> ")<" table)

    ;; Comments.
    (modify-syntax-entry ?/  ". 124b" table)
    (modify-syntax-entry ?*  ". 23n"  table)
    (modify-syntax-entry ?\n "> b"    table)
    (modify-syntax-entry ?\^m "> b"   table)

    table))


;;;
;;; Font locking.
;;;

(defvar myrddin-mode-keywords
  '("$noret"
    "break"
    "const" "continue"
    "elif" "else" "extern"
    "for"
    "generic" "goto"
    "if" "impl" "in"
    "match"
    "pkg" "pkglocal"
    "sizeof" "struct"
    "trait" "type"
    "union"
    "use"
    "var"
    "while"))

(defvar myrddin-mode-constants
  '("true" "false" "void"))

(defvar myrddin-mode-special-types
  '("void" "bool" "char" "byte"
    "int8" "uint8"
    "int16" "uint16"
    "int32" "uint32"
    "int64" "uint64"
    "int" "uint"
    "flt32" "flt64"))

(defconst myrddin-mode-identifier-rx
  '(and (or alpha ?_)
        (one-or-more (or alnum ?_))))

(defconst myrddin-mode-type-name-rx
  '(and
    (eval myrddin-mode-identifier-rx)
    (optional (or (and ?[ (zero-or-more any) ?])
                  ?#))))

(defconst myrddin-mode-variable-declaration-regexp
  (rx
   (and (or "const" "var" "generic")
        (zero-or-more (or "extern" "pkglocal" "#noret"))
        (and (one-or-more whitespace)
             (group
              symbol-start
              (eval myrddin-mode-identifier-rx)
              symbol-end)))))

(defconst myrddin-mode-type-specification-regexp
  (rx
   (and (or ?: "->")
        (zero-or-more whitespace)
        (group (eval myrddin-mode-type-name-rx)))))

(defconst myrddin-mode-label-regexp
  (rx (and ?: (eval myrddin-mode-identifier-rx) symbol-end)))

(defvar myrddin-mode-font-lock-keywords
  `((,(regexp-opt myrddin-mode-keywords 'symbols) . font-lock-keyword-face)
    (,(regexp-opt myrddin-mode-constants 'symbols) . font-lock-constant-face)
    (,myrddin-mode-label-regexp . font-lock-constant-face)
    (,myrddin-mode-type-specification-regexp 1 font-lock-type-face)
    (,myrddin-mode-variable-declaration-regexp 1 font-lock-variable-name-face)))


;;;
;;; Mode declaration.
;;;

;;;###autoload
(define-derived-mode myrddin-mode prog-mode "Myrdin"
  "Major mode for Myrddin code."
  :group 'myrddin-mode
  :syntax-table myrddin-mode-syntax-table
  (setq-local font-lock-defaults '(myrddin-mode-font-lock-keywords
                                   nil nil nil nil))

  (setq comment-start "/*")
  (setq comment-end "*/"))

(provide 'myrddin-mode)
;;; myrddin-mode.el ends here
