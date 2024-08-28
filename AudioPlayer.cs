using NetCoreAudio;
using System;
using System.Threading.Tasks;

namespace Retr0lympis
{
    public class AudioPlayer
    {
        private Player _player;

        public AudioPlayer()
        {
            _player = new Player();
        }

        public async Task PlaySoundAsync(string filePath)
        {
            try
            {
                if (!_player.Playing)
                {
                    await _player.Play(filePath);
                    Console.WriteLine($"Playing sound: {filePath}");
                }
                else
                {
                    Console.WriteLine("A sound is already playing. Please wait.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error playing sound: {ex.Message}");
            }
        }

        public async Task StopSoundAsync()
        {
            try
            {
                await _player.Stop();
                Console.WriteLine("Sound stopped.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error stopping sound: {ex.Message}");
            }
        }
    }
}
