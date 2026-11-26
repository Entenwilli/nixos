{lib}: let
  inherit (lib) concatMapStringsSep hasPrefix removePrefix;

  escapeString = s: ''"'' + (builtins.replaceStrings ["\\" "\""] ["\\\\" "\\\""] s) + ''"'';

  raw = text: {
    __kdlType = "raw";
    inherit text;
  };

  args = list: {__kdlArgs = list;};

  isWrapped = v: builtins.isAttrs v && v ? __kdlType;
  isArgsWrapped = v: builtins.isAttrs v && v ? __kdlArgs;
  isScalar = v: isWrapped v || builtins.isBool v || builtins.isString v || builtins.isInt v || builtins.isFloat v;

  formatFloat = f: let
    s = toString f;
    trim = t:
      if lib.hasSuffix "0" t
      then trim (lib.removeSuffix "0" t)
      else t;
    trimmed =
      if lib.hasInfix "." s
      then trim s
      else s;
  in
    if lib.hasSuffix "." trimmed
    then trimmed + "0"
    else trimmed;

  renderScalar = v:
    if isWrapped v
    then
      (
        if v.__kdlType == "raw"
        then ''r#"'' + v.text + ''"#''
        else throw "kdl.nix: unknown wrapped value type '${v.__kdlType}'"
      )
    else if builtins.isBool v
    then
      (
        if v
        then "true"
        else "false"
      )
    else if builtins.isString v
    then escapeString v
    else if builtins.isFloat v
    then formatFloat v
    else if builtins.isInt v
    then toString v
    else throw "kdl.nix: unsupported scalar type '${builtins.typeOf v}'";

  renderKey = indent: name: value:
    if value == null
    then indent + name
    else if value == []
    then indent + name + " {\n" + indent + "}"
    else if isScalar value
    then indent + name + " " + renderScalar value
    else if isArgsWrapped value
    then indent + name + " " + concatMapStringsSep " " renderScalar value.__kdlArgs
    else if builtins.isList value
    then concatMapStringsSep "\n" (renderKey indent name) value
    else if builtins.isAttrs value
    then renderBlock indent name value
    else throw "kdl.nix: unsupported value type '${builtins.typeOf value}' for '${name}'";

  renderBlock = indent: name: attrs: let
    keys = builtins.attrNames attrs;
    propKeys = builtins.filter (hasPrefix "@") keys;
    childKeys = builtins.filter (k: !(hasPrefix "@" k)) keys;
    propsStr =
      if propKeys == []
      then ""
      else " " + concatMapStringsSep " " (k: "${removePrefix "@" k}=${renderScalar attrs.${k}}") propKeys;
    head = indent + name + propsStr;
  in
    if childKeys == []
    then head
    else
      head
      + " {\n"
      + concatMapStringsSep "\n" (k: renderKey (indent + "    ") k attrs.${k}) childKeys
      + "\n"
      + indent
      + "}";
in {
  inherit raw args;
  toKDL = doc: (concatMapStringsSep "\n" (k: renderKey "" k doc.${k}) (builtins.attrNames doc)) + "\n";
}
