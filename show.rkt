#lang racket

(require net/http-client)
(require json)
(require racket/gui)
(require racket/date)
(require "string-split.rkt")

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
  (let* ([item (hw/api/item item-id)]
         [kids (hash-ref item 'kids empty)]
         [childs (map
                   (lambda (kid) (hw/api/item kid))
                   kids)])
    (append (list item) childs)))

(begin
  (date-display-format 'iso-8601)
  (let* ([comments (hw/show 21534283)])
    (for/list ([comment comments])
      (let* ([item comment]
             [h (make-hasheq)]
             [title (hash-ref item 'title "")]
             [by (hash-ref item 'by "")]
             [time (hash-ref item 'time "")]
             [posted-at (date->string (seconds->date time))]
             [score (hash-ref item 'score 0)]
             [descendants (hash-ref item 'descendants 0)]
             [url (hash-ref item 'url "")]
             [kids (hash-ref item 'kids '())]
             [data-text (hash-ref item 'text "")]
             [data-title-or-text (if (non-empty-string? title)
                                     title
                                     data-text)])
        (displayln (format "@~a\n" by))
        (displayln (format "#~a ~a ~a ~a ~a\n" time score descendants url kids))
        (for/list ([t (string-split-by-length data-text #:size 100)])
          (displayln (format ">~a\n" t)))))))

      
