abstract class IVideoPlayer
{
  Future<bool> start();
  Future<bool> stop();
  Future<bool> pause();
  Future<bool> seek(int seconds);
  Future<bool> play(String url);
}