#lang racket

(require net/http-client)
(require json)
(require racket/gui)
(require racket/date)

(define frame (new frame%
                   [label "Hacker News"]
                   [width 1024]
                   [height 600]
                   [border 2]))
(send frame show #t)

(define (add-frame-message-box model parent-object)
  (let ([panel (new vertical-pane%
                  (parent parent-object)
                  [alignment (list 'left 'top)])])
    (new message%
     (parent panel)
     [auto-resize #t]
     [font small-control-font]
     (label (format "@~a" (hash-ref model 'author ""))))
    (new message%
     (parent panel)
     [auto-resize #t]
     (label (hash-ref model 'title "")))
    (new message%
     (parent panel)
     [auto-resize #t]
     [font small-control-font]
     (label (hash-ref model 'url "")))
    panel))

(define hc (http-conn))
(http-conn-open!
  hc
  "hacker-news.firebaseio.com"
  #:ssl? #t
  #:port 443
  #:auto-reconnect? #t)

(define (hw/base/api-get url)
  (define-values (status headers in)
      (http-conn-sendrecv!
        hc
        (format "https://hacker-news.firebaseio.com/~a" url)
        #:method "GET"))
  (let ([s (string->jsexpr (port->string in))])
    (close-input-port in)
    s))

(define (hw/api/topstories)
  (hw/base/api-get "/v0/topstories.json"))

(define (hw/api/item id)
  (hw/base/api-get (format "/v0/item/~a.json" id)))

(define (hw/show item-id)
  (future (lambda () (hw/api/item item-id))))

(begin
  (date-display-format 'iso-8601)
  (let* ([f (hw/show 21534283)]
         [item (touch f)]
         [h (make-hasheq)]
         [title (hash-ref item 'title "")]
         [by (hash-ref item 'by "")]
         [time (hash-ref item 'time "")]
         [posted-at (date->string (seconds->date time))]
         [score (hash-ref item 'score 0)]
         [descendants (hash-ref item 'descendants 0)]
         [url (hash-ref item 'url "")])
      (hash-set! h 'title title)
      (hash-set! h 'author by)
      (hash-set! h 'posted-at posted-at)
      (hash-set! h 'point score)
      (hash-set! h 'coment-count descendants)
      (hash-set! h 'url url)
      (add-frame-message-box h frame)
      (displayln (format "~a ~a ~a ~a ~a\n" title by time score descendants))))
