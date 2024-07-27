local _self = {
	v = 1,
	name = "cheatsheet.view",
	blocks = {},
	macros = {},
	extends = "base.view",
}

function _self.body(__, _context)
	return "base.view"
end

function _self.blocks.page_content(__, _context)
	__:push_state(_self, 3, "block.page_content")
	__.line = 5
	__([[


  ]])
	local card_content
	do
	local _2 = {}
	__.line = 7
	_2[#_2 + 1] = [[

    <div class="columns-xs">
      ]]
	for name, keys in __.iter(_context.mods) do
	__.line = 11
	_2[#_2 + 1] = [[

        <div class="flex flex-row items-center justify-between space-x-2">
          <div class="flex-none">
            <strong>
              <em>]]
	_2[#_2 + 1] = _context.count
	_2[#_2 + 1] = "❝"
	_2[#_2 + 1] = name
	__.line = 15
	_2[#_2 + 1] = [[❞</em>
            </strong>
          </div>
          <div>
            ]]
	for _, key in __.iter(keys) do
	__.line = 16
	_2[#_2 + 1] = [[

              ]]
	_2[#_2 + 1] = __.fn.mKBD(__, {["scale"] = 90,["keys"] = __.v(_context.symbols, key)})
	__.line = 17
	_2[#_2 + 1] = [[

            ]]
	end
	__.line = 20
	_2[#_2 + 1] = [[

          </div>
        </div>
      ]]
	end
	__.line = 22
	_2[#_2 + 1] = [[

    </div>
  ]]
	card_content = __.concat(_2)
	end
	__.line = 24
	__([[


  ]])
	__:e(__.fn.mCard(__, {["content"] = card_content,["title"] = 'Mods'}))
	__.line = 29
	__([[


  <hr class="my-4" />

  <section class="columns-sm">
    ]])
	for group_name, cmds in __.iter(_context.groups) do
	__.line = 31
	__([[


      ]])
	local card_content
	do
	local _6 = {}
	__.line = 33
	_6[#_6 + 1] = [[

        <div class="flex flex-col space-y-2">
          ]]
	for _, cmd in __.iter(cmds) do
	__.line = 34
	_6[#_6 + 1] = [[

            ]]
	if __.b(__.v(cmd, "hotkey")) then
	__.line = 35
	local icon_size = 30
	__.line = 42
	_6[#_6 + 1] = [[<div class="odd:bg-base-100 p-1 even:bg-none">
                <div class="flex flex-row items-center justify-between gap-x-4">
                  <div class="h-[30px] w-[30px] flex-none">
                    <img
                      class="invert"
                      src="]]
	_6[#_6 + 1] = __.fn.modelfn(__, {["fn"] = 'encodeAsURLString',["model"] = __.fn.modelfn(__, {["fn"] = 'getMenuIcon',["args"] = {icon_size},["model"] = cmd})})
	__.line = 43
	_6[#_6 + 1] = [["
                      width="]]
	_6[#_6 + 1] = icon_size
	__.line = 44
	_6[#_6 + 1] = [["
                      height="]]
	_6[#_6 + 1] = icon_size
	__.line = 46
	_6[#_6 + 1] = [[" />
                  </div>
                  <p class="grow">]]
	_6[#_6 + 1] = __.v(cmd, "title")
	__.line = 48
	_6[#_6 + 1] = [[</p>
                  <div class="flex-none">]]
	__.line = 50
	for _, key in __.iter(__.v(cmd, "hotkey", "mods")) do
	__.line = 49
	_6[#_6 + 1] = __.fn.mKBD(__, {["keys"] = __.v(_context.symbols, key)})
	end
	__.line = 51
	if __.b(__.v(_context.symbols, __.v(cmd, "hotkey", "key"))) then
	__.line = 52
	_6[#_6 + 1] = __.fn.mKBD(__, {["keys"] = __.v(_context.symbols, __.v(cmd, "hotkey", "key"))})
	__.line = 53
	else
	__.line = 54
	_6[#_6 + 1] = __.fn.mKBD(__, {["keys"] = __.v(cmd, "hotkey", "key")})
	__.line = 55
	end
	__.line = 59
	_6[#_6 + 1] = [[

                  </div>
                </div>
              </div>
            ]]
	end
	__.line = 60
	_6[#_6 + 1] = [[

          ]]
	end
	__.line = 62
	_6[#_6 + 1] = [[

        </div>
      ]]
	card_content = __.concat(_6)
	end
	__.line = 64
	__([[


      ]])
	__:e(__.fn.mCard(__, {["classnames"] = {'mb-8 card-compact break-inside-avoid inline-block'},["title"] = group_name,["content"] = card_content}))
	__.line = 70
	__([[

    ]])
	end
	__.line = 74
	__([[

  </section>

  <hr class="py-4" />
]])
	__:pop_state()
end

return _self