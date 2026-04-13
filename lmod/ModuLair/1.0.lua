help([==[

Description
===========
ModuLair is a Python Virtual Environment management tool written by TAMU HPRC.

More information
================
 - Homepage: https://hprc.tamu.edu/kb/Software/ModuLair/
]==])

conflict("ModuLair")
add_property("lmod","sticky")

whatis([==[Description: ModuLair is a Python Virtual Environment management tool written by TAMU HPRC.]==])
whatis([==[Homepage: https://hprc.tamu.edu/kb/Software/ModuLair/]==])
help([[ModuLair is a Python Virtual Environment management tool written by TAMU HPRC. Homepage: https://hprc.tamu.edu/kb/Software/ModuLair/]])

local root = "/sw/hprc/sw/dor-hprc-venv-manager/"

prepend_path("PATH", pathJoin(root, "bin"))

local bashStr = [[
\local cmd="${1-__missing__}"
case "$cmd" in
    activate|deactivate)
        source /sw/hprc/sw/dor-hprc-venv-manager/bin/modulair "$@"
        ;;
    *)
        /sw/hprc/sw/dor-hprc-venv-manager/bin/modulair "$@"
        ;;
esac
]]

local cshStr = 'echo "ModuLair does not support bash/tcsh at the moment. Please use bash."'

set_shell_function("modulair",bashStr,cshStr)

