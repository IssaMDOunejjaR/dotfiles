;; extends

;; x- directives: inject JS into the value
(attribute
  (attribute_name) @_attr
  (quoted_attribute_value
    (attribute_value) @injection.content)
  (#lua-match? @_attr "^x%-")
  (#set! injection.language "javascript"))

;; @ shorthand (x-on): inject JS into the value
(attribute
  (attribute_name) @_attr
  (quoted_attribute_value
    (attribute_value) @injection.content)
  (#lua-match? @_attr "^@")
  (#set! injection.language "javascript"))

;; : shorthand (x-bind): inject JS into the value
(attribute
  (attribute_name) @_attr
  (quoted_attribute_value
    (attribute_value) @injection.content)
  (#lua-match? @_attr "^:")
  (#set! injection.language "javascript"))
