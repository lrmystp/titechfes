(in-package titechfes)

(defgeneric collide (obj-a obj-b game))
(defcollide (obj-a gameobject) (obj-b gameobject))
;;player-behavior
(defcollide (ply player) (chip wall)
  (with-slots (vx vy
		  in-air jump-cool
		  dash-ok while-dash) ply
    (sdl:with-rectangle (chip-rec (sdl:rectangle 
				   :x (get-left (get-x chip) 
						(width chip)) 
				   :y (get-top (get-y chip)
					       (height chip))
				   :w (width chip)
				   :h (height chip)))
      ;;horizontal
      (sdl:with-rectangle (ply-x-rec (sdl:rectangle 
				      :x (get-left (+ (get-x ply) vx)
						   (width ply))
				      :y (get-top (get-y ply) 
						  (height ply))
				      :w (width ply)
				      :h (height ply)))
	(when (rect-collision-judge chip-rec ply-x-rec)
	  (if (plusp vx)
	      (setf vx (- (get-x chip) 
			  (+ (truncate (width chip) 2)
			     (truncate (width ply) 2))
			  (get-x ply)))
	      (setf vx (- (get-x chip)
			  (- (+ (truncate (width chip) 2)
				(truncate (width ply) 2))) 
			  (get-x ply))))))
      ;;vertical
      (sdl:with-rectangle (ply-y-rec (sdl:rectangle
				      :x (get-left (get-x ply)
						   (width ply))
				      :y (get-top (+ (get-y ply) vy)
						  (height ply))
				      :w (width ply)
				      :h (height ply)))
	(when (rect-collision-judge chip-rec ply-y-rec)
	  (if (plusp vy)
	      (progn (setf vy (- (get-y chip)
				 (+ (truncate (height chip) 2)
				    (truncate (height ply) 2))
				 (get-y ply)))
		     (whens (in-air
			     (setf in-air nil
				   jump-cool 10))
			    ((and (not dash-ok) (not while-dash))
			     (setf dash-ok t))))
	      (setf vy (- (get-y chip)
			  (- (+ (truncate (height chip) 2)
				(truncate (height ply) 2)))
			  (get-y ply)))))))))

(defcollide (ply player) (ebul enemy-bullet)
  (when (rect-collide ply ebul)
    (when (not (muteki ply))
      (decf (hp ply) (atk ebul))
      (setf (muteki ply) t
	    (muteki-count ply) *player-mutekitime*))
    (setf (alive ebul) nil)))

;;enemy-behavior
(defcollide (enem enemy) (chip wall)
  (with-slots (vx vy) enem
    (sdl:with-rectangle (chip-rec (sdl:rectangle 
				   :x (get-left (get-x chip) 
						(width chip)) 
				   :y (get-top (get-y chip)
					       (height chip))
				   :w (width chip)
				   :h (height chip)))
      ;;horizontal
      (sdl:with-rectangle (enem-x-rec (sdl:rectangle 
				      :x (get-left (+ (get-x enem) vx)
						   (width enem))
				      :y (get-top (get-y enem) 
						  (height enem))
				      :w (width enem)
				      :h (height enem)))
	(when (rect-collision-judge chip-rec enem-x-rec)
	  (if (plusp vx)
	      (setf vx (- (get-x chip) 
			  (+ (truncate (width chip) 2)
			     (truncate (width enem) 2))
			  (get-x enem)))
	      (setf vx (- (get-x chip)
			  (- (+ (truncate (width chip) 2)
				(truncate (width enem) 2))) 
			  (get-x enem))))))
      ;;vertical
      (sdl:with-rectangle (enem-y-rec (sdl:rectangle 
				       :x (get-left (get-x enem)
						    (width enem))
				       :y (get-top (+ (get-y enem) vy) 
						   (height enem))
				       :w (width enem)
				       :h (height enem)))
	(when (rect-collision-judge chip-rec enem-y-rec)
	  (if (plusp vy)
	      (setf vy (- (get-y chip)
			  (+ (truncate (height chip) 2)
			     (truncate (height enem) 2))
			  (get-y enem)))
	      (setf vy (- (get-y chip)
			  (- (+ (truncate (height chip) 2)
				(truncate (height enem) 2)))
			  (get-y enem)))))))))

;;enemy-bullet-behavior
(defcollide (ebul enemy-bullet) (chip wall)
  (when (rect-collide ebul chip) (setf (alive ebul) nil)))

;;bullet-behavior
(defcollide (bul bullet) (chip wall)
  (when (rect-collide bul chip) (setf (alive bul) nil)))

(defcollide (enem enemy) (bul bullet)
  (when (rect-collide enem bul)
    (when (not (muteki enem))
      (decf (hp enem) (atk bul))
      (setf (muteki enem) t
	    (muteki-count enem) *enemy-mutekitime*))
    (setf (alive bul) (penetrate bul))))

(defcollide (bul penetrate) (chip wall))

(defcollide (bul bomb) (chip wall)
  (when (and (rect-collide bul chip) 
	     (equal (state bul) "bomb"))
    (make-explosion bul)))

(defcollide (enem enemy) (bul bomb)
  (when (rect-collide enem bul)
    (cond ((equal (state bul) "bomb") 
	   (make-explosion bul))
	  ((equal (state bul) "explosion")
	   (decf (hp enem) (atk bul))))))

(defcollide (bul boomerang) (chip wall)
  (when (and (rect-collide bul chip) 
	     (equal (state bul) "go"))
    (setf (state bul) "back")))

(defcollide (bul boomerang) (ply player)
  (when (and (rect-collide bul ply)
	     (equal (state bul) "back"))
    (setf (alive bul) nil
	  (shot-cool ply) (cool-time bul))))

(defcollide (item item) (p player)
  (when (rect-collide item p) (kill item)))

(defcollide (item weapon-item) (p player)
  (when (rect-collide item p)
    (change-bullet (weapon item) p)
    (call-next-method)))
