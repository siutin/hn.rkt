#lang racket

(define s "Yeah, this is very cool, and I’m surprised I hadn’t heard about it. Though I think we’re finally at the point where async python web frameworks and tools are great, to the point where I’m no longer jonesing for something better like I used to, both in terms of performance and usability.<p>Yeah, aiohttp was where it all really began, and sanic is nice for recovering Flask users, but if you really want to see performance and momentum, check out Starlette (<a href=\"https:&#x2F)]));&#x2F;www.starlette.io\" rel=\"nofollow\">https:&#x2F;&#x2F;www.starlette.io</a>) and FastAPI (<a href=\"https:&#x2F;&#x2F;fastapi.tiangolo.com\" rel=\"nofollow\">https:&#x2F;&#x2F;fastapi.tiangolo.com</a>) which is built on top of Starlette and is very clever and probably the most rapid way to build an API that I’ve ever seen. In most practical tests Starlette also outperforms aiohttp&#x2F;etc. by a factor of 5, and the ASGI spec it’s built on is the actual successor to WGSI and the future of python web programming.<p>Things have come a very long way the last handful of years, and there are many great options. Nice to see yet another one.")

(define (partition s)
  (let ([size (if (> (string-length s) 300) 300 (string-length s))])
   (list
     (substring s 0 size)
     (substring s size (string-length s)))))

(define (split str)  
  (let* ([item (partition str)]
         [a (car item)]
         [b (cadr item)])
    (if (= (string-length b) 0)
        (list a)
        (append (list a) (split b)))))

(split s)