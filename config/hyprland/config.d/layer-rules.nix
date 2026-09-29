''
  hl.layer_rule({
    name = "no-anim-awww",
    match = { namespace = "^awww-daemon$" },
    no_anim = true,
  })

  hl.layer_rule({
    name = "no-anim-quickshell",
    match = { namespace = "^quickshell$" },
    no_anim = true,
  })
''
