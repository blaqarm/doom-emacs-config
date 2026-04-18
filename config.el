;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; ============================================================================
;; Environment / PATH
;; ============================================================================

;; Синхронизируем PATH из shell (zsh) с Emacs
;; Без этого GUI-Emacs не видит ~/.local/bin, ~/.npm-global/bin, $GOPATH/bin
(use-package! exec-path-from-shell
  :init
  (setq exec-path-from-shell-variables
        '("PATH" "MANPATH" "GOPATH"))
  :config
  (when (or (daemonp) (memq window-system '(mac ns x pgtk))
            (display-graphic-p))
    (exec-path-from-shell-initialize)))

;; Подстраховка на случай если exec-path-from-shell не отработал
(let ((extra-paths '("~/.local/bin"
                     "~/.npm-global/bin"
                     "~/go/bin")))
  (dolist (p extra-paths)
    (let ((expanded (expand-file-name p)))
      (when (file-directory-p expanded)
        (setenv "PATH" (concat expanded ":" (getenv "PATH")))
        (add-to-list 'exec-path expanded)))))


;; ============================================================================
;; LSP — общие настройки
;; ============================================================================

;; Отключаем plist-режим (ломает html-ls в текущей комбинации версий)
(setq lsp-use-plists nil)

;; Все отключённые встроенные клиенты в ОДНОМ списке
;; - tailwindcss: встроенный клиент lsp-mode падает с "node --stdio" без пути к скрипту
;; - ts-ls, vtsls: предпочитаем typescript-language-server явно
;; - pyls: старый, используем pylsp (его НЕ отключаем)
(setq lsp-disabled-clients '(tailwindcss pyls))

;; Регистрация кастомных LSP клиентов
(with-eval-after-load 'lsp-mode

  ;; Удаляем возможные встроенные регистрации из hash-table
  (when (hash-table-p lsp-clients)
    (remhash 'tailwindcss        lsp-clients)
    (remhash 'tailwindcss-tramp  lsp-clients)
    (remhash 'ts-ls              lsp-clients)
    (remhash 'vtsls              lsp-clients))

  ;; --------------------------------------------------------------------------
  ;; Tailwind CSS Language Server
  ;; --------------------------------------------------------------------------
  (lsp-register-client
   (make-lsp-client
    :new-connection
    (lsp-stdio-connection
     (lambda ()
       (list "/usr/bin/node"
             "/usr/lib/node_modules/@tailwindcss/language-server/bin/tailwindcss-language-server"
             "--stdio")))
    :major-modes '(web-mode html-mode css-mode scss-mode
                   typescript-mode js-mode js2-mode vue-mode
                   rjsx-mode php-mode)
    :server-id 'tailwindcss-manual
    :priority 100
    :add-on? t
    :initialization-options
    (lambda () '(:userLanguages (:html "html")))))

  ;; --------------------------------------------------------------------------
  ;; TypeScript / JavaScript Language Server
  ;; --------------------------------------------------------------------------
  (lsp-register-client
   (make-lsp-client
    :new-connection
    (lsp-stdio-connection
     (lambda ()
       (list "/usr/bin/node"
             "/usr/lib/node_modules/typescript-language-server/lib/cli.mjs"
             "--stdio")))
    :major-modes '(js-mode js2-mode rjsx-mode
                   typescript-mode typescript-ts-mode js-ts-mode)
    :server-id 'js-ls-manual
    :priority 100
    :initialization-options
    '(:preferences (:includeCompletionsForModuleExports t)))))

;; Хуки: автоматически стартовать LSP в этих режимах
(add-hook 'js-mode-hook         #'lsp!)
(add-hook 'js2-mode-hook        #'lsp!)
(add-hook 'typescript-mode-hook #'lsp!)
(add-hook 'python-mode-hook     #'lsp!)
(add-hook 'web-mode-hook        #'lsp!)
(add-hook 'css-mode-hook        #'lsp!)
(add-hook 'scss-mode-hook       #'lsp!)


;; ============================================================================
;; UI
;; ============================================================================

(setq doom-theme 'doom-one)

;; Относительные номера строк (как в nvim)
(setq display-line-numbers-type 'relative)

;; Шрифт
(setq doom-font
      (font-spec :family "Hack Nerd Font Mono"
                 :size 14
                 :spacing 110
                 :weight 'semibold))

;; Splash-картинка
(setq fancy-splash-image "~/.doom.d/doom-emacs.png")


;; ============================================================================
;; Org Mode
;; ============================================================================

(setq org-directory "~/org/")

(setq org-agenda-files
      (directory-files-recursively
       "/mnt/SSD1/blaQarm"
       "\\.org$"
       nil
       (lambda (dir)
         (not (string-match-p "Programming" dir)))))


;; ============================================================================
;; Evil — nvim-style window navigation
;; ============================================================================
;; C-h/j/k/l — переключение окон как в nvim
;; В терминале C-h часто приходит как DEL/<backspace>, биндим только в normal-state

(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "C-h") #'evil-window-left)
  (define-key evil-normal-state-map (kbd "C-j") #'evil-window-down)
  (define-key evil-normal-state-map (kbd "C-k") #'evil-window-up)
  (define-key evil-normal-state-map (kbd "C-l") #'evil-window-right)

  (define-key evil-insert-state-map (kbd "C-j") #'evil-window-down)
  (define-key evil-insert-state-map (kbd "C-k") #'evil-window-up)
  (define-key evil-insert-state-map (kbd "C-l") #'evil-window-right)

  (define-key evil-normal-state-map (kbd "DEL") #'evil-window-left)
  (define-key evil-normal-state-map (kbd "<backspace>") #'evil-window-left))

;; Jump to matching tag через %
(after! evil
  (global-evil-matchit-mode 1))

(with-eval-after-load 'evil-matchit
  (define-key evil-normal-state-map (kbd "%") #'evilmi-jump-items)
  (define-key evil-visual-state-map (kbd "%") #'evilmi-jump-items))


;; ============================================================================
;; Treemacs — vim-style file ops
;; ============================================================================

(with-eval-after-load 'treemacs
  ;; File ops
  (define-key treemacs-mode-map (kbd "a") #'treemacs-create-file)
  (define-key treemacs-mode-map (kbd "A") #'treemacs-create-dir)
  (define-key treemacs-mode-map (kbd "r") #'treemacs-rename)
  (define-key treemacs-mode-map (kbd "R") #'treemacs-refresh)
  (define-key treemacs-mode-map (kbd "d") #'treemacs-delete)

  ;; Window nav
  (define-key treemacs-mode-map (kbd "C-h") #'evil-window-left)
  (define-key treemacs-mode-map (kbd "C-j") #'evil-window-down)
  (define-key treemacs-mode-map (kbd "C-k") #'evil-window-up)
  (define-key treemacs-mode-map (kbd "C-l") #'evil-window-right)

  (define-key treemacs-mode-map (kbd "DEL") #'evil-window-left)
  (define-key treemacs-mode-map (kbd "<backspace>") #'evil-window-left)

  ;; Doom использует evil-treemacs state
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


;; ============================================================================
;; Wayland Clipboard — wl-copy для системного буфера
;; ============================================================================

(setq wl-copy-process nil)

(defun wl-copy (text)
  "Копировать TEXT в системный буфер через wl-copy."
  (setq wl-copy-process (make-process
                         :name "wl-copy"
                         :buffer nil
                         :command '("wl-copy" "-f" "-n")
                         :connection-type 'pipe))
  (process-send-string wl-copy-process text)
  (process-send-eof wl-copy-process))

(setq interprogram-cut-function 'wl-copy)

;; Альтернативная версия с отладкой и UTF-8 (закомментируй wl-copy выше если будешь использовать эту)
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


;; ============================================================================
;; Keybindings
;; ============================================================================

;; SPC - → закомментить строку
(map! :leader
      :desc "Comment line" "-" #'comment-line)

;; C-Tab / C-S-Tab → переключение буферов
(map!
 :n "C-<tab>"   #'next-buffer
 :n "C-S-<tab>" #'previous-buffer)


;; ============================================================================
;; gptel + Ollama
;; ============================================================================

(after! gptel
  (setq gptel-backend
        (gptel-make-ollama
         "Ollama"
         :host "127.0.0.1:11434"
         :stream t
         :models '(qwen3:14b qwen2.5-coder:7b)))

  (setq gptel-model 'qwen3:14b)

  (setq gptel-system-message
        "Отвечай на русском языке. Код и технические термины оставляй на английском. Ты помощник по программированию."))

(defun my/gptel-get-buffer (name model)
  (let ((buf (gptel name)))
    (with-current-buffer buf
      (setq-local gptel-model model))
    buf))

(defun my/gptel-open-chat ()
  "Открыть основной чат (qwen3:14b)."
  (interactive)
  (pop-to-buffer
   (my/gptel-get-buffer "*gptel*" 'qwen3:14b)))

(defun my/gptel-open-fast-chat ()
  "Открыть быстрый чат (qwen2.5-coder:7b)."
  (interactive)
  (pop-to-buffer
   (my/gptel-get-buffer "*gptel-fast*" 'qwen2.5-coder:7b)))

(defun my/gptel-fast-question (question)
  "Быстрый вопрос в fast-чат."
  (interactive "sБыстрый вопрос: ")
  (let ((buf (my/gptel-get-buffer "*gptel-fast*" 'qwen2.5-coder:7b)))
    (with-current-buffer buf
      (goto-char (point-max))
      (unless (bolp) (insert "\n\n"))
      (insert question "\n\n")
      (gptel-send))
    (pop-to-buffer buf)))

(defun my/gptel-ask-region ()
  "Спросить про выделенный код."
  (interactive)
  (unless (use-region-p)
    (user-error "Сначала выдели код"))
  (let* ((text (buffer-substring-no-properties
                (region-beginning)
                (region-end)))
         (src-file (or (buffer-file-name) (buffer-name)))
         (src-mode (symbol-name major-mode))
         (buf (my/gptel-get-buffer "*gptel*" 'qwen3:14b)))
    (with-current-buffer buf
      (goto-char (point-max))
      (unless (bolp) (insert "\n\n"))
      (insert (format
               "Объясни этот код. Укажи возможные проблемы и предложи улучшения.\n\nФайл: %s\nРежим: %s\n\n"
               src-file src-mode))
      (insert text "\n\n")
      (gptel-send))
    (pop-to-buffer buf)))

(defun my/gptel-ask-buffer ()
  "Спросить про весь буфер."
  (interactive)
  (let* ((text (buffer-substring-no-properties (point-min) (point-max)))
         (src-file (or (buffer-file-name) (buffer-name)))
         (src-mode (symbol-name major-mode))
         (buf (my/gptel-get-buffer "*gptel-fast*" 'qwen3:14b)))
    (with-current-buffer buf
      (goto-char (point-max))
      (unless (bolp) (insert "\n\n"))
      (insert (format
               "Проанализируй этот файл. Объясни что он делает и предложи улучшения.\n\nФайл: %s\nРежим: %s\n\n"
               src-file src-mode))
      (insert text "\n\n")
      (gptel-send))
    (pop-to-buffer buf)))

;; SPC l <...> → llm команды
(map! :leader
      (:prefix ("l" . "llm")
       :desc "Chat (qwen3)"      "c" #'my/gptel-open-chat
       :desc "Fast chat (coder)" "f" #'my/gptel-open-fast-chat
       :desc "Fast question"     "q" #'my/gptel-fast-question
       :desc "Ask about region"  "r" #'my/gptel-ask-region
       :desc "Ask about buffer"  "b" #'my/gptel-ask-buffer))


;;; config.el ends here
