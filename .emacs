;;; emacs-config --- My emacs config
;;; Commentary:
;;; Code:

(defun config-main ()
  (generic-decls)
  (modes-setup)
  )

(defun generic-decls ()
  "generic declarations for all modes"
  (defvar package-list '(evil
                         flycheck
                         haskell-mode
                         color-theme
                         linum-relative
                         evil-leader))

  (package-config)

  (load "~/.emacs.d/desert-theme/desert-theme.el")
  (defvar skippable-buffers '("*Messages*" "*scratch*" "*Help*"))
  (evil-config)
  (hl-line-setup)
  (linum-config)
  (menu-bar-mode -1)
  (when window-system (scroll-bar-mode -1))
  (tool-bar-mode -1)
  (blink-cursor-mode 0)
  (longlines-mode)
  (paren-config)
  (setq inhibit-startup-message t)
  (setq tab-always-indent 'initials)
  (setq make-backup-files nil)
  (kbd-config)
  )

(defun max-line-number-width ()
  (length (number-to-string (count-lines (point-min) (point-max))))
  )

(defun linum-config ()
  (global-linum-mode)
  (require 'linum-relative)
  (add-hook 'linum-before-numbering-hook
            (lambda ()
              (defvar linum-format)
              (setq linum-format (concat "%"
                                         (number-to-string (max-line-number-width))
                                         "d "))
              )
            )
  )

(defun kbd-config ()
  "defines my own keybindings"
  (evil-leader/set-leader "`")
  ;; Buffer navigation
  (evil-leader/set-key
    "j" 'my-previous-buffer
    "k" 'my-next-buffer
    "q" 'kill-this-buffer
    )
  )

(defun paren-config ()
  "show-paren-mode and smartparens-mode config"
  (show-paren-mode 1)
  (defvar show-paren-delay 0)
  )

(defun package-config ()
  "initialize 'package' and install missing plugins"
  (defvar package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                             ("marmalade" .
                              "http://marmalade-repo.org/packages/")
                             ("melpa" .
                              "http://melpa.milkbox.net/packages/")))
  (require 'package)
  (package-initialize)
  (install-missing-packages)
  )

(defun flycheck-config ()
  "flychek settings"
  (flycheck-mode)
  )

(defun evil-config ()
  "evil settings"
  (defvar evil-want-C-u-scroll t)

  (require 'evil-leader)
  (global-evil-leader-mode 1) ; WARNING: Should appear before (require 'evil)
  (require 'evil)
  (evil-mode 1)
  (evil-auto-save)
  )

(defun evil-auto-save ()
  "save buffer after insert"
  (defvar my-current-state (evil-insert-state-p))
  (add-hook 'post-command-hook
            '(lambda ()
               (when (and
                      ;; state toggled
                      my-current-state (evil-normal-state-p)
                      ;; not unnamed buffer
                      (buffer-name)
                      ;; not special buffer
                      (not (string-match "^\*.*\*$" (buffer-name)))
                      )
                 (save-buffer)
                 )
               (setq my-current-state (evil-insert-state-p))
               )
            )
  )

(defun install-missing-packages ()
  "installs missing packages"
  (defvar package-list)
  (defvar package-archive-contents)

  (unless package-archive-contents
    (message "%s" "Refreshing package database...")
    (package-refresh-contents)
    (message "%s" "Done.")
    )

  (dolist (package package-list)
    (unless (package-installed-p package)
      (package-install package)))
  )

(defun modes-setup ()
  "Configure all modes"
  (add-hook 'prog-mode-hook 'prog-mode-setup)
  (add-hook 'haskell-mode-hook 'haskell-mode-setup)
  (add-hook 'c-mode-common-hook 'c-like-mode-setup)
  (add-hook 'emacs-lisp-mode-hook 'emacs-lisp-mode-setup)
  )

(defun hl-line-setup ()
  "Settings for hl-line"
  (global-hl-line-mode 1)
  (add-hook 'post-command-hook 'choose-line-color)
  (set-face-foreground 'highlight nil) ; Don't hide syntax highlighting
  )


(defun choose-line-color ()
  "Choose line and theme color: red for insert mode, green - for command mode"
  (if (evil-insert-state-p)
      (set-face-background 'hl-line "#201515")
    (set-face-background 'hl-line "#152015"))
  )

(defun whitespace-mode-setup ()
  "Settings for whitespace mode"
  (whitespace-mode)
  ;; Dark colors
  (set-face-foreground 'whitespace-space "#111111")
  (set-face-foreground 'whitespace-newline "#111111")
  )

(defun prog-mode-setup ()
  "Common settings for all programming modes"
  (flycheck-config)
  (whitespace-mode-setup)
  (delete-trailing-whitespace-on-save)
  )

(defun indent-buffer-on-save ()
  "Making hook for indentation file before save"
  (add-hook 'before-save-hook
            '(lambda ()
               (when buffer-file-name
                 (indent-region (point-min) (point-max) nil))
               )
            t t)
  )

(defun untabify-on-save ()
  "Making hook for indentation file before save"
  (add-hook 'before-save-hook
            '(lambda ()
               (when buffer-file-name
                 (untabify (point-min) (point-max)))
               )
            t t)
  )

(defun delete-trailing-whitespace-on-save ()
  "Making hook for deletion trailing whitespace before save"
  (add-hook 'before-save-hook
            '(lambda ()
               (when buffer-file-name
                 (delete-trailing-whitespace (point-min) (point-max)))
               )
            t t)
  )

(defun c-like-mode-setup ()
  "Settings for c-like languages (C, C++, Java)"
  (defvar c-basic-offset)

  (local-set-key (kbd "RET") 'newline-and-indent)
  (setq-default indent-tabs-mode nil)
  (setq c-basic-offset 4)
  (indent-buffer-on-save)
  (untabify-on-save)
  )

(defun c++-mode-setup ()
  "Settings C++ mode"
  (defvar flycheck-clang-language-standart "c++11")
  )

(defun haskell-mode-setup ()
  "Settings for haskell mode"
  (local-set-key (kbd "RET") 'haskell-newline-and-indent)
  (turn-on-haskell-indentation)
  )

(defun emacs-lisp-mode-setup ()
  "Settings for all emacs lisp."
  (local-set-key (kbd "RET") 'newline-and-indent)
  (setq-default indent-tabs-mode nil)
  (indent-buffer-on-save)
  (untabify-on-save)
  )


(defun my-next-buffer ()
  "next-buffer that skips certain buffers"
  (interactive)
  (defvar skippable-buffers)

  (next-buffer)
  (while (member (buffer-name) skippable-buffers)
    (next-buffer)))

(defun my-previous-buffer ()
  "previous-buffer that skips certain buffers"
  (interactive)
  (defvar skippable-buffers)

  (previous-buffer)
  (while (member (buffer-name) skippable-buffers)
    (previous-buffer)))

(config-main)
