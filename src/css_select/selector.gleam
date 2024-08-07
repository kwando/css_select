pub type TagSelector {
  Any
  Tag(String)
}

pub type AttributeSelector {
  Class(String)
  AttributeExists(String)
  AttributeEqual(String, String)
  AttributePrefix(String, String)
  AttributeSuffix(String, String)
  AttributeIncludes(String, String)
}

pub type Selector {
  ElementSelector(TagSelector, List(AttributeSelector))
}
