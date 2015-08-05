;;;; titechfes.asd

(asdf:defsystem #:titechfes
  :description "Describe titechfes here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :serial t
  :components ((:file "package")
	       (:file "macro")
	       (:file "global")
	       (:file "load-image")
	       (:file "loadfile")
	       (:file "key")
	       (:file "gameobject")
	       (:file "player")
	       (:file "map")
               (:file "titechfes"))
  :depends-on (:lispbuilder-sdl :split-sequence :iterate))

