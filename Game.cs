using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
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

        public Game(string name, string romPath)
        {
            Name = name;
            RomPath = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "roms", romPath);
            Challenges = new List<Challenge>();
        }
        public Game(string name, string romPath, List<Challenge> challenges)
        {
            Name = name;
            RomPath = romPath;
            Challenges = challenges;
        }

        public void AddChallenge(string challengeName, string saveStateName, string luaScriptName)
        {
            Challenge newChallenge = new Challenge(challengeName, saveStateName, luaScriptName);
            Challenges.Add(newChallenge);
        }
    }
}
