(defgroup catman nil
  "catman customizations"
  :prefix "catman-"
  :group 'applications)

(defcustom catman-clj-compile-on-save t "non-nil means clj files should be compiled after save."
  :type 'boolean
  :group 'catman)
(defcustom catman-clj-test-on-save nil "non-nil means clj test files should be executed after save."
  :type 'boolean
  :group 'catman)

(message "into catmal.el <<<<<<<<<<<<<<<<<<<<<<<<<<<<<")

(defun cider-eval-expression-at-point-in-repl ()
  (interactive)
  (let ((form (cider-sexp-at-point)))
    ;; Strip excess whitespace
    (while (string-match "\\`\s+\\|\n+\\'" form)
      (setq form (replace-match "" t t form)))
    (set-buffer (cider-find-or-create-repl-buffer))
    (goto-char (point-max))
    (insert form)
    (cider-repl-return)))

;; http://blog.jenkster.com/2013/12/popup-help-in-emacs-lisp.html
(require 'popup)
(defun describe-thing-in-popup ()
  (interactive)
  (let* ((thing (symbol-at-point))
         (help-xref-following t)
         (description (with-temp-buffer
                        (help-mode)
                        (help-xref-interned thing)
                        (buffer-string))))
    (popup-tip description
               :point (point)
               :around t
               :height 30
               :scroll-bar t
               :margin t)))
;;(help-xref-following t)

;; http://stackoverflow.com/questions/92971/how-do-i-set-the-size-of-emacs-window
(defun set-frame-size-according-to-resolution ()
  (interactive)
  (if window-system
  (progn
    ;; use 120 char wide window for largeish displays
    ;; and smaller 80 column windows for smaller displays
    ;; pick whatever numbers make sense for you
    (if (> (x-display-pixel-width) 1280)
           (add-to-list 'default-frame-alist (cons 'width 175))
           (add-to-list 'default-frame-alist (cons 'width 80)))
    ;; for the height, subtract a couple hundred pixels
    ;; from the screen height (for panels, menubars and
    ;; whatnot), then divide by the height of a char to
    ;; get the height we want
    (add-to-list 'default-frame-alist 
         (cons 'height (/ (- (x-display-pixel-height) 200)
                             (frame-char-height)))))))

(set-frame-size-according-to-resolution)

(defun catman-toggle-clj-compile-on-save ()
  (interactive)
  (setq catman-clj-compile-on-save (not catman-clj-compile-on-save))
  (message "catman-clj-compile-on-save %s" (if catman-clj-compile-on-save "enabled" "disabled")))

(defun catman-toggle-clj-test-on-save ()
  (interactive)
  (setq catman-clj-test-on-save (not catman-clj-compile-on-save))
  (message "catman-clj-test-on-save %s" (if catman-clj-test-on-save "enabled" "disabled")))

(defun catman-toggle-cider-repl-popup-stacktraces ()
  (interactive)
  (setq cider-repl-popup-stacktraces (not cider-repl-popup-stacktraces))
  (message "cider-repl-popup-stacktraces %s" (if cider-repl-popup-stacktraces "enabled" "disabled")))

;; from https://github.com/overtone/emacs-live/blob/master/packs/live/clojure-pack/config/paredit-conf.el#L19 
(defun catman-paredit-forward ()
  "Feels more natural to move to the beginning of the next item
   in the sexp, not the end of the current one."
  (interactive)
  (if (and (not (paredit-in-string-p))
           (save-excursion
             (ignore-errors
               (forward-sexp)
               (forward-sexp)
               t)))
      (progn
        (forward-sexp)
        (forward-sexp)
        (backward-sexp))
    (paredit-forward)))

;; Treat hyphens as a word character when transposing words
;; based on https://github.com/overtone/emacs-live/blob/a7951de9bad6153537f6ee8af46d18bbc2bf0166/packs/dev/clojure-pack/config/clojure-conf.el#L39
(defvar catman-clojure-mode-with-hyphens-as-word-sep-syntax-table
  (let ((st (make-syntax-table clojure-mode-syntax-table)))
    (modify-syntax-entry ?- "w" st)
    st))

(defun catman-transpose-words-with-hyphens (arg)
  "Treat hyphens as a word character when transposing words"
  (interactive "*p")
  (with-syntax-table catman-clojure-mode-with-hyphens-as-word-sep-syntax-table
    (transpose-words arg)))

(defun catman-add-clj-compile-on-save ()
 (add-hook 'after-save-hook
          (lambda nil
             (if (and catman-clj-compile-on-save
                      (symbol-value 'cider-mode)
                      (not (string-match "project.clj"
                                         (file-name-nondirectory (buffer-file-name))))
                      (not (string-match ".lein/profiles.clj"
                                         (substring (buffer-file-name) -18))))
                 (progn (message "Compiling...")
                        (cider-load-current-buffer)))
             (if (and catman-clj-test-on-save
                      (assq 'clojure-test minor-mode-alist))
                 (clojure-test-run-tests))))
 )

(defun catman-toggle-fullscreen ()
  "Toggle full screen on X11"
  (interactive)
  (when (eq window-system 'x)
    (set-frame-parameter
     nil 'fullscreen
     (when (not (frame-parameter nil 'fullscreen)) 'fullboth))))

(defun catman-nrepl-current-server-buffer ()
  (let ((nrepl-server-buf (replace-regexp-in-string "connection" "server" (nrepl-current-connection-buffer))))
    (when nrepl-server-buf
      (get-buffer nrepl-server-buf))))

(defun catman-clear-current-server-buffer ()
  "Clear current server buffer"
  (interactive)
  (with-current-buffer (catman-nrepl-current-server-buffer)
    (kill-region (point-min) (point-max))))

(defun catman-show-max§um-output-current-server-buffer ()
  "Show the Maximum output in the current server buffer."
  (interactive)
  (with-current-buffer (catman-nrepl-current-server-buffer)
    (goto-char (point-max))
    (let ((windows (get-buffer-window-list (current-buffer) nil t)))
      (while windows
        (set-window-point (car windows) (point-max))
        (setq windows (cdr windows))))))

(defun catman-cider-perspective ()
  (interactive)
  (delete-other-windows)
  (split-window-below)
  (windmove-down)
  (shrink-window 15)
  (switch-to-buffer (catman-nrepl-current-server-buffer))
  (windmove-up)
  (pop-to-buffer (cider-find-or-create-repl-buffer)))

(defun catman-run-cider-command (cmd)
  (with-current-buffer (cider-find-or-create-repl-buffer)
    (goto-char (point-max))
    (insert cmd)
    (cider-repl-return)))

(defun catman-cider-reset ()
  (interactive)
  (save-some-buffers)
  (catman-run-cider-command "(do (load \"dev\")(dev/reset))"))

(defun catman-send-expr-to-repl ()
  (interactive)
  (catman-run-cider-command (cider-expression-at-point)))

(defun catman-send-previous-expr-to-repl ()
  (interactive)
  (catman-run-cider-command (cider-last-expression)))

(defun catman-toggle-transparency ()
  (interactive)
  (let ((param (cadr (frame-parameter nil 'alpha))))
    (if (and param (/= param 100))
        (set-frame-parameter nil 'alpha '(100 100))
      (set-frame-parameter nil 'alpha '(85 50)))))

(provide 'catman)
