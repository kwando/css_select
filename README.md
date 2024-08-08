# css_select

Libary for parsing and matching simple CSS selectors against HTML elements.
A simple selector is a selector that does not contain combinators like `>`, `+`, `~`, ` `.

(They might be added in the future).

**This is lib is work in progress.**

```gleam
import css_select


let assert Ok(selector) = css_select.parse_simple_selector("div#wibble.wobble")
let element = #(
  "div",
  [
    #("class", "wobble wubble"),
    #("id", "wibble")
  ]
)

css_select.simple_match(element, selector)  // True
```

## Development

```sh
gleam test  # Run the tests
```
