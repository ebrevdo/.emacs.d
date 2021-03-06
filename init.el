(require 'package)

;; Comment
(defmacro comment (v))

;; include marmalade repos in your package archive list
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))

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

(defvar my-packages '(auto-complete
                      clojure-mode clojure-project-mode
                      clojure-test-mode color-theme eieio
                      ess ess-smart-underscore company
                      find-file-in-project jedi
                      idle-highlight-mode ido-ubiquitous
                      magit org paredit python ein
                      project-mode scala-mode
                      nrepl ac-nrepl emacs-eclim
                      starter-kit starter-kit-bindings
                      starter-kit-eshell starter-kit-lisp
                      virtualenv markdown-mode
                      auto-complete-clang))

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

(when (and window-system (not (eq system-type 'darwin)))
  (fullscreen))

(when (not window-system)
  (xterm-mouse-mode))

;; set a decent color theme
(when window-system
  (require 'color-theme)
  (color-theme-initialize)
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
  ;; Set 16pt font
  (set-face-attribute 'default nil :height 160))

(comment
 (when (file-accessible-directory-p "~/emacs/cedet-dev")
   (load-file "~/emacs/cedet-dev/cedet-devel-load.el")

   ;; * This enables the database and idle reparse engines
   (semantic-load-enable-minimum-features)

   ;; * This enables some tools useful for coding, such as summary mode,
   ;;   imenu support, and the semantic navigator
   (semantic-load-enable-code-helpers)

   ;; Use gnu/global sometimes
   (semanticdb-enable-gnu-global-databases 'c-mode)
   (semanticdb-enable-gnu-global-databases 'c++-mode)

   ;; Use cscope (to build an index: cscope -Rq)
   (semanticdb-enable-cscope-databases)

   ;; * This enables even more coding tools such as intellisense mode,
   ;;   decoration mode, and stickyfunc mode (plus regular code helpers)
   ;;  (semantic-load-enable-gaudy-code-helpers)
   (add-to-list 'semantic-default-submodes 'global-semantic-idle-summary-mode t)
   (add-to-list 'semantic-default-submodes 'global-semantic-idle-completions-mode t)
   (add-to-list 'semantic-default-submodes 'global-cedet-m3-minor-mode t)

   ;;(semantic-mode 1)

   ;; Enable EDE (Project Management) features
   (global-ede-mode 1)

   (setq ede-arduino-appdir "/opt/arduino-1.0.5")

   ;; Projects
   (ede-cpp-root-project "graphlab" :file "/opt/graphlab/configure"
                         :include-path (recursive-list-directories "/opt/graphlab"))))

;; Arduino mode
(when (file-accessible-directory-p "~/emacs/arduino-mode")
  (add-to-list 'load-path "~/emacs/arduino-mode")
  (setq auto-mode-alist (cons '("\\.\\(pde\\|ino\\)$" . arduino-mode) auto-mode-alist))
  (autoload 'arduino-mode "arduino-mode" "Arduino editing mode." t))

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

(let ((ppath (expand-file-name "~/python/")))
  (when (file-accessible-directory-p ppath)
    (setq python-shell-virtualenv-path ppath)

    ;; For org-mode python, support my virtualenv.
    (activate-virtualenv ppath)))

;; jedi
(setq jedi:setup-keys t)
(add-hook 'python-mode-hook 'jedi:setup)

;; ein and jedi
(add-hook 'ein:notebook-multilang-mode-hook
          (lambda ()
            (define-key ein:notebook-multilang-mode-map [(tab)] 'ein:completer-complete)))

(add-hook 'ein:notebook-python-mode-hook
          (lambda ()
            (define-key ein:notebook-python-mode-map [(tab)] 'ein:completer-complete)))

;; python-mode automatically accesses ein
;;(add-hook 'after-init-hook 'ein:notebooklist-load)
;;(setq ein:connect-default-notebook "8888/main")
;;(add-hook 'python-mode-hook 'ein:connect-to-default-notebook)

;; if you want auto-complete inside ein python
;; (add-hook 'ein:connect-mode-hook
;;   (lambda ()
;;     (define-key ein:connect-mode-map [(tab)] 'ein:completer-complete)))

;; if you want jedi inside ein python
;;(add-hook 'ein:connect-mode-hook 'ein:jedi-setup)

;; clojure env tweaks
(require 'clojure-mode)
(defun turn-on-paredit () (paredit-mode 1))
(add-hook 'clojure-mode-hook 'paredit-mode)
(add-hook 'lisp-mode-hook 'paredit-mode)
(add-hook 'emacs-lisp-mode-hook 'paredit-mode)
(add-hook 'nrepl-mode-hook 'clojure-mode-font-lock-setup)
(add-hook 'nrepl-mode-hook 'paredit-mode)
(define-key clojure-mode-map (kbd "C-c v") 'nrepl-eval-buffer)
(global-set-key (kbd "C-c C-j") 'nrepl-jack-in)

;; clojure+slime
;; control+i can perform indentation.  tab for completion.
;;(require 'slime)
;;(slime-setup)
(add-hook 'clojure-mode-hook
          (lambda ()
            (define-key clojure-mode-map "\r" 'newline-and-indent)
            (define-key clojure-mode-map [(control ?/)] 'backward-up-list)
            (define-key clojure-mode-map [(control ?=)] 'down-list)
            (define-key clojure-mode-map [(tab)] 'nrepl-indent-and-complete-symbol)))

;; slime for ECL / CL development
(when (file-accessible-directory-p "~/emacs/slime")
  (add-to-list 'load-path "~/emacs/slime/")
  (add-to-list 'auto-mode-alist '("\\.asd$" . lisp-mode))

  (eval-after-load "slime"
    '(progn
       (setq slime-lisp-implementations
             '((ecl ("/usr/local/bin/ecl"))
               ;;(sbcl ("/usr/bin/sbcl"))
               ;;(clisp ("/usr/bin/clisp"))
               ))
       (slime-setup '(slime-asdf
                      slime-autodoc
                      slime-editing-commands
                      slime-fancy-inspector
                      slime-fontifying-fu
                      slime-fuzzy
                      slime-indentation
                      slime-package-fu
                      slime-references
                      slime-repl
                      slime-sbcl-exts
                      slime-scratch
                      slime-xref-browser))
       (slime-autodoc-mode)
       (setq slime-complete-symbol*-fancy t)
       (setq slime-complete-symbol-function 'slime-fuzzy-complete-symbol)
       (dolist (hook '(slime-mode-hook slime-repl-mode-hook))
         (add-hook hook (lambda ()
                          (paredit-mode +1)
                          (set-variable lisp-indent-function 'common-lisp-indent-function)
                          (slime-define-keys slime-mode-map
                            ("\r" 'newline-and-indent)
                            ([(control ?/)] 'backward-up-list)
                            ([(control ?=)] 'down-list)
                            ([tab] 'slime-indent-and-complete-symbol)
                            ([(control c) tab] 'slime-complete-form)
                            ([f13] 'slime-cheat-sheet)))))))

  (require 'slime))



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
 '(company-backends (quote (company-emacs-eclim company-elisp company-css company-semantic company-abbrev company-clang company-xcode company-ropemacs (company-gtags company-etags company-dabbrev-code company-keywords) company-oddmuse company-files company-dabbrev)))
 '(eclim-eclipse-dirs (quote ("~/Documents/workspace")))
 '(eclimd-default-workspace "~/Documents/workspace")
 '(ede-project-directories (quote ("/opt/graphlab" "/opt/graphlab/debug")))
 '(inhibit-startup-screen t)
 '(jedi:complete-on-dot t)
 '(jedi:get-in-function-call-delay 0)
 '(jedi:key-complete (kbd "<tab>"))
 '(jedi:key-goto-definition (kbd "M-."))
 '(menu-bar-mode t)
 '(nrepl-server-command "lein2 repl :headless")
 '(protect-buffer-bury-p nil)
 '(safe-local-variable-values (quote ((Package . C) (Syntax . Common-Lisp) (whitespace-line-column . 80) (lexical-binding . t))))
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
                latex-mode
                scala-mode-hook
                lisp-mode-hook
                java-mode-hook
                text-mode-hook
                matlab-mode
                matlab-shell-mode))
  (add-hook hook (lambda()
                   (turn-on-auto-fill)
                   (setq-default indent-tabs-mode nil
                                 show-trailing-whitespace t
                                 ;; 4-space tabs.  new line after paren
                                 ;; indentation tabs instead of indenting up to parens
                                 c-basic-offset 4
                                 c-offsets-alist '((arglist-intro . +)
                                                   (arglist-cont . nil)
                                                   (arglist-cont-nonempty . +))
                                 tab-width 4
                                 highlight-tabs t))))

;; If you want auto-complete
(require 'company)
(add-hook 'after-init-hook 'global-company-mode)

;; (require 'auto-complete)
;; (add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
;; (require 'auto-complete-config)
;; (ac-config-default)
;; ;; Make it so return doesn't complete (makes it hard to add newlines)
;; (define-key ac-complete-mode-map (kbd "<return>") nil)
;; (define-key ac-complete-mode-map (kbd "RET") nil)
;; (define-key ac-complete-mode-map (kbd "<C-return>") 'ac-complete)

;; (dolist (mode '(python-mode
;;                 shell-script-mode
;;                 c-mode
;;                 c++-mode
;;                 emacs-lisp-mode
;;                 latex-mode
;;                 scala-mode
;;                 clojure-mode
;;                 lisp-mode
;;                 java-mode))
;;   (add-to-list 'ac-modes mode))

;; scala stuff
;; load the ensime lisp code...
(when (file-accessible-directory-p "~/scala/ensime")
  (add-to-list 'load-path "~/scala/ensime/elisp/")
  (require 'ensime)
  ;; This step causes the ensime-mode to be started whenever
  ;; scala-mode is started for a buffer. You may have to customize this step
  ;; if you're not using the standard scala mode.
  (add-hook 'scala-mode-hook 'ensime-scala-mode-hook))

;; java -- eclipse integration via eclim
(require 'eclim)
(require 'eclimd)

;;(require 'ac-emacs-eclim-source)
(global-eclim-mode)


;;(setq help-at-pt-display-when-idle t)
;;(setq help-at-pt-timer-delay 0.05)
;;(help-at-pt-set-timer)
;;(ac-emacs-eclim-config)

(require 'company-emacs-eclim)
(company-emacs-eclim-setup)
(global-company-mode t)

(add-hook 'eclim-mode-hook
          (lambda ()
            (start-eclimd (first eclim-eclipse-dirs))
            (eclim-problems-show-errors)
            (define-key eclim-mode-map (kbd "M-.") 'eclim-java-find-declaration)
            (define-key eclim-mode-map (kbd "C-?") 'eclim-java-show-documentation-for-current-element)
            (define-key eclim-mode-map (kbd "<tab>") 'company-complete)
            (define-key eclim-mode-map (kbd "C-c `") 'eclim-problems)))

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
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(when (file-accessible-directory-p "~/.emacs.d/matlab-emacs")
  (add-to-list 'load-path "~/.emacs.d/matlab-emacs")
  (load-library "matlab-load")

  (add-hook 'matlab-mode-hook
            (lambda () (define-key matlab-mode-map (kbd "<tab>") 'matlab-complete-symbol)))

  (add-hook 'matlab-shell-mode-hook
            (lambda () (define-key matlab-shell-mode-map (kbd "<tab>") 'matlab-complete-symbol)))
  ;; Enable CEDET feature support for MATLAB code. (Optional)
  ;;(matlab-cedet-setup)
  )

(defun recursive-list-directories (path)
  (let* ((last (substring path -1 nil))
         (path (if (string= last "/")
                   path
                 (concat path "/")))
         (lpath (length path))
         (cmd (concat "find " path " -type d"))
         (parse (lambda (x)
                  (if (< lpath (length x))
                      (substring x lpath)
                    x)))
         (splitted (split-string (shell-command-to-string cmd) "\n")))
    (mapcar parse splitted)))
