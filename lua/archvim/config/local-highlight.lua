require('local-highlight').setup({
    file_types = nil, -- If this is given only attach to this
    -- OR attach to every filetype except:
    disable_file_types = {},
    hlgroup = 'LocalHighlight',
    cw_hlgroup = nil, -- 'LocalHighlight',
    -- Whether to display highlights in INSERT mode or not
    insert_mode = false,
    min_match_len = 1,
    max_match_len = math.huge,
    highlight_single_match = false,
    animate = {
      enabled = true,
      easing = "linear",
      duration = {
        step = 10, -- ms per step
        total = 100, -- maximum duration
      },
    },
    debounce_timeout = 200,
})
