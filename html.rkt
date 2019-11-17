#lang racket
 (require html-parsing)

(define result (html->xexp
   (string-append
    "<html><head><title></title><title>whatever</title></head>"
    "<body> <a href=\"url\">link</a><p align=center>"
    "<ul compact style=\"aa\"> <p>BLah<!-- comment <comment> -->"
    " <i> italic <b> bold <tt> ened</i> still &lt; bold </b>"
    "</body><P> But not done yet...")))

(define (recursive p)
  (if (and (list? p) (not (empty? p)))
      (let* ([a (first p)]
             [r (rest p)])
        (displayln (format "a=~a r=~a\n" a r))
        (if (symbol? a)
            (hash a (if (= (length r) 1)
                             (first r)
                             (recursive r)))
            (map recursive p)))
      p))


; (define h (recursive (cdr result)))

; (define (recursive-display s [depth 0])
;   (for/list ([i (length s)]
;              [r s])
;     (if (or (symbol? r) (string? r))
;       (displayln (format "[~a]~a:~a~a" i 
;                                       (if (symbol? r) "KEY" "VAL")
;                                       (make-string depth #\>) 
;                                       r))
;       (recursive-display r (+ depth 1)))))

; (recursive-display result)

(define (build-model s h [depth 0])
  (for/list ([i (length s)]
             [r s])
    (if (or (symbol? r) (string? r))      
      (let* ([f "[~a][~a]~a:~a~a"])        
        (displayln (format f
                           i 
                           depth
                           (if (symbol? r) "KEY" "VAL")
                           (make-string depth #\>) 
                           r)))        
      (build-model r h (+ depth 1)))))

(define m (make-hasheq))
(build-model result m)
