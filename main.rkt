#lang racket

(require net/http-client)
(require json)

(define (hw/base/api-get url)
  (define-values (status headers in)
    (http-sendrecv
      "hacker-news.firebaseio.com"
      url
      #:ssl? #t
      #:method "GET"))        
  (let ([s (string->jsexpr (port->string in))])
    (close-input-port in)
    s))

(define (hw/api/topstories)
  (hw/base/api-get "/v0/topstories.json"))

(hw/api/topstories)
