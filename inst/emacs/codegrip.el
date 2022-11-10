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

;;;###autoload
(defun codegrip-rise ()
  (interactive)
  (codegrip--move "codegrip:::emacs_rise(%d, %d, file = '%s')\n"))

(defun codegrip--move (cmd)
  (interactive)
  (inferior-ess-r-force)
  (codegrip--update-scratch)
  (let ((cmd (format cmd
                     (line-number-at-pos)
                     (1+ (current-column))
                     (codegrip--scratch-file))))
    (when (ess-boolean-command cmd)
      (let* ((out (read (codegrip--scratch-buffer-string)))
             (pos (codegrip--as-position out)))
        (goto-char pos)))))

(defun codegrip--update-scratch ()
  (let ((buf (current-buffer)))
    (with-current-buffer (codegrip--scratch-buffer)
      (replace-buffer-contents buf)
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
