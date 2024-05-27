class Chapter {
  int id;
  String[] videos;
  boolean autoplay;
  int[] activeButtons;
  String side;
  HashMap<Integer, Integer> videoMapping;


  // Constructor
  Chapter(int id, String[] videos, boolean autoplay, int[] activeButtons, String side, HashMap<Integer, Integer> videoMapping) {
    this.id = id;
    this.videos = videos;
    this.autoplay = autoplay;
    this.activeButtons = activeButtons;
    this.side = side;
    this.videoMapping = videoMapping;
    display();

  }

  // Method to display chapter information (optional)
  void display() {
    println("Chapter ID: " + id);
    println("Videos: " + join(videos, ", "));
    println("Autoplay: " + autoplay);
    println("Active Buttons: " + join(str(activeButtons), ", "));
    println("Side: " + side);
    println("Video Mapping: " + videoMapping);
  }
}
