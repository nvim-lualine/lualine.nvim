#include <string.h>
#define ABUF_EXPAND 1024 // 1KB

typedef struct {
  char *buf;
  size_t len;
  size_t max_len;
} abuf;

abuf *ab_init(size_t len);
void ab_append(abuf *ab, const char *s, size_t len);
void ab_free(abuf *ab);
void ab_clear(abuf *ab);
char *ab_get_str(abuf *ab);
