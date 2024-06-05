class Chapter {
  int id;
  String[] videosForeground;
  String[] videosBackground;

  int[] activeButtons;
  String position;
  String mode;
  HashMap<Integer, Integer> videoMapping;
  PImage stillimage;

  // Constructor
  Chapter(int id, String[] videosForeground, String[] videosBackground,  int[] activeButtons, String position, String mode,HashMap<Integer, Integer> videoMapping, PImage image) {
    this.id = id;
    this.videosForeground = videosForeground;
    this.videosBackground = videosBackground;
    this.activeButtons = activeButtons;
    this.position = position;
        this.mode=mode;
    this.videoMapping = videoMapping;
    this.stillimage=image;
    display();
  }

  // Method to display chapter information (optional)
  void display() {
    println("Chapter ID: " + id);
    println("Active Buttons: " + join(str(activeButtons), ", "));
    println("Video Mapping: " + videoMapping);
  }
}
