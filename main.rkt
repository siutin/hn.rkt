#lang racket

(require net/http-client)
(require json)
(require racket/gui)
(require racket/date)

(define frame (new frame%
                   [label "Hacker News"]
                   [width 1024]
                   [height 600]))
(send frame show #t)

(define frame-index-box-data empty)
(define frame-index-box
  (new list-box%
        (label #f)
        (parent frame)
        (choices frame-index-box-data)
        (style (list 'single
                      'column-headers))
        (columns (list "Title" "Point" "Comment" "Author" "Time"))))

(send frame-index-box set-column-width 0 650 500 824)
(send frame-index-box set-column-width 1 70 70 70)
(send frame-index-box set-column-width 2 80 80 80)
(send frame-index-box set-column-width 3 120 100 120)
(send frame-index-box set-column-width 4 50 50 80)

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

(define (hw/index)
  (map
      (lambda (item-id)
            (future (lambda () (hw/api/item item-id))))
      (hw/api/topstories)))

(begin
  (date-display-format 'iso-8601)
  (let* ([futures (take (hw/index) 5)]
         [count 0])
    (for/async ([f futures])
      (let* ([item (touch f)]
             [title (hash-ref item 'title "")]
             [by (hash-ref item 'by "")]
             [time (hash-ref item 'time "")]
             [dt-str (date->string (seconds->date time))]
             [score (hash-ref item 'score 0)]
             [descendants (hash-ref item 'descendants 0)])

        (send frame-index-box append title)
        (send frame-index-box set-string count (number->string score) 1)
        (send frame-index-box set-string count (number->string descendants) 2)
        (send frame-index-box set-string count by 3)
        (send frame-index-box set-string count dt-str 4)
        (set! count (+ count 1))
        (displayln (format "~a ~a ~a ~a ~a\n" title by time score descendants))))))
