{}:

with builtins;

rec {

  toZConfigValue = value:
    if (isString value) then value else
    if (isInt value) then toString value else
    if (isBool value) && value then "on" else
    if (isBool value) then "off" else
    if (isList value) then (
      let ret = foldl' (x: y: x + y + " ") "" value;
      in substring 0 ((stringLength ret) - 1) ret
    ) else
    throw "Unsupported value \"${value}\"";

  toZConfigComponent = type: name: attrs: indentation:
    let names = attrNames attrs; in
    if (all (value: (isAttrs value)) (attrValues attrs)) then
      concatLists
        (map (key: toZConfigComponent type key (getAttr key attrs) indentation)
             (sort lessThan names))
    else [
      (if (isNull name)
       then "\n${indentation}<${type}>"
       else "\n${indentation}<${type} ${name}>")
    ] ++ toZConfigLines attrs (indentation + "  ") ++ [
      "${indentation}</${type}>"
    ];

  toZConfigLines = attrs: indentation:
    let names = attrNames attrs; in
    # key value pairs
    (map (key: "${indentation}${key} ${toZConfigValue (getAttr key attrs)}")
         (filter (key: let value = (getAttr key attrs);
                       in (isString value) ||
                          (isInt    value) ||
                          (isBool   value) ||
                          (isList   value))
                 (sort lessThan names)))
    # components
    ++
    concatLists
      (map (key: toZConfigComponent key null (getAttr key attrs) indentation)
            (filter (key: let value = (getAttr key attrs);
                          in (isAttrs value))
                    (sort lessThan names)));

  toZConfig = attrs:
    let names = attrNames attrs; in
    foldl' (x: y: x + y + "\n") "" (
      # %define
      (if hasAttr "%define" attrs then
        map (key: "%define ${key} ${getAttr key attrs."%define"}")
            (sort lessThan (attrNames attrs."%define"))
      else [])
      # %import
      ++
      (if hasAttr "%import" attrs then
        map (module: "%import ${module}")
            (sort lessThan attrs."%import")
      else [])
      # separator
      ++ (if (elem "%define" names || elem "%import" names)
          then [ "" ] else [])
      # configuration
      ++
      toZConfigLines (removeAttrs attrs [ "%define" "%import" ]) ""
    );
}
