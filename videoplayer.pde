
import processing.video.*;

Chapter[] chapters;
int currentChapterIndex = 0;
Movie currentVideo;

void setup() {
  //size(800, 600);  // Set the size of the canvas
  size(1280, 720/2);  // Set the size of the canvas to be wider than the video width


  // Load the JSON file
  JSONObject json = loadJSONObject("storyboard.json");

  // Access the 'chapters' array
  JSONArray jsonChapters = json.getJSONArray("chapters");

  // Create an array of Chapter objects
  chapters = new Chapter[jsonChapters.size()];

  // Loop through each JSON chapter and create Chapter instances
  for (int i = 0; i < jsonChapters.size(); i++) {
    JSONObject jsonChapter = jsonChapters.getJSONObject(i);

    int id = jsonChapter.getInt("id");
    JSONArray jsonVideos = jsonChapter.getJSONArray("videos");
    String[] videos = new String[jsonVideos.size()];
    for (int j = 0; j < jsonVideos.size(); j++) {
      videos[j] = jsonVideos.getString(j);
    }

    boolean autoplay = jsonChapter.getBoolean("autoplay");

    JSONArray jsonActiveButtons = jsonChapter.getJSONArray("activeButtons");
    int[] activeButtons = new int[jsonActiveButtons.size()];
    for (int k = 0; k < jsonActiveButtons.size(); k++) {
      activeButtons[k] = jsonActiveButtons.getInt(k);
    }
    String side = jsonChapter.getString("side");
   JSONObject jsonVideoMapping = jsonChapter.getJSONObject("videoMapping");
    HashMap<Integer, Integer> videoMapping = new HashMap<Integer, Integer>();
    for (Object keyObj : jsonVideoMapping.keys()) {
      String key = (String) keyObj;
      videoMapping.put(Integer.parseInt(key), jsonVideoMapping.getInt(key));
    }

    // Create a new Chapter instance and add it to the array
    chapters[i] = new Chapter(id, videos, autoplay, activeButtons, side, videoMapping);
  }

  // Display and play the initial chapter
  displayCurrentChapter();
  playFirstVideo();
}

void draw() {
  // Clear the background
  background(255);

  // Display the current chapter's videos list
  displayCurrentChapter();
  // If a video is playing, display it
  if (currentVideo != null) {
    Chapter currentChapter = chapters[currentChapterIndex];
    float xPosition = currentChapter.side.equals("left") ? 0 : width / 2;
    image(currentVideo, xPosition, 0, width / 2, height);
    // Check if the video has finished playing
    if (!currentVideo.isPlaying() && currentVideo.time() >= currentVideo.duration()) {
      if (currentChapter.autoplay) {
        nextChapter();
      } else {
        // Stop the video and jump to frame x (e.g., frame 0.5 second)
        currentVideo.jump(currentVideo.duration()/2);
        currentVideo.read();
       // currentVideo.pause();
      }
    }
  }
}




void nextChapter() {
  // Increment the current chapter index and wrap around if necessary
  currentChapterIndex = (currentChapterIndex + 1) % chapters.length;
  displayCurrentChapter();
  playFirstVideo();
}

void displayCurrentChapter() {
  Chapter currentChapter = chapters[currentChapterIndex];
  fill(0);
  textSize(24);
  text("Chapter ID: " + currentChapter.id, 50, 50);

  textSize(18);
  text("Videos:", 50, 90);

  // Display the list of videos
  for (int i = 0; i < currentChapter.videos.length; i++) {
    text(currentChapter.videos[i], 70, 120 + i * 30);
  }
}

void playFirstVideo() {
  playVideo(0);
}


void movieEvent(Movie m) {
  m.read();
}

void keyPressed() {
  if (key == 'n' || key == 'N') {
    nextChapter();
  }else if (Character.isDigit(key)) {
    // Convert the key to an integer and call handleButtonPress
    int buttonId = Character.getNumericValue(key);
    handleButtonPress(buttonId);
  }
}

void handleButtonPress(int buttonId) {
  Chapter currentChapter = chapters[currentChapterIndex];
  if (currentChapter.videoMapping.containsKey(buttonId)) {
    int videoIndex = currentChapter.videoMapping.get(buttonId);
    playVideo(videoIndex);
  }
}




void playVideo(int index) {
  if (currentVideo != null) {
    currentVideo.stop();
  }

  // Load and play the video at the specified index of the current chapter
  String videoPath = chapters[currentChapterIndex].videos[index];
  println("Trying to load video: " + videoPath); // Debugging line
  currentVideo = new Movie(this, videoPath);

  // Add a check to see if the video file is loaded successfully
  if (currentVideo != null) {
    currentVideo.play();
  } else {
    println("Error: Could not load video " + videoPath);
  }
}
