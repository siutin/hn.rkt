#lang racket

(require net/http-client)
(require json)
(require racket/gui)

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
        (columns (list "Title" "Author"))))

(send frame-index-box set-column-width 0 900 500 1024)
(send frame-index-box set-column-width 1 100 100 150)

(let ([hc (http-conn)])
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
    (let* ([futures (take (hw/index) 5)]
           [count 0])
      (for/async ([f futures])
        (let* ([item (touch f)]
               [title (hash-ref item 'title "")]
               [by (hash-ref item 'by "")])
          (send frame-index-box append title)
          (send frame-index-box set-string count by 1)
          (set! count (+ count 1))
          (displayln (format "~a ~a\n" title by)))))))
      

