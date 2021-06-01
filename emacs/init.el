(setq user-init-file (or load-file-name (buffer-file-name)))
(setq user-emacs-directory (file-name-directory user-init-file))
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

(require 'package)
(add-to-list 'package-archives '("tromey" . "http://tromey.com/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(setq package-user-dir (expand-file-name "elpa/" user-emacs-directory))
(package-initialize)

;; Install use-package that we require for managing all other dependencies

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package)
  (require 'use-package)
  (setq use-package-always-ensure t))

(use-package use-package-ensure-system-package
  :ensure t)

;; Look and Feel
(use-package gruvbox-theme
  :ensure t
  :demand t
  :init
    (load-theme 'gruvbox-dark-medium t)
    (set-face-attribute 'default nil :font "Menlo" :height 130)
    (global-display-line-numbers-mode)
    (setq auto-save-default nil)

    ;; backup in one place. flat, no tree structure.
    (setq backup-directory-alist '(("" . "~/.emacs.d/backup")))
    (setq backup-by-copying t))

;; Simple Enhancements
(use-package diminish
  :defer 5
  :config
  (diminish 'org-indent-mode))

(use-package magit
  :ensure t
  :config
  (global-set-key (kbd "C-x g") 'magit-status))

(use-package compile
  :init
  (progn
    (setq compilation-scroll-output t)))

(use-package projectile :ensure t)

(use-package hydra :ensure t)

(use-package which-key :ensure t :config (which-key-mode))

(use-package helm
  :ensure t
  :diminish
  :config (setq helm-use-frame-when-more-than-two-windows t)
        (setq helm-split-window-in-side-p t)
  :init (helm-mode t)
        (helm-autoresize-mode 1)
  :bind (("M-x"     . helm-M-x)
        ("C-x C-f" . helm-find-files)
        ("C-x b"   . helm-mini)     ;; See buffers & recent files; more useful.
        ("C-x r b" . helm-filtered-bookmarks)
        ("C-x C-r" . helm-recentf)  ;; Search for recently edited files
        ("C-c i"   . helm-imenu)
        ("C-h a"   . helm-apropos)
        ;; Look at what was cut recently & paste it in.
        ("M-y" . helm-show-kill-ring)

        :map helm-map
        ;; We can list ‘actions’ on the currently selected item by C-z.
        ("C-z" . helm-select-action)
        ;; Let's keep tab-completetion anyhow.
        ("TAB"   . helm-execute-persistent-action)
        ("<tab>" . helm-execute-persistent-action)))

(use-package helm-lsp
  :ensure t
  :config
  (define-key lsp-mode-map [remap xref-find-apropos] #'helm-lsp-workspace-symbol))

;; Setup for Rust

(use-package rustic
  :ensure
  :bind (:map rustic-mode-map
          ("M-j" . lsp-ui-imenu)
          ("M-?" . lsp-find-references)
          ("C-c C-c l" . flycheck-list-errors)
          ("C-c C-c a" . lsp-execute-code-action)
          ("C-c C-c r" . lsp-rename)
          ("C-c C-c q" . lsp-workspace-restart)
          ("C-c C-c Q" . lsp-workspace-shutdown)
          ("C-c C-c s" . lsp-rust-analyzer-status)
          ("C-c C-c e" . lsp-rust-analyzer-expand-macro)
          ("C-c C-c d" . dap-hydra)
          ("C-c C-c h" . lsp-ui-doc-glance))
  :hook
  (rustic-mode-hook . rk/rustic-mode-hook)
  :config
  (setq rustic-lsp-server 'rust-analyzer)
  ;; comment to disable rustfmt on save
  (setq rustic-format-on-save t)
  (defun rk/rustic-mode-hook ()
    ;; so that run C-c C-c C-r works without having to confirm
    (setq-local buffer-save-without-query t)))

;; for Cargo.toml and other config files
(use-package toml-mode :ensure)


;; for Scala
(use-package scala-mode
  :ensure t
  :interpreter
    ("scala" . scala-mode))

;; Enable sbt mode for executing sbt commands
(use-package sbt-mode
  :ensure t
  :commands sbt-start sbt-command
  :config
  ;; WORKAROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
  ;; allows using SPACE when in the minibuffer
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)
   ;; sbt-supershell kills sbt-mode:  https://github.com/hvesalai/emacs-sbt-mode/issues/152
   (setq sbt:program-options '("-Dsbt.supershell=false"))
)

(use-package lsp-metals
	:ensure t
	:hook (scala-mode . lsp))

;; for Python
(use-package lsp-python-ms
	:ensure t
	:init (setq lsp-python-ms-auto-install-server t)
	:hook (python-mode . (lambda ()
		  		(require 'lsp-python-ms)(lsp))))

;; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;; for rust-analyzer integration

(use-package lsp-mode
  :ensure
  :commands lsp
  :hook (scala-mode . company-mode)
        (lsp-mode . lsp-lens-mode)
  :bind (:map lsp-mode-map
              ("C-c C-d" . lsp-describe-thing-at-point)
              ([remap xref-find-definitions] . lsp-find-definition)
              ([remap xref-find-references] . lsp-find-references))
  :custom (progn
            (setq lsp-prefer-flymake nil)
            (setq lsp-modeline-diagnostics-scope :workspace)
            (lsp-rust-analyzer-cargo-watch-command "clippy")
            (lsp-idle-delay 0.6)
            (lsp-rust-analyzer-server-display-inlay-hints t)))

(use-package lsp-ui
  :ensure
  :commands lsp-ui-mode
  :bind (:map rustic-mode-map
          ("C-c C-c h" . lsp-ui-doc-glance))
  :custom (lsp-ui-sideline-show-diagnostics t)
          (lsp-ui-sideline-show-code-actions t)
          (lsp-ui-peek-always-show t)
          (lsp-ui-sideline-show-hover t)
	        (lsp-ui-sideline-enable t)
          (lsp-ui-doc-enable nil))

(use-package lsp-treemacs
         :after lsp-mode
         :bind (:map lsp-mode-map
                ("C-<f8>" . lsp-treemacs-errors-list)
                ("M-<f8>" . lsp-treemacs-symbols)
                ("s-<f8>" . lsp-treemacs-java-deps-list))
         :init (lsp-treemacs-sync-mode 1)
         :config
         (with-eval-after-load 'ace-window
           (when (boundp 'aw-ignored-buffers)
             (push 'lsp-treemacs-symbols-mode aw-ignored-buffers)
             (push 'lsp-treemacs-java-deps-mode aw-ignored-buffers))))

;; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;; inline errors

(use-package flycheck
  :ensure t
  :init (add-hook 'prog-mode-hook 'flycheck-mode)
  :hook (flycheck-mode . flycheck-config-fn)
  :config (progn
            (defun flycheck-config-fn()
             (flycheck-set-indication-mode 'left-margin)
            (setf left-margin-width 3)
            (set-window-buffer (selected-window) (current-buffer)))))


;; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;; auto-completion and code snippets

(use-package yasnippet
  :defer 1
  :ensure t
  :config
  (yas-reload-all)
  (add-hook 'prog-mode-hook 'yas-minor-mode)
  (add-hook 'text-mode-hook 'yas-minor-mode))

(use-package yasnippet-snippets
  :ensure t
  :after yasnippet
  :config (yasnippet-snippets-initialize))

(use-package company
  :ensure
  :defer 1
  :hook (scala-mode . company-mode)
  :bind
  (:map company-mode-map
	  ("<tab>". tab-indent-or-complete)
	  ("TAB". tab-indent-or-complete))
  (:map company-active-map
    ("C-n". company-select-next)
    ("C-p". company-select-previous)
    ("M-<". company-select-first)
    ("M->". company-select-last)))

(defun company-yasnippet-or-completion ()
  (interactive)
  (or (do-yas-expand)
      (company-complete-common)))

(defun check-expansion ()
  (save-excursion
    (if (looking-at "\\_>") t
      (backward-char 1)
      (if (looking-at "\\.") t
        (backward-char 1)
        (if (looking-at "::") t nil)))))

(defun do-yas-expand ()
  (let ((yas/fallback-behavior 'return-nil))
    (yas/expand)))

(defun tab-indent-or-complete ()
  (interactive)
  (if (minibufferp)
      (minibuffer-complete)
    (if (or (not yas/minor-mode)
            (null (do-yas-expand)))
        (if (check-expansion)
            (company-complete-common)
          (indent-for-tab-command)))))


;; ==========================================================
;; Use the Debug Adapter Protocol for running tests and debugging
(use-package posframe
  :ensure t)

(use-package dap-mode
  :ensure t
  :defer 1
  :hook
  (lsp-mode . dap-mode)
  (lsp-mode . dap-ui-mode)
  )

(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay      0.5
          treemacs-directory-name-transformer    #'identity
          treemacs-display-in-side-window        t
          treemacs-eldoc-display                 t
          treemacs-file-event-delay              5000
          treemacs-file-extension-regex          treemacs-last-period-regex-value
          treemacs-file-follow-delay             0.2
          treemacs-file-name-transformer         #'identity
          treemacs-follow-after-init             t
          treemacs-git-command-pipe              ""
          treemacs-goto-tag-strategy             'refetch-index
          treemacs-indentation                   2
          treemacs-indentation-string            " "
          treemacs-is-never-other-window         nil
          treemacs-max-git-entries               5000
          treemacs-missing-project-action        'ask
          treemacs-move-forward-on-expand        nil
          treemacs-no-png-images                 nil
          treemacs-no-delete-other-windows       t
          treemacs-project-follow-cleanup        nil
          treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                      'left
          treemacs-read-string-input             'from-child-frame
          treemacs-recenter-distance             0.1
          treemacs-recenter-after-file-follow    nil
          treemacs-recenter-after-tag-follow     nil
          treemacs-recenter-after-project-jump   'always
          treemacs-recenter-after-project-expand 'on-distance
          treemacs-show-cursor                   nil
          treemacs-show-hidden-files             t
          treemacs-silent-filewatch              nil
          treemacs-silent-refresh                nil
          treemacs-sorting                       'alphabetic-asc
          treemacs-space-between-root-nodes      t
          treemacs-tag-follow-cleanup            t
          treemacs-tag-follow-delay              1.5
          treemacs-user-mode-line-format         nil
          treemacs-user-header-line-format       nil
          treemacs-width                         35
          treemacs-workspace-switch-cleanup      nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :after (treemacs evil)
  :ensure t)

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

(use-package treemacs-icons-dired
  :after (treemacs dired)
  :ensure t
  :config (treemacs-icons-dired-mode))

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

(use-package treemacs-persp ;;treemacs-perspective if you use perspective.el vs. persp-mode
  :after (treemacs persp-mode) ;;or perspective vs. persp-mode
  :ensure t
  :config (treemacs-set-scope-type 'Perspectives))



