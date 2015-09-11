(in-package titechfes)

(define-class game ()
  (window-size '(640 480))
  (map-size nil)
  (camera '(0 0))
  (player nil)
  (all-object nil)
  (mapchips nil)
  (enemies nil)
  (enemy-bullets nil)
  (bullets nil)
  (stage nil)
  (state :title)
  (statef nil)
  (keystate (make-instance 'titechfes-key)))

(defmethod initialize-instance :after ((game game) &key)
  (update-state game))

(defun run-state (game)
  (funcall (statef game) game))

(defun update-state (game)
  (setf (statef game)
	(case (state game)
	  (:title #'title-state)
	  (:game #'gaming-state)
	  (:over #'gameover-state))))

(defun change-state (sym game)
  (setf (state game) sym)
  (update-state game))