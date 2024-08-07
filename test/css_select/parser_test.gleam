import css_select/internal/parser
import css_select/selector
import gleam/list
import gleeunit
import gleeunit/should
import nibble/lexer

pub fn main() {
  gleeunit.main()
}

pub fn parse_simple_selector_test() {
  parser.parse_simple_selector("div.foo.bar#myId")
  |> should.be_ok
  |> should.equal(
    selector.ElementSelector(selector.Tag("div"), [
      selector.Class("foo"),
      selector.Class("bar"),
      selector.AttributeEqual("id", "myId"),
    ]),
  )

  parser.parse_simple_selector(".foo.bar#myId")
  |> should.be_ok
  |> should.equal(
    selector.ElementSelector(selector.Any, [
      selector.Class("foo"),
      selector.Class("bar"),
      selector.AttributeEqual("id", "myId"),
    ]),
  )

  parser.parse_simple_selector(".foo-bar")
  |> should.be_ok
  |> should.equal(
    selector.ElementSelector(selector.Any, [selector.Class("foo-bar")]),
  )
}

pub fn parse_attribute_exists_test() {
  parser.parse_simple_selector("[href]")
  |> should.be_ok
  |> should.equal(
    selector.ElementSelector(selector.Any, [selector.AttributeExists("href")]),
  )
}

pub fn parse_attribute_equals_test() {
  parser.parse_simple_selector("[foo=bar]")
  |> should.be_ok
  |> should.equal(
    selector.ElementSelector(selector.Any, [
      selector.AttributeEqual("foo", "bar"),
    ]),
  )
  parser.parse_simple_selector("[href=\"https://www.example.com\"]")
  |> should.be_ok
  |> should.equal(
    selector.ElementSelector(selector.Any, [
      selector.AttributeEqual("href", "https://www.example.com"),
    ]),
  )
}

pub fn parse_attribute_prefix_test() {
  parser.parse_simple_selector("[foo^=bar]")
  |> should.be_ok
  |> should.equal(
    selector.ElementSelector(selector.Any, [
      selector.AttributePrefix("foo", "bar"),
    ]),
  )
}

pub fn parse_attribute_suffix_test() {
  parser.parse_simple_selector("[foo$=bar]")
  |> should.be_ok
  |> should.equal(
    selector.ElementSelector(selector.Any, [
      selector.AttributeSuffix("foo", "bar"),
    ]),
  )
}

pub fn parse_attribute_psuedo_class_test() {
  parser.parse_simple_selector(":checked")
  |> should.be_ok
  |> should.equal(
    selector.ElementSelector(selector.Any, [selector.AttributeExists("checked")]),
  )

  parser.parse_simple_selector(":disabled")
  |> should.be_ok
  |> should.equal(
    selector.ElementSelector(selector.Any, [
      selector.AttributeExists("disabled"),
    ]),
  )

  parser.parse_simple_selector(":hello")
  |> should.be_error
}

pub fn lexer_test() {
  lexer.run("", parser.lexer())
  |> should.be_ok
  |> should.equal([])

  lexer.run("div#foo", parser.lexer())
  |> should.be_ok
  |> list.map(fn(t) {
    let lexer.Token(_, _, value) = t
    value
  })
  |> should.equal([parser.Name("div"), parser.Hash, parser.Name("foo")])

  lexer.run("div#foo[href]", parser.lexer())
  |> should.be_ok
  |> list.map(fn(t) {
    let lexer.Token(_, _, value) = t
    value
  })
  |> should.equal([
    parser.Name("div"),
    parser.Hash,
    parser.Name("foo"),
    parser.LBracket,
    parser.Name("href"),
    parser.RBracket,
  ])

  lexer.run("div#foo[bar=baz]", parser.lexer())
  |> should.be_ok
  |> list.map(fn(t) {
    let lexer.Token(_, _, value) = t
    value
  })
  |> should.equal([
    parser.Name("div"),
    parser.Hash,
    parser.Name("foo"),
    parser.LBracket,
    parser.Name("bar"),
    parser.EqualSign,
    parser.Name("baz"),
    parser.RBracket,
  ])

  lexer.run("[bar=\"baz\"]", parser.lexer())
  |> should.be_ok
  |> list.map(fn(t) {
    let lexer.Token(_, _, value) = t
    value
  })
  |> should.equal([
    parser.LBracket,
    parser.Name("bar"),
    parser.EqualSign,
    parser.Name("baz"),
    parser.RBracket,
  ])
}
