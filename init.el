;; Make all commands of the “package” module present.
(require 'package)
;; Internet repositories for new packages.
(setq package-archives '(("gnu"       . "http://elpa.gnu.org/packages/")
                         ("melpa"     . "http://melpa.org/packages/")))
;; Actually get “package” to work.
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
;;always ensure packages
(setq use-package-always-ensure t)

;; emacs package basic customization
(use-package emacs
  :init
  ;;basic modes
  (column-number-mode t)
  (electric-pair-mode t)
  (show-paren-mode t)
  (desktop-save-mode t)
  (save-place-mode t)
  (cua-mode t)
  (transient-mark-mode t)
  (ido-mode -1) ;;ido mode enables a better minibuffer now using helm
  ;; disable rings and startup message
  (setq inhibit-startup-message t)
  (setq ring-bell-function 'ignore)
  ;; UTF-8 encoding
  (prefer-coding-system 'utf-8)
  (set-default-coding-systems 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  ;; manage backups
  (defvar --backup-directory (concat user-emacs-directory "backups"))
  (if (not (file-exists-p --backup-directory))
      (make-directory --backup-directory t))
  (setq backup-directory-alist `(("." . ,--backup-directory)))
  (setq make-backup-files t
	backup-by-copying t   ; don't clobber symlinks
        version-control t     ; use versioned backups
        delete-old-versions t
        kept-new-versions 2
        kept-old-versions 2
	)
  (setq create-lockfiles nil)		; files with # problem with onedrive...
  (defalias 'yes-or-no-p 'y-or-n-p) ;just answer y or n
  ;;emacs bulit-in autocompletion (used by company backends!!)
  (setq-default   completions-detailed t ;; better autocompletition
		  completion-ignore-case t ;; ignore or not capital letters for company-capf (causes wrong completition sorting)
		  )
  (setq   visible-bell t
	  kill-buffer-query-functions nil ;; dont ask when closing buffer
	  )
  ;; performance with all-the-icons
  (setq inhibit-compacting-font-caches t)
  ;;cua mode settings
  (setq cua-keep-region-after-copy t)
  ;;others
  (setq process-connection-type nil) ;;xdg-open for latex in org mode
  ;;mouse-wheel speed
  (setq mouse-wheel-scroll-amount '(3 ((shift) . 1) ((control) . nil)))
  ;; c++ configuration
  (defun my-c-mode-common-hook ()
    (c-set-offset 'substatement-open 0)
    (setq c++-tab-always-indent t)
    (setq c-basic-offset 4)                  ;; Default is 2
    (setq c-indent-level 4)                  ;; Default is 2
    (setq tab-stop-list '(4 8 12 16 20 24 28 32 36 40 44 48 52 56 60))
    (setq tab-width 4)
    (setq indent-tabs-mode nil)) ;;indent with spaces rather than tabs!
  (add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

  :hook ;;to avoid global modes, better work only on prog modes!
  (prog-mode . hl-line-mode)
  (prog-mode . linum-mode)
  (LaTeX-mode . linum-mode)
  (LaTeX-mode . hl-line-mode)
  )

;;Dimisih
(use-package diminish
  :demand)

(use-package spacemacs-theme
  :defer t
  :init
  (load-theme 'spacemacs-dark t)
  :config
  (setq spacemacs-theme-comment-italic t))

;;Basic: set up C++ environment
;;(setq gc-cons-threshold (* 100 1024 1024))
;;(setq read-process-output-max (* 1024 1024)) ;; 1mb

;;out loved eglot
(use-package eglot
  :hook
  (c++-mode . eglot-ensure)
  ;(eglot-managed-mode . (lambda ()
;			  (flymake-mode -1)));;disable flymake on elgot to avoid string_view error on ROOT
  :config
  (setq eglot-ignored-server-capabilites '(:documentHighlightProvider :codeLensProvider)
	eglot-autoshutdown t);;turn off highlight and lens; also enable shutdown
  (setq eglot-stay-out-of '(company)) ;; to avoid eglot overriding company backends
  )

;;Which-key
(use-package which-key
  :diminish
  :config
  (which-key-mode))

;;for helm
(use-package helm
  :init (require 'helm-config)
  :bind (("M-x" . helm-M-x)
         ("C-x C-f" . helm-find-files)
         ("C-x b" . helm-buffers-list)
         ("C-c h o" . helm-occur)
	 ("C-c h g" . helm-google-suggest)
	 ("C-c h i" . helm-semantic-or-imenu)
	 ("M-y" . helm-show-kill-ring) 
	 ("C-x r b" . helm-filtered-bookmarks))
  :config
  (helm-autoresize-mode t)
  (setq helm-autoresize-max-height 30
	helm-semantic-fuzzy-match t
	helm-imenu-fuzzy-match    t
	;; helm-completion-style 'emacs
	helm-ff-file-name-history-use-recentf t)
  (helm-mode 1)
  )

;;Dabbrev
(use-package dabbrev
  :diminish abbrev-mode
  :config
  ;; don't change case
  (setq dabbrev-case-replace nil))

;;company-mode: autocompletion
(use-package company
  :bind
  (("C-c c f" . company-files))
  :config
  (setq company-backends '((company-files company-capf company-yasnippet
					  :with company-dabbrev-code)))
  (setq company-idle-delay 0
  	company-require-match nil
	company-selection-wrap-around t
	company-tooltip-align-annotations t
	company-dabbrev-downcase nil
	company-minimum-prefix-length 3
	company-dabbrev-minimum-length 4 ;; we still get the floating point issue, but it's a bug
	company-insertion-on-trigger nil)
  (setq company-transformers '(delete-consecutive-dups
  			       company-sort-by-backend-importance))
  (setq company-files-chop-trailing-slash nil)
  :hook
  (prog-mode . company-mode)
  (LaTeX-mode . company-mode))

;; company prescient: for automatic sorting of suggestions in company
(use-package company-prescient
  :after company
  :config
  (company-prescient-mode 1)
  (prescient-persist-mode -1) ;; do not save completition list
  (setq prescient-sort-full-matches-first nil
	    company-prescient-sort-length-enable t) ;; disabling it causes wrong first candidate
)

(use-package company-statistics
  :disabled
  :after company
  :config
  (company-statistics-mode)
)

;;vterm: the best terminal emulator
(use-package vterm)

;; eldoc: preview templates for functions in minibuffer
(use-package eldoc
  :diminish eldoc-mode
  :config
  (setq eldoc-echo-area-use-multiline-p nil))

;; yasnippet: displaying useful completitions
(use-package yasnippet
  :diminish yas-minor-mode
  :hook
  (prog-mode . yas-minor-mode)
  (LaTeX-mode . yas-minor-mode)
  (c++-mode . yas-minor-mode)
  (org-mode . yas-minor-mode)
  :config
  (yas-reload-all)
  )


;; sml: smart modeline
(use-package smart-mode-line
  :disabled
  :init
  (setq sml/theme 'dark
	sml/no-confirm-load-theme t)
  :config
  (sml/setup))
  
;; autorevert mode
(use-package autorevert
  :defer 1
  :config
  (setq auto-revert-interval 5)
  (setq auto-revert-check-vc-info t)
  (setq global-auto-revert-non-file-buffers t)
  (setq auto-revert-verbose nil)
  (global-auto-revert-mode +1))
  
;; treemacs
(use-package treemacs
  :disabled)

;;all the icons
(use-package all-the-icons
  :if (display-graphic-p))

;;cat in modeline
(use-package nyan-mode
  :disabled
  :config
  (nyan-mode))

;;alternative to helm: ivy-counsel-swiper; disabled by now
(use-package counsel
  :disabled
  :after ivy
  :config (counsel-mode))

(use-package ivy
  :disabled
  :defer 0.1
  :diminish
  :bind (("C-c C-r" . ivy-resume)
         ("C-x B" . ivy-switch-buffer-other-window))
  :custom
  (ivy-count-format "(%d/%d) ")
  (ivy-use-virtual-buffers t)
  :config (ivy-mode))

(use-package ivy-rich
  :disabled
  :after ivy
  :custom
  (ivy-virtual-abbreviate 'full
                          ivy-rich-switch-buffer-align-virtual-buffer t
                          ivy-rich-path-style 'abbrev)
  :config
  (ivy-set-display-transformer 'ivy-switch-buffer
                               'ivy-rich-switch-buffer-transformer))

(use-package swiper
  :disabled
  :after ivy
  :bind (("C-s" . swiper)
         ("C-r" . swiper)))

(use-package cmake-mode)

(use-package doom-modeline
  :init
  (doom-modeline-mode 1)
  :config
  (setq doom-modeline-buffer-encoding nil))

(use-package projectile
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("s-p" . projectile-command-map)
              ("C-c p" . projectile-command-map)))

;;save custom variables set by emacs in separete file
;; so they dont contaminate this file
(setq custom-file (concat user-emacs-directory "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))
