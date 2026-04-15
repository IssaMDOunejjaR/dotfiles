; Alpine.js — inject JavaScript into all x-* directive attribute values.
; Full directive list: https://alpinejs.dev/directives
(((attribute_name) @_attr_name
  (#any-of? @_attr_name
    "x-data"
    "x-init"
    "x-show"
    "x-bind"
    "x-on"
    "x-text"
    "x-html"
    "x-model"
    "x-modelable"
    "x-for"
    "x-transition"
    "x-effect"
    "x-ignore"
    "x-ref"
    "x-cloak"
    "x-teleport"
    "x-if"
    "x-id"))
 .
 (quoted_attribute_value
   (attribute_value) @injection.content)
 (#set! injection.language "javascript"))

; @event shorthand (x-on:click → @click)
(((attribute_name) @_attr_name
  (#lua-match? @_attr_name "^@[a-zA-Z]"))
 .
 (quoted_attribute_value
   (attribute_value) @injection.content)
 (#set! injection.language "javascript"))

; :binding shorthand (x-bind:class → :class)
(((attribute_name) @_attr_name
  (#lua-match? @_attr_name "^:[a-zA-Z]"))
 .
 (quoted_attribute_value
   (attribute_value) @injection.content)
 (#set! injection.language "javascript"))
