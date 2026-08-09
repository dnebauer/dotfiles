# paths for perl5 locally installed modules

# (as per local::lib)

# binary path
perl5_bin="$HOME/perl5/bin"
[[ -d "$perl5_bin" ]] && path+=("$perl5_bin")
unset perl5_bin

# library path
# * 2016-03-13: discovered that PERL5LIB and PERL_LOCAL_LIB_ROOT
#   are set to their desired values before reaching this point,
#   so check value of vars before adding to them
perl5_lib="$HOME/perl5/lib/perl5"
[[ "$PERL5LIB" != "$perl5_lib" ]] && \
    export PERL5LIB="${perl5_lib}${PERL5LIB+:}${PERL5LIB}"
unset perl5_lib
perl5_root="$HOME/perl5"
[[ "$PERL_LOCAL_LIB_ROOT" != "$perl5_root" ]] && \
export PERL_LOCAL_LIB_ROOT=\
"${perl5_root}${PERL_LOCAL_LIB_ROOT+:}${PERL_LOCAL_LIB_ROOT}"

# build options
export PERL_MB_OPT="--install_base \"$perl5_root\""
export PERL_MM_OPT="INSTALL_BASE=$perl5_root"
unset perl5_root
