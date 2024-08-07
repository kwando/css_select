import css_select/selector as css
import gleam/option
import gleam/result
import gleam/set
import gleam/string
import nibble.{do, one_of, return, token}
import nibble/lexer

pub type T {
  Hash
  Dot
  Star
  Colon
  EqualSign
  Prefix
  Suffix
  LBracket
  RBracket
  Name(String)
  StrT(String)
}

pub fn lexer() {
  lexer.simple([
    lexer.token("#", Hash),
    lexer.token(".", Dot),
    lexer.token("*", Star),
    lexer.token(":", Colon),
    lexer.token("[", LBracket),
    lexer.token("]", RBracket),
    lexer.token("=", EqualSign),
    lexer.token("^=", Prefix),
    lexer.token("$=", Suffix),
    lexer.string("\"", Name),
    lexer.identifier("^[\\w]", "[\\w-_]", set.new(), Name),
  ])
}

fn identifier_parser() {
  use tok <- nibble.take_map("identifier")

  case tok {
    Name(k) -> option.Some(k)
    _ -> option.None
  }
}

fn class_parser() {
  use _ <- do(token(Dot))
  use class <- do(identifier_parser())

  return(css.Class(class))
}

fn id_parser() {
  use _ <- do(token(Hash))
  use id <- do(identifier_parser())

  return(css.AttributeEqual("id", id))
}

fn element_parser() {
  one_of([tag_parser(), any_parser()])
}

fn any_parser() {
  nibble.succeed(css.Any)
}

fn tag_parser() {
  use tag <- do(identifier_parser())
  return(css.Tag(tag))
}

fn attr_selector_parser() {
  one_of([class_parser(), id_parser(), attr_parser(), psuedo_parser()])
}

fn psuedo_parser() {
  use _ <- do(token(Colon))
  use name <- do(identifier_parser())

  case name {
    "checked" -> return(css.AttributeExists("checked"))
    "disabled" -> return(css.AttributeExists("disabled"))
    "selected" -> return(css.AttributeExists("selected"))
    _ -> nibble.fail("unknown psuedo class" <> string.inspect(name))
  }
}

fn attr_parser() {
  use _ <- do(token(LBracket))
  use key <- do(identifier_parser())

  let attribute_exists = {
    use _ <- do(token(RBracket))
    return(css.AttributeExists(key))
  }

  let attribute_equals = {
    use _ <- do(token(EqualSign))
    use value <- do(identifier_parser())
    use _ <- do(token(RBracket))
    return(css.AttributeEqual(key, value))
  }

  let attribute_prefix = {
    use _ <- do(token(Prefix))
    use value <- do(identifier_parser())
    use _ <- do(token(RBracket))
    return(css.AttributePrefix(key, value))
  }

  let attribute_suffix = {
    use _ <- do(token(Suffix))
    use value <- do(identifier_parser())
    use _ <- do(token(RBracket))
    return(css.AttributeSuffix(key, value))
  }

  one_of([
    attribute_exists,
    attribute_equals,
    attribute_prefix,
    attribute_suffix,
  ])
}

fn parser() {
  use tag_selector <- do(element_parser())
  use attr_selectors <- do(nibble.many(attr_selector_parser()))
  return(css.ElementSelector(tag_selector, attr_selectors))
}

pub type ParseError(a) {
  LexerError(lexer.Error)
  ParseError(List(nibble.DeadEnd(T, a)))
}

pub fn parse_simple_selector(
  input: String,
) -> Result(css.Selector, ParseError(a)) {
  input
  |> lexer.run(lexer())
  |> result.map_error(LexerError)
  |> result.try(fn(tokens) {
    nibble.run(tokens, parser()) |> result.map_error(ParseError)
  })
}
