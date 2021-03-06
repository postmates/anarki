(test-iso "read-header works"
  '("a: b" "c: d")
  (pipe-to (read-header)
    (prrn "a: b")
    (prrn "c: d")
    (prrn)
    (prrn "body")
    (prrn "body2")))

(test-iso "read-header works - 2"
  '("a: b" "c: d")
  (pipe-to (read-header)
    (prn "a: b")
    (prn "c: d")
    (prn)
    (prn "body")
    (prn "body2")))

(test-iso "split-header works"
  '("content-type" "multipart/form-data; boundary=aaaabbbb")
  (split-header "Content-Type: multipart/form-data; boundary=aaaabbbb"))

(= empty-sym* (sym ""))

(test-iso "parse-header works"
  (obj op empty-sym* type 'get
       "host" "localhost:8080"
       "user-agent" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:28.0) Gecko/20100101 Firefox/28.0"
       "accept" "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
       "accept-language" "en-US,en;q=0.5"
       "accept-encoding" "gzip, deflate"
       "dnt" "1"
       "cookie" "user=Qr9lN3Vn"
       "connection" "keep-alive"
       "cache-control" "max-age=0")
  (pipe-to (parse-header)
    (prrn "GET / HTTP/1.1")
    (prrn "Host: localhost:8080")
    (prrn "User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:28.0) Gecko/20100101 Firefox/28.0")
    (prrn "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
    (prrn "Accept-Language: en-US,en;q=0.5")
    (prrn "Accept-Encoding: gzip, deflate")
    (prrn "DNT: 1")
    (prrn "Cookie: user=Qr9lN3Vn")
    (prrn "Connection: keep-alive")
    (prrn "Cache-Control: max-age=0")))

(test-iso "read-header works"
  (list "GET / HTTP/1.1"
        "Host: localhost:8080"
        "User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:28.0) Gecko/20100101 Firefox/28.0"
        "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
        "Accept-Language: en-US,en;q=0.5"
        "Accept-Encoding: gzip, deflate"
        "DNT: 1"
        "Cookie: user=Qr9lN3Vn"
        "Connection: keep-alive"
        "Cache-Control: max-age=0")
  (pipe-to (read-header)
    (prrn "GET / HTTP/1.1")
    (prrn "Host: localhost:8080")
    (prrn "User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:28.0) Gecko/20100101 Firefox/28.0")
    (prrn "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
    (prrn "Accept-Language: en-US,en;q=0.5")
    (prrn "Accept-Encoding: gzip, deflate")
    (prrn "DNT: 1")
    (prrn "Cookie: user=Qr9lN3Vn")
    (prrn "Connection: keep-alive")
    (prrn "Cache-Control: max-age=0")))

(test-iso "parse-cmd works"
  '((type get)
    (op p1)
    (args (("foo" "bar") ("ug" ""))))
  (parse-cmd "GET /p1?foo=bar&ug"))

;; -----------------------------57651155441074198547161975
;; Content-Disposition: form-data; name="fnid"
;;
;; 2iJaTziJtr
;; -----------------------------57651155441074198547161975
;; Content-Disposition: form-data; name="someField"
;;
;; 33
;; -----------------------------57651155441074198547161975--
(test-iso "parse-multipart-args works"
  `(("a" ,(obj "contents" "34")) ("b" ,(obj "contents" "209")))
  (parse-multipart-args "--abc" (instring "\r\n--abc\r\nContent-Disposition: form-data; name=\"a\"\r\n\r\n34\r\n--abc\r\nContent-Disposition: form-data; name=\"b\"\r\n\r\n209\r\n--abc--\r\n")))

; currently fails; how to include binary data in string literals?
(test-iso "currently fails: parse-multipart-args returns lists of ints for non-ascii data"
  `(("a" ,(obj "contents" "34")) ("b" ,(obj "contents" list.128))) ; \x80 in decimal
  (parse-multipart-args "--abc" (instring "\r\n--abc\r\nContent-Disposition: form-data; name=\"a\"\r\n\r\n34\r\n--abc\r\nContent-Disposition: form-data; name=\"b\"\r\n\r\n\x80\r\n--abc--\r\n")))

; just checks for errors at the moment
(wipe ranked-stories*)
(def run-request (msg input-string)
  (prn "- " msg)
  (tostring
     (fromstring input-string
       (handle-request-thread (stdin) (stdout) "no ip"))))

(run-request "simple request"
"GET / HTTP/1.1

")

(run-request "empty request"
"

")
