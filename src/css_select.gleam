import css_select/internal/parser
import css_select/simple_matcher

/// Parse a CSS selector string into a `Selector`.
///
/// Returns an error if the input is not a valid simple selector
/// (no combinators like `>`, `+`, `~`, ` `).
///
/// ```gleam
/// css_select.parse_simple_selector("div#foo.bar")
/// // -> Ok(ElementSelector(Tag("div"), [Id("foo"), Class("bar")]))
/// ```
pub const parse_simple_selector = parser.parse_simple_selector

/// Check if an HTML element matches a parsed `Selector`.
///
/// The element is a tuple of the tag name and a list of attribute
/// key-value pairs.
///
/// ```gleam
/// let element = #("div", [#("class", "foo bar"), #("id", "wibble")])
/// let assert Ok(selector) = css_select.parse_simple_selector("div#foo")
/// css_select.simple_match(element, selector)
/// // -> True
/// ```
pub const simple_match = simple_matcher.match
