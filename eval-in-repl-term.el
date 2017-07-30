;;; eval-in-repl-shell.el --- ESS-like eval for shell  -*- lexical-binding: t; -*-

;; Copyright (C) 2014-  Kazuki YOSHIDA

;; Author: Kazuki YOSHIDA <kazukiyoshida@mail.harvard.edu>
;; Keywords: tools, convenience
;; URL: https://github.com/kaz-yos/eval-in-repl
;; Version: 0.10.0

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.


;;; Commentary:

;; term-specific file for eval-in-repl
;; See below for configuration
;; https://github.com/kaz-yos/eval-in-repl/


;;; Code:

;;;
;;; Require dependencies
(require 'eval-in-repl)


;;;
;;; SHELL RELATED
;;
;;; eir-send-to-term
(defalias 'eir-send-to-term
  (apply-partially 'eir-send-to-repl
                   ;; fun-change-to-repl
                   #'(lambda () (switch-to-buffer-other-window "*terminal*"))
                   ;; fun-execute
                   #'comint-send-input)
  "Send expression to *terminal* and have it evaluated.")


;;; eir-eval-in-term
;;;###autoload
(defun eir-eval-in-term ()
  "eval-in-repl for term."
  (interactive)
  ;; Define local variables
  (let* (;; Save current point
	 (initial-point (point)))
    ;;
    (eir-repl-start "\\*terminal\\*" #'term)

    ;; Check if selection is present
    (if (and transient-mark-mode mark-active)
	;; If selected, send region
	(eir-send-to-term (buffer-substring-no-properties (point) (mark)))

      ;; If not selected, do all the following
      ;; Move to the beginning of line
      (beginning-of-line)
      ;; Set mark at current position
      (set-mark (point))
      ;; Go to the end of line
      (end-of-line)
      ;; Send region if not empty
      (if (not (equal (point) (mark)))
	  (eir-send-to-term (buffer-substring-no-properties (point) (mark)))
	;; If empty, deselect region
	(setq mark-active nil))

      ;; Move to the next statement code if jumping
      (if eir-jump-after-eval
          (eir-next-code-line)
        ;; Go back to the initial position otherwise
        (goto-char initial-point)))))


(provide 'eval-in-repl-term)
;;; eval-in-repl-shell.el ends here
