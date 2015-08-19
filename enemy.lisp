(in-package titechfes)

(define-class enemy (gameobject)
  (vx 0)
  (vy 0)
  (hp 100)
  (muteki nil)
  (muteki-count 0))

(defmethod update-object :before ((enem enemy) game)
  (if (and (muteki enem) (zerop  (muteki-count enem)))
      (setf (muteki enem) nil)
      (decf (muteki-count enem))))

(defmethod draw-object :before ((enem enemy) game)
  (incf (get-x enem) (vx enem))
  (incf (get-y enem) (vy enem)))


(define-class enemy-bullet (gameobject)
  (vx 0)
  (vy 0)
  (atk 0))

(defmethod draw-object :before ((ebul enemy-bullet) game)
  (incf (get-x ebul) (vx ebul))
  (incf (get-y ebul) (vy ebul)))


;;aomura

(define-class aomura (enemy)
  (hp 200)
  (image-r (get-image :enemy-r))
  (image-l (get-image :enemy-l))
  (turn-routine 20)
  (jump-routine 75))

(defmethod update-object ((enem aomura) game)
  (with-slots (image-r image-l 
		       turn-routine jump-routine) enem
    (setf (image enem) (if (plusp (vx enem)) image-r image-l))
    (incf (vy enem) *gravity*)
    (whens ((zerop turn-routine)
	    (setf (vx enem) (- (vx enem))
		  turn-routine 75))
	   ((zerop jump-routine)
	    (setf (vy enem) -16
		  jump-routine 75)))
    (whens ((plusp turn-routine) (decf turn-routine))
	   ((plusp jump-routine) (decf jump-routine)))
    (when (<= (hp enem) 0) (setf (alive enem) nil))))

;;tullet

(define-class tullet-bullet (enemy-bullet)
  (image (get-image :ebul))
  (vx -2)
  (atk 10))

(define-class tullet (enemy)
  (image (get-image :enemy2-l))
  (shot-routine 100))

(defmethod update-object ((enem tullet) game)
  (setf (vx enem) 0
	(vy enem) 0)
  (if (zerop (shot-routine enem))
      (let ((ebul (make-instance 'tullet-bullet)))
	(setf (get-x ebul) (- (get-x enem)
			      (truncate (width enem) 2)
			      (truncate (width ebul) 2))
	      (get-y ebul) (get-y enem))
	(push ebul (all-object game))
	(push ebul (enemy-bullets game))
	(setf (shot-routine enem) 100))
      (decf (shot-routine enem)))
  (when (<= (hp enem) 0) (setf (alive enem) nil)))
