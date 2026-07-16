import gleam/list
import gleam/string

/// The element type part of a selector.
pub type TagSelector {
  /// Matches any element type.
  Any
  /// Matches elements of the given tag name.
  Tag(String)
}

/// A single attribute-based selector component.
pub type AttributeSelector {
  /// Matches elements with the given ID attribute.
  Id(String)
  /// Matches elements with the given class.
  Class(String)
  /// Matches elements that have the given attribute.
  AttributeExists(String)
  /// Matches elements where the attribute equals the given value.
  AttributeEqual(String, String)
  /// Matches elements where the attribute value starts with the given prefix.
  AttributePrefix(String, String)
  /// Matches elements where the attribute value ends with the given suffix.
  AttributeSuffix(String, String)
  /// Matches elements where the attribute value contains the given substring.
  AttributeIncludes(String, String)
  /// Matches elements with the given pseudo-class.
  Psuedo(String)
}

/// A complete simple CSS selector, consisting of a tag selector
/// and zero or more attribute selectors.
pub type Selector {
  ElementSelector(TagSelector, List(AttributeSelector))
}

/// Convert a `Selector` back to its CSS selector string representation.
///
/// ```gleam
/// let assert Ok(selector) = css_select.parse_simple_selector("div#foo.bar")
/// css_select.to_string(selector)
/// // -> "div#foo.bar"
/// ```
pub fn to_string(selector: Selector) -> String {
  let ElementSelector(tag, attrs) = selector

  let t = case tag {
    Any -> ""
    Tag(tag) -> tag
  }

  let attr_matches =
    list.map(attrs, fn(attr) {
      case attr {
        Id(id) -> "#" <> id
        Class(class) -> "." <> class
        Psuedo(str) -> ":" <> str
        AttributeExists(k) -> "[" <> k <> "]"
        AttributeEqual("id", v) -> "#" <> v
        AttributeEqual(k, v) -> "[" <> k <> "=" <> v <> "]"
        AttributePrefix(k, v) -> "[" <> k <> "=" <> v <> "]"
        AttributeSuffix(k, v) -> "[" <> k <> "=" <> v <> "]"
        AttributeIncludes(k, v) -> "[" <> k <> "=" <> v <> "]"
      }
    })
    |> string.join("")

  t <> attr_matches
}
