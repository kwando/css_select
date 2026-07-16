# css_select

Library for parsing and matching simple CSS selectors against HTML elements.
A simple selector is a selector that does not contain combinators like `>`, `+`, `~`, ` `.

(They might be added in the future).

**This library is a work in progress.**

## Installation

```sh
gleam add css_select
```

## Usage

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
| Pseudo-classes                 | `:checked`                    | Matches pseudo-classes like `checked`, `disabled`, `selected`, `readonly`. |
| Attribute                      | `[href]`                      | Matches elements with the given attribute                                  |
| Attribute with value           | `[href="http://example.com"]` | Matches elements with the given attribute and exact value                  |
| Attribute with value prefix    | `[href^="http://"]`           | Matches elements with the given attribute and value prefix                 |
| Attribute with value suffix    | `[href$=".com"]`              | Matches elements with the given attribute and value suffix                 |
| Attribute with value inclusion | `[href*="example"]`           | Matches elements with the given attribute containing the value             |

Matching is case sensitive. Complex pseudo-classes that need more than one element to work (like `:nth-child`) are not supported.

## Development

```sh
gleam deps download   # Install dependencies
gleam test            # Run the tests
gleam format          # Format code
gleam run -m benchmark # Run parser benchmarks
```
