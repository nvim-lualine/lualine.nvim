#include "append_buffer.h"
#include <stdlib.h>
/*** Apend buffer ***/

abuf *ab_init(size_t len) {
  abuf *ab = (abuf *)malloc(sizeof(abuf));
  if (ab == NULL) return NULL;
  ab->len = 0;
  if (len > 0){
    ab->buf = (char *)malloc(sizeof(char) * len);
    if (ab->buf == NULL) {
      free(ab);
      return NULL;
    }
    ab->max_len = len;
  } else {
    ab->buf = NULL;
    ab->max_len = 0;
  }
  return ab;
}

void ab_append(abuf *ab, const char *s, size_t len) {
  if (len + ab->len > ab->max_len) {
    size_t new_maxLen = (ab->len + len) * 1.5; // Alocate 50% extra memory
    char *new = realloc(ab->buf, new_maxLen);
    if (new == NULL) return;
    ab->buf = new;
    ab->max_len = new_maxLen;
  }
  memcpy(&ab->buf[ab->len], s, len);
  ab->len += len;
}

char *ab_get_str(abuf *ab) {
  char * buf = ab->buf;
  ab->buf = NULL;
  buf[ab->len] = 0;
  ab_free(ab);
  return buf;
}

void ab_free(abuf *ab) {
  if (ab->buf != NULL) free(ab->buf);
  ab->buf = NULL;
  ab->len = 0;
  free(ab);
}

void ab_clear(abuf *ab) {
  ab->len = 0;
}
