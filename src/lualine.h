#ifndef LUALINE_H
#define LUALINE_H

// Module initializer
#include <stdbool.h>
#include "nvim.h"

typedef struct {
  bool (*hl_exists)(char *);
  void (*create_highlight)(char *name, char *fg, char *bg);
} Lualinelib;

char * extract_hl_color(String *name, const char *scope);
char * apply_transitional_separator(char *stl);

#endif // LUALINE_H
