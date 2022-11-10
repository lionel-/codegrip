;;; codegrip.el --- Get a grip on your code

;; Copyright (C) 2022 Posit, PBC.

;; Author: Lionel Henry <lionel@posit.co>
;; Version: 1.3
;; Package-Requires: ((ess "18.10.3"))
;; URL: https://github.com/lionel-/codegrip/tree/main/inst/emacs

;;; Commentary:
;; Provides interactive commands for reshaping code.

(defvar codegrip--scratch-file nil)

;;;###autoload
(defun codegrip-reshape ()
  (interactive)
  (inferior-ess-r-force)
  (codegrip--update-scratch)
  (let ((cmd (format "codegrip:::emacs_reshape(%d, %d, file = '%s')\n"
                     (line-number-at-pos)
                     (1+ (current-column))
                     (codegrip--scratch-file))))
    (when (ess-boolean-command cmd)
      (let* ((out (read (codegrip--scratch-buffer-string)))
             (reshaped (car (plist-get out :reshaped)))
             (beg (codegrip--as-position (plist-get out :start)))
             (end (codegrip--as-position (plist-get out :end)))
             (point (point)))
        (kill-region beg end)
        (goto-char beg)
        (insert reshaped)
        (goto-char point)))))

(defun codegrip--update-scratch ()
  (let ((text (buffer-substring-no-properties (point-min) (point-max))))
    (with-current-buffer (codegrip--scratch-buffer)
      (delete-region (point-min) (point-max))
      (insert text)
      (basic-save-buffer)
      (kill-buffer))))

(defun codegrip--scratch-file ()
  (unless codegrip--scratch-file
    (setq codegrip--scratch-file (make-temp-file "codegrip-scratch")))
  codegrip--scratch-file)

(defun codegrip--scratch-buffer ()
  (let ((buf (find-file-noselect (codegrip--scratch-file))))
    (with-current-buffer buf
      (rename-buffer " *codegrip--scratch*"))
    buf))

(defun codegrip--scratch-buffer-string ()
  (let* ((buf (codegrip--scratch-buffer))
         (out (with-current-buffer buf
                (buffer-string))))
    (kill-buffer buf)
    out))

(defun codegrip--as-position (data)
  (save-excursion
    (codegrip--goto-line (plist-get data :line))
    (forward-char (1- (plist-get data :col)))
    (point)))

(defun codegrip--goto-line (line)
  (goto-char (point-min))
  (forward-line (1- line)))

(provide 'codegrip)
