;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; Синхронизация PATH из shell (zsh) с Emacs
;; Нужно для GUI-Emacs чтобы видеть ~/.local/bin, ~/.npm-global/bin и т.д.
(package! exec-path-from-shell)

;; Jump to matching tag через %
(package! evil-matchit)

;; LLM chat (Ollama)
(package! gptel)
