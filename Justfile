doc:
    vimcats -t -f -c -a \
    lua/undo-glow/init.lua \
    lua/undo-glow/config.lua \
    lua/undo-glow/types.lua \
    > doc/undo-glow.nvim.txt

set shell := ["bash", "-cu"]

fmt-check:
    stylua --config-path=.stylua.toml --check lua

fmt:
    stylua --config-path=.stylua.toml lua

lint:
    selene lua

test:
    @echo "Running tests in headless Neovim using test_init.lua..."
    nvim -l tests/minit.lua --minitest
