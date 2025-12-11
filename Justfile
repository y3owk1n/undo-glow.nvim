doc:
    vimcats -t -f -c -a \
    lua/undo-glow/init.lua \
    lua/undo-glow/api.lua \
    lua/undo-glow/config.lua \
    lua/undo-glow/types.lua \
    lua/undo-glow/factory.lua \
    lua/undo-glow/log.lua \
    lua/undo-glow/debounce.lua \
    lua/undo-glow/validate.lua \
    > doc/undo-glow.nvim.txt

set shell := ["bash", "-cu"]

fmt-check:
    stylua --config-path=.stylua.toml --check lua

fmt:
    stylua --config-path=.stylua.toml lua

lint:
    @if lua-language-server --configpath=.luarc.json --check=. --check_format=pretty --checklevel=Warning 2>&1 | grep -E 'Warning|Error'; then \
        echo "LSP lint failed"; \
        exit 1; \
    else \
        echo "LSP lint passed"; \
    fi

test:
    @echo "Running tests in headless Neovim using test_init.lua..."
    nvim -l tests/minit.lua --minitest
