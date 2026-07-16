import css_select/selector as css
import splitter

const token_delims = [".", "#", "[", ":"]

const attr_delims = ["^=", "$=", "*=", "=", "]"]

const quote_delims = ["\""]

/// A reusable parser instance with pre-built splitters.
///
/// Create with `new()` and pass to `parse_simple_selector_with_parser/2`
/// for best performance when parsing many selectors.
pub opaque type Parser {
  Parser(
    token_splitter: splitter.Splitter,
    attr_splitter: splitter.Splitter,
    quote_splitter: splitter.Splitter,
  )
}

/// Create a new parser instance with pre-built splitters.
///
/// Use this when parsing multiple selectors to avoid the overhead
/// of creating splitters on each call.
///
/// ```gleam
/// let parser = parser.new()
/// parser.parse_simple_selector_with_parser(parser, "div#foo")
/// parser.parse_simple_selector_with_parser(parser, ".bar")
/// ```
pub fn new() -> Parser {
  Parser(
    token_splitter: splitter.new(token_delims),
    attr_splitter: splitter.new(attr_delims),
    quote_splitter: splitter.new(quote_delims),
  )
}

/// Error returned when parsing fails.
pub type ParseError {
  ParseError(String)
}

/// Parse a CSS selector string into a `Selector`.
///
/// Creates a new parser internally on each call. For repeated
/// parsing, use `parse_simple_selector_with_parser` with a
/// pre-created `Parser` for better performance.
///
/// ```gleam
/// parser.parse_simple_selector("div#foo.bar")
/// // -> Ok(ElementSelector(Tag("div"), [Id("foo"), Class("bar")]))
/// ```
pub fn parse_simple_selector(
  input: String,
) -> Result(css.Selector, ParseError) {
  parse_simple_selector_with_parser(new(), input)
}

/// Parse a CSS selector string using a pre-created `Parser`.
///
/// This avoids the overhead of creating splitters on each call.
/// Create a `Parser` once with `new()` and reuse it for all parsing.
pub fn parse_simple_selector_with_parser(
  parser: Parser,
  input: String,
) -> Result(css.Selector, ParseError) {
  let #(tag_part, rest) = splitter.split_before(parser.token_splitter, input)

  let tag = case tag_part {
    "" -> css.Any
    _ -> css.Tag(tag_part)
  }

  let attrs = parse_attrs(rest, parser)
  Ok(css.ElementSelector(tag, attrs))
}

fn parse_attrs(input: String, parser: Parser) -> List(css.AttributeSelector) {
  case input {
    "" -> []
    "." <> rest -> {
      let #(name, remaining) =
        splitter.split_before(parser.token_splitter, rest)
      [css.Class(name), ..parse_attrs(remaining, parser)]
    }
    "#" <> rest -> {
      let #(name, remaining) =
        splitter.split_before(parser.token_splitter, rest)
      [css.Id(name), ..parse_attrs(remaining, parser)]
    }
    ":" <> rest -> {
      let #(name, remaining) =
        splitter.split_before(parser.token_splitter, rest)
      [css.Psuedo(name), ..parse_attrs(remaining, parser)]
    }
    "[" <> rest -> {
      let #(attr, remaining) = parse_bracket_attr(rest, parser)
      [attr, ..parse_attrs(remaining, parser)]
    }
    _ -> []
  }
}

fn parse_bracket_attr(
  input: String,
  parser: Parser,
) -> #(css.AttributeSelector, String) {
  let #(key, op_and_rest) = splitter.split_before(parser.attr_splitter, input)

  case op_and_rest {
    "]" <> remaining -> #(css.AttributeExists(key), remaining)
    "^=" <> rest -> parse_attr_with_op(css.AttributePrefix, key, rest, parser)
    "$=" <> rest -> parse_attr_with_op(css.AttributeSuffix, key, rest, parser)
    "*=" <> rest -> parse_attr_with_op(css.AttributeIncludes, key, rest, parser)
    "=" <> rest -> parse_attr_with_op(css.AttributeEqual, key, rest, parser)
    _ -> #(css.AttributeExists(key), op_and_rest)
  }
}

fn parse_attr_with_op(
  constructor: fn(String, String) -> css.AttributeSelector,
  key: String,
  input: String,
  parser: Parser,
) -> #(css.AttributeSelector, String) {
  let #(value, after_value) = parse_attr_value(input, parser)

  case after_value {
    "]" <> remaining -> #(constructor(key, value), remaining)
    _ -> #(constructor(key, value), after_value)
  }
}

fn parse_attr_value(input: String, parser: Parser) -> #(String, String) {
  case input {
    "\"" <> rest -> {
      let #(parts, _, remaining) = splitter.split(parser.quote_splitter, rest)
      case remaining {
        "\"" <> after -> #(parts, after)
        _ -> #(parts, remaining)
      }
    }
    _ -> splitter.split_before(parser.attr_splitter, input)
  }
}
