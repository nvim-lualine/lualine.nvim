# Internationalization

To make your own translations do the following:

1. Add the language in the CMakeLists.txt in line `9`
```cmake
set(LANGUAGES en ja)
```
2. Go to `~/po/build/` and run

```
cmake ..
build
```

3. Now your new translation file should be in `../lang.po` with `lang` being the name of
the translaiton.
