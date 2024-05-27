class Chapter {
  int id;
  String[] videosForeground;
  String[] videosBackground;

  boolean autoplay;
  int[] activeButtons;
  String position;
  HashMap<Integer, Integer> videoMapping;
  PImage stillimage;

  // Constructor
  Chapter(int id, String[] videosForeground, String[] videosBackground, boolean autoplay, int[] activeButtons, String position, HashMap<Integer, Integer> videoMapping, PImage image) {
    this.id = id;
    this.videosForeground = videosForeground;
    this.videosBackground = videosBackground;
    this.autoplay = autoplay;
    this.activeButtons = activeButtons;
    this.position = position;
    this.videoMapping = videoMapping;
    this.stillimage=image;
    display();
  }

  // Method to display chapter information (optional)
  void display() {
    println("Chapter ID: " + id);
    println("Autoplay: " + autoplay);
    println("Active Buttons: " + join(str(activeButtons), ", "));
    println("Video Mapping: " + videoMapping);
  }
}
