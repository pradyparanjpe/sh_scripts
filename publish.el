(require 'ox-publish)
(require 'ox-man)
(dolist (pub-dir '("bin/" "share/man/" "lib/"))
  (mkdir (format "pss/%s" pub-dir) t))
(mkdir "docs/" t)
(defun org-man-publish-to-man (plist filename pub-dir)
  "Publish an org file to MAN-PAGE.

FILENAME is the filename of the Org file to be published.  PLIST
is the property list for the given project.  PUB-DIR is the
publishing directory.

Return output file name."
  (let* ((org-section (or (plist-get plist :section-id) "1"))
         (man-dir (format "%s/man%s" pub-dir org-section)))
    (org-publish-org-to
     'man
     filename
     (concat "." org-section)
     plist
     man-dir)))

(setq org-publish-project-alist
      (list
       (list "org-man"
             :base-directory "."
             :base-extension "org"
             :publishing-directory "pss/share/man/"
             :recursive t
             :publishing-function 'org-man-publish-to-man
             :headline-levels 4
             :auto-preamble t)
       (list "org-notes"
             :base-directory "."
             :base-extension "org"
             :publishing-directory "docs/"
             :recursive t
             :publishing-function 'org-html-publish-to-html
             :headline-levels 4
             :auto-preamble t)
       (list "org-static"
             :base-directory "."
             :base-extension
             "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
             :publishing-directory "docs/"
             :recursive t
             :publishing-function 'org-publish-attachment)
       (list "org" :components
             '("org-notes" "org-static" "org-man"))))
(org-publish "org" t)
(dolist (litorg (directory-files "." nil ".org"))
  (org-babel-tangle-file (format "%s" litorg)))
