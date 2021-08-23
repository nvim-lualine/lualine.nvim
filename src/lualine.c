#include <stdio.h>
#include <stdlib.h>

#include "lualine.h"
#include "nvim.h"
#include "append_buffer.h"

Lualinelib *lib;

void init(Lualinelib *lualib) {
  lib = lualib;
}

// https://stackoverflow.com/questions/4770985/how-to-check-if-a-string-starts-with-another-string-in-c
bool startsWith(const char *pre, const char *str)
{
    size_t lenpre = strlen(pre),
           lenstr = strlen(str);
    return lenstr < lenpre ? false : memcmp(pre, str, lenpre) == 0;
}

bool is_string_same(const String *left, const String *right) {
  if (left->size != right->size) return false;
  return strcmp(left->data, right->data) == 0;
}

char * extract_hl_color(char *color_group, const char *scope) {
  String name = {.data = color_group, .size=strlen(color_group)};
  Boolean rgb = true;
  Error err = ERROR_INIT;
  Dictionary color = nvim_get_hl_by_name(name, rgb, &err);
  bool scope_bg = strcmp(scope, "bg") == 0 ? true : false;
  bool scope_fg = scope_bg ? false : true;
  int color_int = -1;
  for (int iii=0; iii < color.size; iii++) {
    if (scope_bg && (strcmp(color.items[iii].key.data, "background") == 0)) {
      color_int = color.items[iii].value.data.integer;
    } else if (scope_fg && (strcmp(color.items[iii].key.data, "foreground") == 0)) {
      color_int = color.items[iii].value.data.integer;
    }
  }

  char * result = (char*)malloc(sizeof(char) * 8);
  if (result == NULL) return NULL;
  sprintf(result, "#%06x", color_int);
  return result;
}

// Returns NULL when transitional separator isn't found
// Returns heap alocated string with name of transitional separator
String get_transitional_highlights(String *left_hl_name,
                                   String *right_hl_name,
                                   bool reverse) {
  String retval = STRING_INIT;
  if (left_hl_name->size == 0|| right_hl_name->size == 0) return retval;
  if (is_string_same(left_hl_name, right_hl_name)) return retval;
  bool right_starts_lualine = startsWith(right_hl_name->data, "lualine");
  bool left_starts_lualine = startsWith(left_hl_name->data, "lualine");
  size_t hl_name_size = left_hl_name->size + right_hl_name->size + 4 + 1; // _to_ = 4
  if (!left_starts_lualine) hl_name_size += 8; // lualine_ = 8
  if (right_starts_lualine) hl_name_size -= 8; // lualine_ = 8

  char *hl_name = (char *)malloc(sizeof(char) * hl_name_size);
  if (hl_name == NULL) return retval;
  char *name_ptr = hl_name;

  if (!left_starts_lualine) {
    memcpy(name_ptr, "lualine_", 8);
    name_ptr += 8;
  }
  memcpy(name_ptr, left_hl_name->data, left_hl_name->size);
  name_ptr += left_hl_name->size;
  memcpy(name_ptr, "_to_", 4);
  name_ptr += 4;
  if (!right_starts_lualine) {
    memcpy(name_ptr, right_hl_name->data, right_hl_name->size);
    name_ptr += right_hl_name->size;
  } else { // Don't copy starting lualine_
    memcpy(name_ptr, right_hl_name->data + 8, right_hl_name->size - 8);
    name_ptr += right_hl_name->size - 8;
  }
  *name_ptr = 0;

  if (!lib->hl_exists(hl_name)) {
    char *fg, *bg;
    if (!reverse) {
      fg = extract_hl_color(left_hl_name->data, "bg");
      bg = extract_hl_color(right_hl_name->data, "bg");
    }else{
      bg = extract_hl_color(left_hl_name->data, "bg");
      fg = extract_hl_color(right_hl_name->data, "bg");
    }
    if (fg == NULL || bg == NULL) {
      if (fg == NULL) free(fg);
      if (bg == NULL) free(bg);
      free(hl_name);
      return retval;
    }
    if (strcmp(fg, bg) == 0) {
      free(fg);
      free(bg);
      free(hl_name);
      return retval;
    }
    lib->create_highlight(hl_name, fg, bg);
  }

  retval.data = hl_name;
  retval.size = hl_name_size;

  return retval;
}

char * goto_char(char *str, char c) {
  for(; *str != 0; str++) {
    if (*str == c) return str;
  }
  return NULL;
}

String extract_highlight(char *str) {
  String retval = STRING_INIT;
  if (str[0] == '%' && str[1] == '#') {
    char *endPos = goto_char(str + 2, '#');
    if (endPos == NULL) return retval; 
    retval.data = str + 2;
    retval.size = endPos - str - 1;
    return retval;
  }
  return retval;
}

String find_next_hl(char *str) {
  char *s = str;
  while (s != NULL && *s != 0) {
    s = goto_char(s, '#');
    if (s[-1] != '%') {
      s++;
      continue;
    }
    return extract_highlight(s-1);
  }
  return (String)STRING_INIT;
}

char * apply_transitional_separator(char *stl) {
  int len  = strlen(stl);
  char *s = stl;
  char *copied = stl;
  String last_hl = STRING_INIT;
  abuf *ab = ab_init(len * 1.5);
  while (s != NULL && *s != 0) {
    s = goto_char(s, '%');
    if (s == NULL) break;
    ab_append(ab, copied, s - copied);
    copied = s;
    switch (s[1]) {
      case '#':
        last_hl = extract_highlight(s);
        last_hl.size > 0 ? s += last_hl.size : s++;
        ab_append(ab, copied, s - copied);
        copied = s;
        break;
      case 's':
        if (s[2] == '{') {
          char *sep_end = goto_char(s+2, '}');
          if (sep_end == NULL) {
            s++;
            break;
          }
          String sep = {.data=s+2, .size=sep_end-(s + 2) - 1};
          s = sep_end + 1;
          copied = s;
          String next_hl = find_next_hl(s);
          if (next_hl.size != 0) {
            String ts_hl = get_transitional_highlights(&last_hl, &next_hl, false);
            if (ts_hl.size != 0) {
              ab_append(ab, "%#", 2);
              ab_append(ab, ts_hl.data, ts_hl.size);
              ab_append(ab, "#", 1);
              ab_append(ab, sep.data, sep.size);
              free(ts_hl.data);
            }
          }
        }else{
          s++;
        }
        break;
      case 'S':
        if (s[2] == '{') {
          char *sep_end = goto_char(s+2, '}');
          if (sep_end == NULL) {
            s++;
            break;
          }
          String sep = {.data=s+2, .size=sep_end-(s + 2) - 1};
          s = sep_end + 1;
          copied = s;
          String next_hl = find_next_hl(s);
          if (next_hl.size != 0) {
            String ts_hl = get_transitional_highlights(&last_hl, &next_hl, true);
            if (ts_hl.size != 0) {
              ab_append(ab, "%#", 2);
              ab_append(ab, ts_hl.data, ts_hl.size);
              ab_append(ab, "#", 1);
              ab_append(ab, sep.data, sep.size);
              free(ts_hl.data);
            }
          }
        }else{
          s++;
        }
        break;
      default:
        s++;
    }
  }
  ab_append(ab, copied, stl + len - copied);
  return ab_get_str(ab);
}
