import css_select/selector as css
import splitter

const token_delims = [".", "#", "[", ":"]

const attr_delims = ["^=", "$=", "*=", "=", "]"]

pub type ParseError {
  ParseError(String)
}

pub fn parse_simple_selector(
  input: String,
) -> Result(css.Selector, ParseError) {
  let splitter = splitter.new(token_delims)
  let #(tag_part, rest) = splitter.split_before(splitter, input)

  let tag = case tag_part {
    "" -> css.Any
    _ -> css.Tag(tag_part)
  }

  let attrs = parse_attrs(rest, splitter)
  Ok(css.ElementSelector(tag, attrs))
}

fn parse_attrs(
  input: String,
  splitter: splitter.Splitter,
) -> List(css.AttributeSelector) {
  case input {
    "" -> []
    "." <> rest -> {
      let #(name, remaining) = splitter.split_before(splitter, rest)
      [css.Class(name), ..parse_attrs(remaining, splitter)]
    }
    "#" <> rest -> {
      let #(name, remaining) = splitter.split_before(splitter, rest)
      [css.Id(name), ..parse_attrs(remaining, splitter)]
    }
    ":" <> rest -> {
      let #(name, remaining) = splitter.split_before(splitter, rest)
      [css.Psuedo(name), ..parse_attrs(remaining, splitter)]
    }
    "[" <> rest -> {
      let #(attr, remaining) = parse_bracket_attr(rest)
      [attr, ..parse_attrs(remaining, splitter)]
    }
    _ -> []
  }
}

fn parse_bracket_attr(input: String) -> #(css.AttributeSelector, String) {
  let attr_splitter = splitter.new(attr_delims)
  let #(key, op_and_rest) = splitter.split_before(attr_splitter, input)

  case op_and_rest {
    "]" <> remaining -> #(css.AttributeExists(key), remaining)
    "^=" <> rest ->
      parse_attr_with_op(css.AttributePrefix, key, rest, attr_splitter)
    "$=" <> rest ->
      parse_attr_with_op(css.AttributeSuffix, key, rest, attr_splitter)
    "*=" <> rest ->
      parse_attr_with_op(css.AttributeIncludes, key, rest, attr_splitter)
    "=" <> rest ->
      parse_attr_with_op(css.AttributeEqual, key, rest, attr_splitter)
    _ -> #(css.AttributeExists(key), op_and_rest)
  }
}

fn parse_attr_with_op(
  constructor: fn(String, String) -> css.AttributeSelector,
  key: String,
  input: String,
  attr_splitter: splitter.Splitter,
) -> #(css.AttributeSelector, String) {
  let #(value, after_value) = parse_attr_value(input, attr_splitter)

  case after_value {
    "]" <> remaining -> #(constructor(key, value), remaining)
    _ -> #(constructor(key, value), after_value)
  }
}

fn parse_attr_value(
  input: String,
  attr_splitter: splitter.Splitter,
) -> #(String, String) {
  case input {
    "\"" <> rest -> {
      let #(parts, remaining) = take_until_quote(rest)
      case remaining {
        "\"" <> after -> #(parts, after)
        _ -> #(parts, remaining)
      }
    }
    _ -> {
      let #(value, rest) = splitter.split_before(attr_splitter, input)
      #(value, rest)
    }
  }
}

fn take_until_quote(input: String) -> #(String, String) {
  let quote_splitter = splitter.new(["\""])
  let #(before, _, after) = splitter.split(quote_splitter, input)
  #(before, after)
}
