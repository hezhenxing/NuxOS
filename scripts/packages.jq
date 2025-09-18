# Order of package groups
def groups:
  [ "xfce"
  , "kdePackages"
  , "mate"
  , "enlightenment"
  , "nodePackages"
  , "elmPackages"
  , "haskellPackages"
  ]
  ;

def ordering:
  . as $name
  | groups
  | reduce .[] as $group (
      0;
      if $name | startswith($group + ".")
      then groups | index($group)
      else .
      end
    )
  ;

def filter:
  groups
  | join("|")
  | "^((" + . + ").)?[^<>.]+$"
  ;

.packages
| keys
| map(
  select(test(filter))
  | split(".")
  | {key: .[-1] | ltrimstr("_") | ltrimstr("_"), value: join(".")}
  )
| group_by(.key)
| map(sort_by(.value | ordering) | .[0])
| from_entries
