import gleam/list
import gleam/string

pub type TagSelector {
  Any
  Tag(String)
}

pub type AttributeSelector {
  Id(String)
  Class(String)
  AttributeExists(String)
  AttributeEqual(String, String)
  AttributePrefix(String, String)
  AttributeSuffix(String, String)
  AttributeIncludes(String, String)
  Psuedo(String)
}

pub type Selector {
  ElementSelector(TagSelector, List(AttributeSelector))
}

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
