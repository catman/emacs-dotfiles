;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; cider tweaks
;(require 'nrepl-eval-sexp-fu)
;(require 'nrepl-inspect)
(require 'slamhound)

(setq cider-javadoc-local-paths (list "/usr/local/share/javadoc-w3m/7/docs/api")
      cider-repl-history-file (concat user-emacs-directory ".cider-history")
      cider-popup-stacktraces t
      cider-repl-popup-stacktrace nil)
(setq-default cider-port "4001")

;; (add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)
;; (setq nrepl-hide-special-buffers t)
;; (setq cider-repl-tab-command 'indent-for-tab-command)
;; (setq cider-repl-pop-to-buffer-on-connect nil)
;; (setq cider-popup-stacktraces nil)
;; (setq cider-auto-select-error-buffer t)
;; (setq nrepl-buffer-name-separator "-")
;; (setq nrepl-buffer-name-show-port t)
;; (setq cider-repl-display-in-current-window t)
;; (setq cider-repl-print-length 100) ; the default is nil, no limit
;; (setq cider-repl-wrap-history t)
;; (setq cider-repl-history-size 1000) ; the default is 500
;; (setq cider-repl-history-file "path/to/file")
;; (add-hook 'cider-repl-mode-hook 'subword-mode)
;; (add-hook 'cider-repl-mode-hook 'paredit-mode)
;; (add-hook 'cider-repl-mode-hook 'smartparens-strict-mode)
;; (add-hook 'cider-repl-mode-hook 'rainbow-delimiters-mode)

(add-to-list 'same-window-buffer-names "*cider*")

(defun ensure-yasnippet-is-first-ac-source ()
  (when (memq 'ac-source-yasnippet ac-sources)
    (setq ac-sources
          (cons 'ac-source-yasnippet
                (remove 'ac-source-yasnippet ac-sources)))))
(add-hook 'cider-mode-hook 'ac-nrepl-setup)
(add-hook 'cider-mode-hook 'ensure-yasnippet-is-first-ac-source)
(add-hook 'cider-repl-mode-hook 'ac-nrepl-setup)
(add-hook 'cider-repl-mode-hook 'ensure-yasnippet-is-first-ac-source)
(add-hook 'cider-mode-hook
          (lambda nil
            (define-key  cider-mode-map (kbd "C-c C-d") 'ac-nrepl-popup-doc)
            (define-key cider-mode-map (kbd "C-c C-c") 'sw1nn-send-expr-to-repl)
            (define-key cider-mode-map (kbd "C-c C-e") 'sw1nn-send-previous-expr-to-repl)
            (cider-turn-on-eldoc-mode)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
