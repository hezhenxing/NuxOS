def ordering:
    if   startswith("services.") then 1
    elif startswith("wayland.")  then 2
    elif startswith("xsession.") then 3
    elif startswith("programs.") then 4
    else error
    end;

.
| keys
| map(
  select(test("^(programs|services(.xserver)?|wayland|xsession)(.(display|window)Manager)?.[^<>.]+.enable$"))
  | split(".")
  | .[:-1]
  | {key: .[-1] | trimstr("\"") | ltrimstr("_") | ltrimstr("_"), value: join(".")}
  )
| group_by(.key)
| map(sort_by(.value | ordering) | .[0])
| from_entries
