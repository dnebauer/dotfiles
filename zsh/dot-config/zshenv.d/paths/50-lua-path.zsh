# LUA_PATH variable

# base LUA_PATH
unset LUA_PATH lua_path
export -T LUA_PATH lua_path ';'  # separator is single semicolon
typeset -U LUA_PATH lua_path
lua_path+=('/usr/share/lua/lib/?.lua')       #} modules installed via user-
lua_path+=('/usr/share/lua/lib/?/init.lua')  #} built debian packages
lua_path+=(';')  # so LUA_PATH ends with ';;', meaning append default path

