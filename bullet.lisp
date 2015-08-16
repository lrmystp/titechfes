(in-package titechfes)

(define-class bullet (gameobject)
  (vx 0)
  (vy 0)
  (atk 0)
  (cool-time 0))

(definteract-method collide (bul bullet) (chip wall)
  (when (rect-collide bul chip) (setf (alive bul) nil)))


;;;knife
(define-class knife (bullet)
  (image (get-image :bullet))
  (life 20)
  (atk 20)
  (cool-time 10))

(defmethod update-object ((bul knife) game)
  (decf (life bul))
  (when (zerop (life bul)) (setf (alive bul) nil)))

(defmethod draw-object :before ((bul knife) game)
  (incf (get-x bul) (vx bul))
  (incf (get-y bul) (vy bul)))

(defun shot-knife (ply game)
  (let ((bul (make-instance 'knife :vx (if (dir-right ply) 7 -7))))
    (setf (get-x bul) (if (dir-right ply)
			  (+ (get-x ply)
			     (truncate (width ply) 2) 
			     (truncate (width bul) 2))
			  (- (get-x ply)
			     (truncate (width ply) 2) 
			     (truncate (width bul) 2)))
	  (get-y bul) (get-y ply))
    (push bul (all-object game))
    (push bul (bullets game))
    (setf (shot-cool ply) (cool-time bul))))
