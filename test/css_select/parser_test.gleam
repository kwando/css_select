import css_select/internal/parser
import css_select/selector.{
  Any, AttributeEqual, AttributeExists, AttributePrefix, AttributeSuffix, Class,
  ElementSelector, Tag,
}
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
    ElementSelector(Tag("div"), [
      Class("foo"),
      Class("bar"),
      AttributeEqual("id", "myId"),
    ]),
  )

  parser.parse_simple_selector(".foo.bar#myId")
  |> should.be_ok
  |> should.equal(
    ElementSelector(Any, [
      Class("foo"),
      Class("bar"),
      AttributeEqual("id", "myId"),
    ]),
  )

  parser.parse_simple_selector(".foo-bar")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [Class("foo-bar")]))
}

pub fn parse_attribute_exists_test() {
  parser.parse_simple_selector("[href]")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [AttributeExists("href")]))
}

pub fn parse_attribute_equals_test() {
  parser.parse_simple_selector("[foo=bar]")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [AttributeEqual("foo", "bar")]))
  parser.parse_simple_selector("[href=\"https://www.example.com\"]")
  |> should.be_ok
  |> should.equal(
    ElementSelector(Any, [AttributeEqual("href", "https://www.example.com")]),
  )
}

pub fn parse_attribute_prefix_test() {
  parser.parse_simple_selector("[foo^=bar]")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [AttributePrefix("foo", "bar")]))
}

pub fn parse_attribute_suffix_test() {
  parser.parse_simple_selector("[foo$=bar]")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [AttributeSuffix("foo", "bar")]))
}

pub fn parse_attribute_psuedo_class_test() {
  parser.parse_simple_selector(":checked")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [AttributeExists("checked")]))

  parser.parse_simple_selector(":disabled")
  |> should.be_ok
  |> should.equal(ElementSelector(Any, [AttributeExists("disabled")]))

  parser.parse_simple_selector(":hello")
  |> should.be_error
}

//------------------------- [ check lexer ] -------------------------
pub fn lexer_test() {
  tokens("")
  |> should.equal([])

  tokens("div#foo")
  |> should.equal([parser.Name("div"), parser.Hash, parser.Name("foo")])

  tokens("div#foo[href]")
  |> should.equal([
    parser.Name("div"),
    parser.Hash,
    parser.Name("foo"),
    parser.LBracket,
    parser.Name("href"),
    parser.RBracket,
  ])

  tokens("div#foo[bar=baz]")
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

  tokens("[bar=\"baz\"]")
  |> should.equal([
    parser.LBracket,
    parser.Name("bar"),
    parser.EqualSign,
    parser.Name("baz"),
    parser.RBracket,
  ])
}

fn tokens(input: String) -> List(parser.T) {
  lexer.run(input, parser.lexer())
  |> should.be_ok
  |> list.map(fn(t) {
    let lexer.Token(_, _, value) = t
    value
  })
}
