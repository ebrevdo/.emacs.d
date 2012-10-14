(require 'package)

;; include marmalade repos in your package archive list
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))

;; defined before (package-initialize) is called so it's available for
;; use within username.el scripts.
(defun ensure-packages (ps)
  "install any missing packages in ps"
  (dolist (p ps)
    (when (not (package-installed-p p))
      (package-install p))))

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

(defvar my-packages '(auto-complete clojure-mode clojure-project-mode
                                    clojure-test-mode color-theme eieio
                                    ess ess-smart-underscore
                                    find-file-in-project
                                    idle-highlight-mode ido-ubiquitous
                                    magit midje-mode org paredit
                                    project-mode python scala-mode slime
                                    slime-repl
                                    starter-kit starter-kit-bindings
                                    starter-kit-eshell starter-kit-lisp
                                    virtualenv markdown-mode))

(ensure-packages my-packages)

;; helper functions

;; maximize
(defun fullscreen (&optional f)
  (interactive)
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
	    		 '(2 "_NET_WM_STATE_MAXIMIZED_VERT" 0))
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
	    		 '(2 "_NET_WM_STATE_MAXIMIZED_HORZ" 0)))

;; add to $PATH
(defun add-to-PATH (dir)
  "Add the specified path element to the Emacs PATH"
  (interactive "DEnter directory to be added to PATH: ")
  (if (file-directory-p dir)
      (setenv "PATH"
              (concat (expand-file-name dir)
                      path-separator
                      (getenv "PATH")))))


;; stuff you see

;; disable useless toolbar (and semi-useful menubar!)
(tool-bar-mode -1)
(menu-bar-mode -1)

(when window-system
  (fullscreen))

;; set a decent color theme
(require 'color-theme)
(when window-system
    (color-theme-dark-laptop))

;; empty the initial scratch message
(setq initial-scratch-message "")

;; make emacs interact with clipboard properly
(global-set-key "\C-w" 'clipboard-kill-region)
(global-set-key "\M-w" 'clipboard-kill-ring-save)
(global-set-key "\C-y" 'clipboard-yank)

;; default text mode + line wrap
(setq default-major-mode 'text-mode)
(setq initial-major-mode 'text-mode)
(setq-default fill-column 80)

; line, column number mode
(setq line-number-mode t)
(setq column-number-mode t)
(global-linum-mode t)

(when window-system
  (custom-set-faces
   ;; custom-set-faces was added by Custom.
   ;; If you edit it by hand, you could mess it up, so be careful.
   ;; Your init file should contain only one such instance.
   ;; If there is more than one, they won't work right.
   '(default ((t (:inherit nil :stipple nil :background "black"
                           :foreground "white" :inverse-video nil :box nil
  :strike-through nil :overline nil :underline nil :slant normal
  :weight normal :height 113 :width normal :foundry "unknown" :family "DejaVu Sans Mono"))))))

;; GNU R
(require 'ess-site)

;; python
;;(autoload 'pymacs-apply "pymacs")
;;(autoload 'pymacs-call "pymacs")
;;(autoload 'pymacs-eval "pymacs" nil t)
;;(autoload 'pymacs-exec "pymacs" nil t)
;;(autoload 'pymacs-load "pymacs" nil t)
;;(eval-after-load "pymacs"
;;  '(add-to-list 'pymacs-load-path YOUR-PYMACS-DIRECTORY"))
(require 'python)

(add-hook 'python-mode-hook
  (lambda ()
    (define-key python-mode-map [(tab)] 'completion-at-point)))
(add-hook 'inferior-python-mode-hook
  (lambda ()
    (define-key inferior-python-mode-map [(tab)] 'completion-at-point)))

(setq python-shell-interpreter "ipython --pylab --colors=NoColor"
      python-shell-virtualenv-path "/export/disk0/wb/python/"
      python-shell-interpreter-args ""
      python-shell-prompt-regexp "In \\[[0-9]+\\]: "
      python-shell-prompt-output-regexp "Out\\[[0-9]+\\]: "
      python-shell-completion-setup-code
      "from IPython.core.completerlib import module_completion"
      python-shell-completion-module-string-code
      "';'.join(module_completion('''%s'''))\n"
      python-shell-completion-string-code
      "';'.join(get_ipython().Completer.all_completions('''%s'''))\n")

(defun activate-virtualenv (dir)
  (setenv "VIRTUAL_ENV" dir)
  (add-to-PATH (concat dir "/bin"))
  (add-to-list 'exec-path (concat dir "/bin")))

;; For org-mode python, support my virtualenv.
(activate-virtualenv "/export/disk0/wb/python/")

;; clojure env tweaks
(require 'clojure-mode)
(defun turn-on-paredit () (paredit-mode 1))
(add-hook 'clojure-mode-hook 'esk-turn-on-paredit)
(add-hook 'lisp-mode-hook 'esk-turn-on-paredit)
(add-hook 'emacs-lisp-mode-hook 'esk-turn-on-paredit)
(add-hook 'slime-repl-mode-hook 'clojure-mode-font-lock-setup)
(add-hook 'slime-repl-mode-hook 'esk-turn-on-paredit)
(define-key clojure-mode-map (kbd "C-c v") 'slime-eval-buffer)
(global-set-key (kbd "C-c C-j") 'clojure-jack-in)

;; clojure+slime
;; control+i can perform indentation.  tab for completion.
(require 'slime)
(slime-setup)
(add-hook 'clojure-mode-hook
  (lambda ()
    (define-key clojure-mode-map "\r" 'newline-and-indent)
    (define-key clojure-mode-map [(control ?/)] 'backward-up-list)
    (define-key clojure-mode-map [(control ?=)] 'down-list)
    (define-key clojure-mode-map [(tab)] 'slime-indent-and-complete-symbol)
    (define-key clojure-mode-map [f13] 'slime-cheat-sheet)))


(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(comint-completion-addsuffix t)
 '(comint-get-old-input (lambda nil "") t)
 '(comint-input-ignoredups t)
 '(comint-input-ring-size 5000)
 '(comint-move-point-for-output nil)
 '(comint-prompt-read-only nil)
 '(comint-scroll-show-maximum-output t)
 '(comint-scroll-to-bottom-on-input t)
 '(inhibit-startup-screen t)
 '(menu-bar-mode t)
 '(protect-buffer-bury-p nil)
 '(scroll-bar-mode nil)
 '(show-paren-mode t)
 '(swank-clojure-extra-vm-args (quote ("-server" "-Xmx2048M")))
 '(tab-always-indent (quote complete))
 '(tool-bar-mode nil)
 '(tramp-default-method "ssh"))

;; spaces instead of tabs + show trailing whitespace + turn on autofill
(dolist (hook '(python-mode-hook
		shell-script-mode-hook
		c-mode-hook
                clj-mode-hook
		c++-mode-hook
                emacs-lisp-mode-hook
                clojure-mode-hook
                scala-mode-hook
                lisp-mode-hook
		java-mode-hook
		text-mode-hook))
  (add-hook hook (lambda()
                   (turn-on-auto-fill)
		   (setq-default indent-tabs-mode nil)
		   (setq-default show-trailing-whitespace t)
		   (setq-default highlight-tabs t))))

;; scala stuff
;; load the ensime lisp code...
(add-to-list 'load-path "/home/eugene/scala/ensime/elisp/")
(require 'ensime)

;; java
;; (add-to-list 'load-path "/home/eugene/java/malabar/lisp/")
;; ;; Or enable more if you wish
;; (setq semantic-default-submodes '(global-semantic-idle-scheduler-mode
;;                                   global-semanticdb-minor-mode
;;                                   global-semantic-idle-summary-mode
;;                                   global-semantic-mru-bookmark-mode))
;; (semantic-mode 1)
;; (require 'malabar-mode)
;; (setq malabar-groovy-lib-dir "/home/eugene/java/malabar/lib")
;; (add-to-list 'auto-mode-alist '("\\.java\\'" . malabar-mode))

;; This step causes the ensime-mode to be started whenever
;; scala-mode is started for a buffer. You may have to customize this step
;; if you're not using the standard scala mode.
(add-hook 'scala-mode-hook 'ensime-scala-mode-hook)

;; org mode
(org-babel-do-load-languages
 'org-babel-load-languages
 '((R . t)
   (python . t)
   (sh . t)))

;; reftex for org-mode
(defun org-mode-reftex-setup ()
  (load-library "reftex")
  (and (buffer-file-name)
       (file-exists-p (buffer-file-name))
       (reftex-parse-all))
  (define-key org-mode-map (kbd "C-c )") 'reftex-citation))
(add-hook 'org-mode-hook 'org-mode-reftex-setup)

;; other extensions
(add-to-list 'auto-mode-alist '("[.]avdl$" . javascript-mode))

;; shells
(defvar my-local-shells
  '("*shell0*" "*shell1*" "*shell2*" "*shell3*"))
(defvar my-shells my-local-shells)

(require 'tramp)

(setenv "PAGER" "cat")

;; truncate buffers continuously
(add-hook 'comint-output-filter-functions 'comint-truncate-buffer)

(defun make-my-shell-output-read-only (text)
  "Add to comint-output-filter-functions to make stdout read only in my shells."
  (if (member (buffer-name) my-shells)
      (let ((inhibit-read-only t)
            (output-end (process-mark (get-buffer-process (current-buffer)))))
        (put-text-property comint-last-output-start output-end 'read-only t))))
(add-hook 'comint-output-filter-functions 'make-my-shell-output-read-only)

(defun my-dirtrack-mode ()
  "Add to shell-mode-hook to use dirtrack mode in my shell buffers."
  (when (member (buffer-name) my-shells)
    (shell-dirtrack-mode 0)
    (set-variable 'dirtrack-list '("^.*[^ ]+:\\(.*\\)>" 1 nil))
    (dirtrack-mode 1)))
(add-hook 'shell-mode-hook 'my-dirtrack-mode)

; interpret and use ansi color codes in shell output windows
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(defun set-scroll-conservatively ()
  "Add to shell-mode-hook to prevent jump-scrolling on newlines in shell buffers."
  (set (make-local-variable 'scroll-conservatively) 10))
(add-hook 'shell-mode-hook 'set-scroll-conservatively)

;; i think this is wrong, and it buries the shell when you run emacsclient from
;; it. temporarily removing.
;; (defun unset-display-buffer-reuse-frames ()
;;   "Add to shell-mode-hook to prevent switching away from the shell buffer
;; when emacsclient opens a new buffer."
;;   (set (make-local-variable 'display-buffer-reuse-frames) t))
;; (add-hook 'shell-mode-hook 'unset-display-buffer-reuse-frames)

;; make it harder to kill my shell buffers
;(require 'protbuf)
;(add-hook 'shell-mode-hook 'protect-process-buffer-from-kill-mode)

(defun make-comint-directory-tracking-work-remotely ()
  "Add this to comint-mode-hook to make directory tracking work
while sshed into a remote host, e.g. for remote shell buffers
started in tramp. (This is a bug fix backported from Emacs 24:
http://comments.gmane.org/gmane.emacs.bugs/39082"
  (set (make-local-variable 'comint-file-name-prefix)
       (or (file-remote-p default-directory) "")))
(add-hook 'comint-mode-hook 'make-comint-directory-tracking-work-remotely)

(defun enter-again-if-enter ()
  "Make the return key select the current item in minibuf and shell history isearch.
An alternate approach would be after-advice on isearch-other-meta-char."
  (when (and (not isearch-mode-end-hook-quit)
             (equal (this-command-keys-vector) [13])) ; == return
    (cond ((active-minibuffer-window) (minibuffer-complete-and-exit))
          ((member (buffer-name) my-shells) (comint-send-input)))))
(add-hook 'isearch-mode-end-hook 'enter-again-if-enter)

(defadvice comint-previous-matching-input
    (around suppress-history-item-messages activate)
  "Suppress the annoying 'History item : NNN' messages from shell history isearch.
If this isn't enough, try the same thing with
comint-replace-by-expanded-history-before-point."
  (let ((old-message (symbol-function 'message)))
    (unwind-protect
      (progn (fset 'message 'ignore) ad-do-it)
    (fset 'message old-message))))

;; (defadvice comint-send-input (around go-to-end-of-multiline activate)
;;   "When I press enter, jump to the end of the *buffer*, instead of the end of
;; the line, to capture multiline input. (This only has effect if
;; `comint-eol-on-send' is non-nil."
;;   (flet ((end-of-line () (end-of-buffer)))
;;     ad-do-it))

;; not sure why, but comint needs to be reloaded from the source (*not*
;; compiled) elisp to make the above advise stick.
;(load "comint.el.gz")

;; for other code, e.g. emacsclient in TRAMP ssh shells and automatically
;; closing completions buffers, see the links above.

(defun comint-close-completions ()
  "Close the comint completions buffer.
Used in advice to various comint functions to automatically close
the completions buffer as soon as I'm done with it. Based on
Dmitriy Igrishin's patched version of comint.el."
  (if comint-dynamic-list-completions-config
      (progn
        (set-window-configuration comint-dynamic-list-completions-config)
        (setq comint-dynamic-list-completions-config nil))))

(defadvice comint-send-input (after close-completions activate)
  (comint-close-completions))

(defadvice comint-dynamic-complete-as-filename (after close-completions activate)
  (if ad-return-value (comint-close-completions)))

(defadvice comint-dynamic-simple-complete (after close-completions activate)
  (if (member ad-return-value '('sole 'shortest 'partial))
      (comint-close-completions)))

(defadvice comint-dynamic-list-completions (after close-completions activate)
    (comint-close-completions)
    (if (not unread-command-events)
        ;; comint's "Type space to flush" swallows space. put it back in.
        (setq unread-command-events (listify-key-sequence " "))))