def ordering:
    if   startswith("xfce.") then 1
    elif startswith("kdePackages.") then 2
    elif startswith("haskellPackages.") then 3
    elif contains(".") then error
    else 0
    end;

.packages
| keys
| map(
  select(test("^((xfce|kdePackages|haskellPackages).)?[^<>.]+$"))
  | split(".")
  | {key: .[-1] | ltrimstr("_") | ltrimstr("_"), value: join(".")}
  )
| group_by(.key)
| map(sort_by(.value | ordering) | .[0])
| from_entries
