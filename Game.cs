using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace Retr0lympis
{
    internal class Game
    {
        public string Name { get; set; }
        public string RomPath { get; set; }
        public List<Challenge> Challenges { get; set; }

        public Game() 
        {
            Name = string.Empty;
            RomPath = string.Empty;
            Challenges = new List<Challenge>();
        }

        public Game(string name, string romFilename)
        {
            Name = name;
            RomPath = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "roms", romFilename);
            Challenges = new List<Challenge>();
        }
        [JsonConstructor]
        public Game(string name, string romPath, List<Challenge> challenges)
        {
            Name = name;
            RomPath = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "roms", romPath);
            Challenges = challenges;
        }

        public void AddChallenge(string challengeName, string saveStateName, string luaScriptName)
        {
            Challenge newChallenge = new Challenge(challengeName, saveStateName, luaScriptName);
            Challenges.Add(newChallenge);
        }
    }
}
