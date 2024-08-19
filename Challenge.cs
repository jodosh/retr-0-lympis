using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Retr0lympis
{
    internal class Challenge
    {
        public string Name { get; set; }
        public string SaveStatePath { get; set; }
        public string LuaScriptPath { get; set; }
        public string ResultPath {  get; set; }   

        public Challenge()
        {
            Name = string.Empty;
            SaveStatePath = string.Empty;
            LuaScriptPath = string.Empty;
            ResultPath = string.Empty;
        }

        public Challenge(string name, string saveStatePath, string luaScriptPath)
        {
            Name = name;
            SaveStatePath = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "fceux", "fcs", saveStatePath);
            LuaScriptPath = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "fceux", "luascripts", luaScriptPath);
            ResultPath = luaScriptPath.Replace(".lua", ".RESULTS.txt");
        }
    }
}
