using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace Retr0lympis
{
    internal class Challenge
    {
        public string Name { get; set; }
        public string SaveState0Path { get; set; }
        public string? SaveState1Path { get; set; }
        public string LuaScriptPath { get; set; }
        public string ResultPath {  get; set; }   

        public Challenge()
        {
            Name = string.Empty;
            SaveState0Path = string.Empty;
            SaveState1Path = string.Empty;
            LuaScriptPath = string.Empty;
            ResultPath = string.Empty;
        }
        [JsonConstructor]
        public Challenge(string name, string saveState0Path, string luaScriptPath, string? saveState1Path)
        {
            Name = name;
            SaveState0Path = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "config", "fcs", saveState0Path);
            if (saveState1Path != null)
            {
                SaveState1Path = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "config", "fcs", saveState1Path);
            }
            LuaScriptPath = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "config", "luascripts", luaScriptPath);
            ResultPath = luaScriptPath.Replace(".lua", ".RESULTS.txt");
        }
    }
}
