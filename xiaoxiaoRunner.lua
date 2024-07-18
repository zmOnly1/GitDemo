--package.cpath = package.cpath .. ';C:/Users/DS/AppData/Roaming/JetBrains/IntelliJIdea2022.2/plugins/EmmyLua/debugger/emmy/windows/x64/?.dll'
--local dbg = require('emmy_core')
--dbg.tcpConnect('localhost', 9966)
grid = {
    {11	,13,	13	,14,	11	,13},
    {14	,12,	14	,12,	11	,23},
    {12	,14,	14	,12,	14	,12},
    {14	,11,	12	,14,	13	,11},
    {11	,12,	11	,12,	13	,22},
    {11	,12,	14	,13,	14	,14},
}

function myLog(str)
    io.write(str .. "\n")
end

require("xiaoxiaoHelper")