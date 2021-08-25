#ifndef NVIM_H
#define NVIM_H

#include <stdint.h>
#include <stdbool.h>
#include <string.h>

// Types and function definations to access neovim's api
typedef unsigned char char_u;
typedef uint32_t u8char_T;
typedef int handle_T;
typedef int LuaRef;
typedef handle_T NS;
typedef struct expand expand_T;

typedef enum {
  kNone  = -1,
  kFalse = 0,
  kTrue  = 1,
} TriState;

// Basic types
typedef enum {
  kErrorTypeNone = -1,
  kErrorTypeException,
  kErrorTypeValidation
} ErrorType;

typedef enum {
  kMessageTypeUnknown = -1,
  // Per msgpack-rpc spec.
  kMessageTypeRequest = 0,
  kMessageTypeResponse = 1,
  kMessageTypeNotification = 2,
} MessageType;

#define ARRAY_DICT_INIT {.size = 0, .capacity = 0, .items = NULL}
#define STRING_INIT {.data = NULL, .size = 0}
#define OBJECT_INIT { .type = kObjectTypeNil }
#define ERROR_INIT { .type = kErrorTypeNone, .msg = NULL }
#define REMOTE_TYPE(type) typedef handle_T type

#define ERROR_SET(e) ((e)->type != kErrorTypeNone)

typedef bool Boolean;
typedef int64_t Integer;
typedef double Float;

/// Maximum value of an Integer
#define API_INTEGER_MAX INT64_MAX

/// Minimum value of an Integer
#define API_INTEGER_MIN INT64_MIN


typedef struct {
  char *data;
  size_t size;
} String;

typedef struct {
  ErrorType type;
  char *msg;
} Error;

REMOTE_TYPE(Buffer);
REMOTE_TYPE(Window);
REMOTE_TYPE(Tabpage);

typedef struct object Object;

typedef struct {
  Object *items;
  size_t size, capacity;
} Array;

typedef struct key_value_pair KeyValuePair;

typedef struct {
  KeyValuePair *items;
  size_t size, capacity;
} Dictionary;

typedef enum {
  kObjectTypeNil = 0,
  kObjectTypeBoolean,
  kObjectTypeInteger,
  kObjectTypeFloat,
  kObjectTypeString,
  kObjectTypeArray,
  kObjectTypeDictionary,
  kObjectTypeLuaRef,
  // EXT types, cannot be split or reordered, see #EXT_OBJECT_TYPE_SHIFT
  kObjectTypeBuffer,
  kObjectTypeWindow,
  kObjectTypeTabpage,
} ObjectType;

struct object {
  ObjectType type;
  union {
    Boolean boolean;
    Integer integer;
    Float floating;
    String string;
    Array array;
    Dictionary dictionary;
    LuaRef luaref;
  } data;
};

struct key_value_pair {
  String key;
  Object value;
};

#define OBJECT_OBJ(o) o

#define BOOLEAN_OBJ(b) ((Object) { \
    .type = kObjectTypeBoolean, \
    .data.boolean = b })
#define BOOL(b) BOOLEAN_OBJ(b)

#define INTEGER_OBJ(i) ((Object) { \
    .type = kObjectTypeInteger, \
    .data.integer = i })

#define FLOAT_OBJ(f) ((Object) { \
    .type = kObjectTypeFloat, \
    .data.floating = f })

#define STRING_OBJ(s) ((Object) { \
    .type = kObjectTypeString, \
    .data.string = s })

#define CSTR_TO_OBJ(s) STRING_OBJ(cstr_to_string(s))
#define FIXED_TEMP_ARRAY(name, fixsize) \
  Array name = ARRAY_DICT_INIT; \
  Object name##__items[fixsize]; \
  name.size = fixsize; \
  name.items = name##__items; \

#define STATIC_CSTR_AS_STRING(s) ((String) {.data = s, .size = sizeof(s) - 1})

void xfree(void *ptr);
void api_free_string(String value);
void api_free_object(Object value);
void api_free_object(Object value);
void api_free_array(Array value);
void api_free_dictionary(Dictionary value);
void api_clear_error(Error *value);
void api_free_luaref(LuaRef ref);
String cstr_to_string(const char *str);

extern int name_to_color(const unsigned char *name);
extern Dictionary nvim_get_hl_by_name(String name, Boolean rgb, Error *err);

Object nvim_exec_lua(String code, Array args, Error *err);
#endif  // NVIM_H
