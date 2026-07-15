import css_select/selector as css
import gleam/list
import gleam/string

pub type ParseError {
  ParseError(String)
}

pub fn parse_simple_selector(
  input: String,
) -> Result(css.Selector, ParseError) {
  let chars = string.to_graphemes(input)
  let #(tag, rest) = parse_tag(chars)
  let attrs = parse_attributes(rest)
  Ok(css.ElementSelector(tag, attrs))
}

fn parse_tag(chars: List(String)) -> #(css.TagSelector, List(String)) {
  case chars {
    [] -> #(css.Any, [])
    [".", ..] -> #(css.Any, chars)
    ["#", ..] -> #(css.Any, chars)
    ["[", ..] -> #(css.Any, chars)
    [":", ..] -> #(css.Any, chars)
    _ -> {
      let #(name, rest) = take_while(chars, is_ident_char)
      #(css.Tag(name), rest)
    }
  }
}

fn parse_attributes(chars: List(String)) -> List(css.AttributeSelector) {
  case chars {
    [] -> []
    [".", ..rest] -> {
      let #(name, remaining) = take_while(rest, is_ident_char)
      [css.Class(name), ..parse_attributes(remaining)]
    }
    ["#", ..rest] -> {
      let #(name, remaining) = take_while(rest, is_ident_char)
      [css.Id(name), ..parse_attributes(remaining)]
    }
    [":", ..rest] -> {
      let #(name, remaining) = take_while(rest, is_ident_char)
      [css.Psuedo(name), ..parse_attributes(remaining)]
    }
    ["[", ..rest] -> {
      let #(attr, remaining) = parse_bracket_attr(rest)
      [attr, ..parse_attributes(remaining)]
    }
    _ -> []
  }
}

fn parse_bracket_attr(
  chars: List(String),
) -> #(css.AttributeSelector, List(String)) {
  let #(key, rest) = take_while(chars, is_ident_char)
  case rest {
    ["]", ..remaining] -> #(css.AttributeExists(key), remaining)
    ["=", ..remaining] -> {
      let #(value, after) = parse_attr_value(remaining)
      case after {
        ["]", ..remaining] -> #(css.AttributeEqual(key, value), remaining)
        _ -> #(css.AttributeEqual(key, value), after)
      }
    }
    ["^", "=", ..remaining] -> {
      let #(value, after) = parse_attr_value(remaining)
      case after {
        ["]", ..remaining] -> #(css.AttributePrefix(key, value), remaining)
        _ -> #(css.AttributePrefix(key, value), after)
      }
    }
    ["$", "=", ..remaining] -> {
      let #(value, after) = parse_attr_value(remaining)
      case after {
        ["]", ..remaining] -> #(css.AttributeSuffix(key, value), remaining)
        _ -> #(css.AttributeSuffix(key, value), after)
      }
    }
    ["*", "=", ..remaining] -> {
      let #(value, after) = parse_attr_value(remaining)
      case after {
        ["]", ..remaining] -> #(css.AttributeIncludes(key, value), remaining)
        _ -> #(css.AttributeIncludes(key, value), after)
      }
    }
    _ -> #(css.AttributeExists(key), rest)
  }
}

fn parse_attr_value(chars: List(String)) -> #(String, List(String)) {
  case chars {
    ["\"", ..rest] -> {
      let #(parts, remaining) = take_until(rest, fn(c) { c == "\"" })
      let value = string.concat(parts)
      case remaining {
        ["\"", ..after] -> #(value, after)
        _ -> #(value, remaining)
      }
    }
    _ -> {
      let #(value, remaining) = take_while(chars, is_ident_char)
      #(value, remaining)
    }
  }
}

fn take_while(
  chars: List(String),
  predicate: fn(String) -> Bool,
) -> #(String, List(String)) {
  let #(matched, rest) = take_while_loop(chars, predicate, [])
  #(string.concat(list.reverse(matched)), rest)
}

fn take_while_loop(
  chars: List(String),
  predicate: fn(String) -> Bool,
  acc: List(String),
) -> #(List(String), List(String)) {
  case chars {
    [] -> #(acc, [])
    [first, ..rest] -> {
      case predicate(first) {
        True -> take_while_loop(rest, predicate, [first, ..acc])
        False -> #(acc, chars)
      }
    }
  }
}

fn take_until(
  chars: List(String),
  predicate: fn(String) -> Bool,
) -> #(List(String), List(String)) {
  case chars {
    [] -> #([], [])
    [first, ..rest] -> {
      case predicate(first) {
        True -> #([], chars)
        False -> {
          let #(matched, remaining) = take_until(rest, predicate)
          #([first, ..matched], remaining)
        }
      }
    }
  }
}

fn is_ident_char(char: String) -> Bool {
  case char {
    "." -> False
    "#" -> False
    "[" -> False
    "]" -> False
    ":" -> False
    "=" -> False
    "^" -> False
    "$" -> False
    "*" -> False
    "\"" -> False
    " " -> False
    _ -> True
  }
}
