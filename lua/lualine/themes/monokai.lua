local colors = {
  black     = '#272822',
  dark_gray = '#383830',
  gray      = '#75715e',
  white     = '#f8f8f2',
  red       = '#f92672',
  green     = '#a6e22e',
  yellow    = '#e6db74',
  blue      = '#66d9ef',
  magenta   = '#ae81ff',
  cyan      = '#a1efe4',
  orange    = '#fd971f',
}

return {
  normal = {
    a = {
      bg = colors.dark_gray,
      fg = colors.white,
      gui = 'bold'
    },
    b = {
      bg = colors.dark_gray,
      fg = colors.white,
      gui = 'bold'
    },
    c = {
      bg = colors.dark_gray,
      fg = colors.white,
      gui = 'italic'
    },
  },
  insert = {
    a = {
      bg = colors.dark_gray,
      fg = colors.green,
      gui = 'bold'
    }
  },
  visual = {
    a = {
      bg = colors.dark_gray,
      fg = colors.magenta,
      gui = 'bold'
    }
  },
  replace = {
    a = {
      bg = colors.dark_gray,
      fg = colors.red,
      gui = 'bold'
    }
  },
  inactive = {
    a = {
      bg = colors.dark_gray,
      fg = colors.gray
    },
    b = {
      bg = colors.dark_gray,
      fg = colors.gray
    },
    c = {
      bg = colors.dark_gray,
      fg = colors.gray
    },
  },
}

