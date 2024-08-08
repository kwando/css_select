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

## Supported selectors

| Selector                       | Example                       | Description                                                                |
| ------------------------------ | ----------------------------- | -------------------------------------------------------------------------- |
| Type                           | `div`                         | Matches elements of the given type                                         |
| ID                             | `#wibble`                     | Matches elements with the given ID                                         |
| Class                          | `.wibble`                     | Matches elements with the given class                                      |
| Psuedo-classes                 | `:checked`                    | Matches psuedo classes like `checked`, `disabled`, `selected`, `readonly`. |
| Attribute                      | `[href]`                      | Matches elements with the given attribute                                  |
| Attribute with value           | `[href="http://example.com"]` | Matches elements with the given attribute and value prefix                 |
| Attribute with value prefix    | `[href^="http://"]`           | Matches elements with the given attribute and value suffix                 |
| Attribute with value inclusion | `[href*="example"]`           | Matches elements with the given attribute and includes the value           |

The matching is case senssitive and it does support complex psuedo classes like
that needs more than one element to work.

## Development

```sh
gleam test  # Run the tests
```
