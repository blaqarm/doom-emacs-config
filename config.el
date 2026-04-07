;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!



;; clipboard 1
;; (setq evil-want-clipboard t)

;; (setq select-enable-clipboard t
;;       select-enable-primary nil)

;; (defun my/wl-copy (text &optional _push)
;;   (let ((process-connection-type nil))
;;     (let ((proc (start-process
;;                  "wl-copy" nil
;;                  "wl-copy" "--type" "text/plain" "-f" "-n")))
;;       (process-send-string proc text)
;;       (process-send-eof proc))))

;; (defun my/wl-paste ()
;;   (string-trim-right
;;    (shell-command-to-string
;;     "wl-paste --no-newline --type text/plain 2>/dev/null | tr -d '\r'")))

;; (defun my/force-plain-clipboard (&optional _frame)
;;   (setq interprogram-cut-function #'my/wl-copy)
;;   (setq interprogram-paste-function #'my/wl-paste))

;; (add-hook 'after-init-hook #'my/force-plain-clipboard)
;; (add-hook 'after-make-frame-functions #'my/force-plain-clipboard)






;; clipboard 2
(defun my/wl-copy (text &optional _push)
  (with-temp-file "/tmp/emacs-wl-copy-debug.txt"
    (insert "RAW:\n")
    (prin1 text (current-buffer))
    (insert "\n\nPLAIN:\n")
    (insert text))
  (let ((process-connection-type nil)
        (coding-system-for-write 'utf-8))
    (let ((proc (make-process
                 :name "wl-copy"
                 :buffer nil
                 :command '("wl-copy" "--type" "text/plain;charset=utf-8" "-f" "-n")
                 :connection-type 'pipe
                 :noquery t)))
      (process-send-string proc text)
      (process-send-eof proc))))





;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

(map! :leader
      :desc "Comment line" "-" #'comment-line)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;;
;; -----------------------------------------------
;; for agenda
;;(setq org-agenda-files '("/mnt/SSD1/blaQarm"))
;;
;; (setq org-agenda-files
;;       (directory-files-recursively
;;        "/mnt/SSD1/blaQarm" "\\.org$"))


(setq org-agenda-files
      (directory-files-recursively
       "/mnt/SSD1/blaQarm"
       "\\.org$"
       nil
       (lambda (dir)
         (not (string-match-p "Programming" dir)))))
;; (not (string-match-p "Programming\\|Archive\\|Temp" dir)))


;; system clipboard
;; (setq evil-want-clipboard t)
;;
;; clipboard
;; (setq select-enable-clipboard t
;;       select-enable-primary t)
;;
;; wayland clipboard for terminal emacs via wl-clipboard
;; (when (and (not (display-graphic-p))
;;            (eq system-type 'gnu/linux)
;;            (or (getenv "WAYLAND_DISPLAY") (getenv "SWAYSOCK"))
;;            (executable-find "wl-copy")
;;            (executable-find "wl-paste"))
;;   (defun my/wl-copy (text &optional _push)
;;     (let ((process-connection-type nil))
;;       (let ((proc (start-process "wl-copy" nil "wl-copy" "-f" "-n")))
;;         (process-send-string proc text)
;;         (process-send-eof proc))))
;;   (defun my/wl-paste ()
;;     (string-trim-right
;;      (shell-command-to-string "wl-paste -n 2>/dev/null | tr -d '\r'")))
;;   (setq interprogram-cut-function #'my/wl-copy)
;;   (setq interprogram-paste-function #'my/wl-paste)
;;   (setq select-enable-clipboard t))

;; Make evil yanks use system clipboard (+)
;; (setq evil-unnamedplus t)
;;
;;
;;
;; like nvim config in neotree
;;
;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; Doom loads this file after init.el and packages.el.
;; Keep it tidy: small, stable tweaks that you actually use.

;; Basic identity (optional)
;; (setq user-full-name "Your Name"
;;       user-mail-address "you@example.com")

;; UI / behavior (optional examples)
;; (setq display-line-numbers-type 'relative)

;; NVIM-LIKE WINDOW NAVIGATION (safe for terminal backspace)
;;
;; Goal:
;; - C-h/j/k/l switch windows like in nvim.
;; - In terminal, C-h is often sent as DEL (Backspace).
;;   So bind DEL -> window-left ONLY in normal-state.
;; - DO NOT bind DEL in insert-state (otherwise backspace breaks).

(with-eval-after-load 'evil
;; Normal state: nvim-style
  (define-key evil-normal-state-map (kbd "C-h") #'evil-window-left)
  (define-key evil-normal-state-map (kbd "C-j") #'evil-window-down)
  (define-key evil-normal-state-map (kbd "C-k") #'evil-window-up)
  (define-key evil-normal-state-map (kbd "C-l") #'evil-window-right)

;; Insert state: keep it, but avoid C-h because terminal may turn it into backspace
  (define-key evil-insert-state-map (kbd "C-j") #'evil-window-down)
  (define-key evil-insert-state-map (kbd "C-k") #'evil-window-up)
  (define-key evil-insert-state-map (kbd "C-l") #'evil-window-right)

;; Terminal fallback: C-h often arrives as DEL/<backspace>
;; Only in normal-state so Backspace in insert still deletes text.
  (define-key evil-normal-state-map (kbd "DEL") #'evil-window-left)
  (define-key evil-normal-state-map (kbd "<backspace>") #'evil-window-left))

;; TREEMACS: vim-ish file ops + same window nav

(with-eval-after-load 'treemacs
;; File ops
  (define-key treemacs-mode-map (kbd "a") #'treemacs-create-file)
  (define-key treemacs-mode-map (kbd "A") #'treemacs-create-dir)
  (define-key treemacs-mode-map (kbd "r") #'treemacs-rename)
  (define-key treemacs-mode-map (kbd "R") #'treemacs-refresh)
  (define-key treemacs-mode-map (kbd "d") #'treemacs-delete)

;; Window nav inside treemacs
  (define-key treemacs-mode-map (kbd "C-h") #'evil-window-left)
  (define-key treemacs-mode-map (kbd "C-j") #'evil-window-down)
  (define-key treemacs-mode-map (kbd "C-k") #'evil-window-up)
  (define-key treemacs-mode-map (kbd "C-l") #'evil-window-right)

;; Terminal fallback for "left" inside treemacs
  (define-key treemacs-mode-map (kbd "DEL") #'evil-window-left)
  (define-key treemacs-mode-map (kbd "<backspace>") #'evil-window-left)

;; Doom often uses evil-treemacs state (separate map) → bind there too
  (when (boundp 'evil-treemacs-state-map)
    (define-key evil-treemacs-state-map (kbd "a") #'treemacs-create-file)
    (define-key evil-treemacs-state-map (kbd "A") #'treemacs-create-dir)
    (define-key evil-treemacs-state-map (kbd "r") #'treemacs-rename)
    (define-key evil-treemacs-state-map (kbd "R") #'treemacs-refresh)
    (define-key evil-treemacs-state-map (kbd "d") #'treemacs-delete)

    (define-key evil-treemacs-state-map (kbd "C-h") #'evil-window-left)
    (define-key evil-treemacs-state-map (kbd "C-j") #'evil-window-down)
    (define-key evil-treemacs-state-map (kbd "C-k") #'evil-window-up)
    (define-key evil-treemacs-state-map (kbd "C-l") #'evil-window-right)

    (define-key evil-treemacs-state-map (kbd "DEL") #'evil-window-left)
    (define-key evil-treemacs-state-map (kbd "<backspace>") #'evil-window-left)))

;; (Optional) a dedicated Help key after stealing C-h sometimes:
;; Doom already has help on SPC h. if need  add another:
;; (global-set-key (kbd "C-c h") help-map)

;;; End of config.el





;; jump to open-closed tag like nvim
(after! evil
  (global-evil-matchit-mode 1))

;; Сделать так, чтобы % использовал matchit, если он доступен
(with-eval-after-load 'evil-matchit
  (define-key evil-normal-state-map (kbd "%") #'evilmi-jump-items)
  (define-key evil-visual-state-map (kbd "%") #'evilmi-jump-items))

;;
;;Relative number like nvim
(setq display-line-numbers-type 'relative)
;;
;; font
;;
(setq doom-font
      (font-spec :family "Hack Nerd Font Mono"
                 :size 14
                 ;; :weight 'regular))
                 :spacing 110
                 :weight 'semibold))

;;
;; wl-copy for system buffer
(setq wl-copy-process nil)

(defun wl-copy (text)
  (setq wl-copy-process (make-process
                         :name "wl-copy"
                         :buffer nil
                         :command '("wl-copy" "-f" "-n")
                         :connection-type 'pipe))
  (process-send-string wl-copy-process text)
  (process-send-eof wl-copy-process))

(setq interprogram-cut-function 'wl-copy)

;; start image
(setq fancy-splash-image "~/.doom.d/doom-emacs.png")







;; gptel + Ollama for Doom Emacs
;; Normal chat: qwen3:14b
;; Fast/code chat: qwen2.5-coder:7b

(after! gptel
  (setq gptel-backend
        (gptel-make-ollama
         "Ollama"
         :host "127.0.0.1:11434"
         :stream t
         :models '(qwen3:14b qwen2.5-coder:7b)))

;; модель по умолчанию
  (setq gptel-model 'qwen3:14b)

  (setq gptel-system-message
        "Отвечай на русском языке. Код и технические термины оставляй на английском. Ты помощник по программированию."))

;; буфер с нужной моделью

(defun my/gptel-get-buffer (name model)
  (let ((buf (gptel name)))
    (with-current-buffer buf
      (setq-local gptel-model model))
    buf))

;; обычный чат

(defun my/gptel-open-chat ()
  (interactive)
  (pop-to-buffer
   (my/gptel-get-buffer "*gptel*" 'qwen3:14b)))

;; быстрый чат

(defun my/gptel-open-fast-chat ()
  (interactive)
  (pop-to-buffer
   (my/gptel-get-buffer "*gptel-fast*" 'qwen2.5-coder:7b)))

;; быстрый вопрос

(defun my/gptel-fast-question (question)
  (interactive "sБыстрый вопрос: ")

  (let ((buf (my/gptel-get-buffer "*gptel-fast*" 'qwen2.5-coder:7b)))

    (with-current-buffer buf
      (goto-char (point-max))

      (unless (bolp)
        (insert "\n\n"))

      (insert question)
      (insert "\n\n")

      (gptel-send))

    (pop-to-buffer buf)))

;; спросить про выделение

(defun my/gptel-ask-region ()
  (interactive)

  (unless (use-region-p)
    (user-error "Сначала выдели код"))

  (let* ((text (buffer-substring-no-properties
                (region-beginning)
                (region-end)))

         (src-file (or (buffer-file-name) (buffer-name)))
         (src-mode (symbol-name major-mode))

         ;; (buf (my/gptel-get-buffer "*gptel-fast*" 'qwen2.5-coder:7b)))
            (buf (my/gptel-get-buffer "*gptel*" 'qwen3:14b)))

    (with-current-buffer buf
      (goto-char (point-max))

      (unless (bolp)
        (insert "\n\n"))

      (insert
       (format
        "Объясни этот код. Укажи возможные проблемы и предложи улучшения.\n\nФайл: %s\nРежим: %s\n\n"
        src-file src-mode))

      (insert text)
      (insert "\n\n")

      (gptel-send))

    (pop-to-buffer buf)))

;; весь буфффер

(defun my/gptel-ask-buffer ()
  (interactive)

  (let* ((text (buffer-substring-no-properties
                (point-min)
                (point-max)))

         (src-file (or (buffer-file-name) (buffer-name)))
         (src-mode (symbol-name major-mode))

         ;; (buf (my/gptel-get-buffer "*gptel-fast*" 'qwen2.5-coder:7b)))
         (buf (my/gptel-get-buffer "*gptel-fast*" 'qwen3:14b)))

    (with-current-buffer buf
      (goto-char (point-max))

      (unless (bolp)
        (insert "\n\n"))

      (insert
       (format
        "Проанализируй этот файл. Объясни что он делает и предложи улучшения.\n\nФайл: %s\nРежим: %s\n\n"
        src-file src-mode))

      (insert text)
      (insert "\n\n")

      (gptel-send))

    (pop-to-buffer buf)))

;; Doom keybindings

(map! :leader
      (:prefix ("l" . "llm")

       :desc "Chat (qwen3)"
       "c" #'my/gptel-open-chat

       :desc "Fast chat (coder)"
       "f" #'my/gptel-open-fast-chat

       :desc "Fast question"
       "q" #'my/gptel-fast-question

       :desc "Ask about region"
       "r" #'my/gptel-ask-region

       :desc "Ask about buffer"
       "b" #'my/gptel-ask-buffer))











;; next buffer
(map!
 :n "C-<tab>" #'next-buffer
 :n "C-S-<tab>" #'previous-buffer)
