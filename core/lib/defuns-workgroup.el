;;; defuns-workgroup.el

;;;###autoload
(defun narf/wg-helm-switch-to-workgroup (name)
  (wg-switch-to-workgroup (wg-get-workgroup name)))

;;;###autoload
(defun narf:helm-wg ()
  (interactive)
  (require 'helm)
  (helm :sources '(narf/helm-source-wg)))

;;;###autoload
(defun narf/wg-projectile-switch-project ()
  (let ((workgroup-name (file-name-nondirectory (directory-file-name (narf/project-root)))))
    (wg-create-workgroup workgroup-name t)
    (helm-projectile-find-file)))

;;;###autoload (autoload 'narf:save-session "defuns-workgroup" nil t)
(evil-define-command narf:save-session (&optional bang session-name)
  (interactive "<!><a>")
  (if session-name
      (wg-save-session-as (concat wg-workgroup-directory session-name) (not bang))
    (wg-save-session)))

;;;###autoload (autoload 'narf:load-session "defuns-workgroup" nil t)
(evil-define-command narf:load-session (&optional bang session-name)
  (interactive "<!><a>")
  (wg-open-session (if session-name
                       (concat wg-workgroup-directory session-name)
                     wg-session-file)))

;;;###autoload (autoload 'narf:workgroup-new "defuns-workgroup" nil t)
(evil-define-command narf:workgroup-new (bang name)
  (interactive "<!><a>")
  (unless name
    (user-error "No name specified for new workgroup"))
  (if bang
      (wg-clone-workgroup (wg-current-workgroup) name)
    (wg-create-workgroup name t)))

;;;###autoload (autoload 'narf:workgroup-rename "defuns-workgroup" nil t)
(evil-define-command narf:workgroup-rename (new-name)
  (interactive "<a>")
  (wg-rename-workgroup new-name))

;;;###autoload
(defun narf:kill-other-workgroups ()
  "Kill all other workgroups."
  (interactive)
  (let (workgroup (wg-current-workgroup))
    (dolist (w (wg-workgroup-list))
      (unless (wg-current-workgroup-p w)
        (wg-kill-workgroup w)))))

;;;###autoload
(defun narf:workgroup-display ()
  (interactive)
  (when (wg-current-session t)
    (message (wg-display-internal
              (lambda (workgroup index)
                (if (not workgroup) wg-nowg-string
                  (wg-element-display
                   workgroup
                   (format "%d %s" index (wg-workgroup-name workgroup))
                   'wg-current-workgroup-p
                   'wg-previous-workgroup-p)))
              (wg-workgroup-list)))))

;;;###autoload (autoload 'narf:switch-to-workgroup-left "defuns-workgroup" nil t)
(evil-define-command narf:switch-to-workgroup-left (count)
  (interactive "<c>")
  (if count
      (wg-switch-to-workgroup-at-index (1- count))
    (wg-switch-to-workgroup-left)))

;;;###autoload (autoload 'narf:switch-to-workgroup-right "defuns-workgroup" nil t)
(evil-define-command narf:switch-to-workgroup-right (count)
  (interactive "<c>")
  (if count
      (wg-switch-to-workgroup-at-index (1- count))
    (wg-switch-to-workgroup-right)))

;;;###autoload
(defun narf:switch-to-workgroup-at-index (index)
  (interactive)
  (wg-switch-to-workgroup-at-index index)
  (narf:workgroup-display))

(provide 'defuns-workgroup)
;;; defuns-workgroup.el ends here
