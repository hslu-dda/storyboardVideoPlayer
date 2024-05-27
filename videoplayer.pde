
import processing.video.*;

import codeanticode.syphon.*;

SyphonServer leftSyphonServer;
SyphonServer rightSyphonServer;

Chapter[] chapters;
int currentChapterIndex = 0;
Movie currentVideo;
Movie secondaryVideo;


PGraphics leftCanvas;
PGraphics rightCanvas;


void setup() {
  //size(800, 600);  // Set the size of the canvas
  size(1920, 1080, P3D);  // Set the size of the canvas to be wider than the video width
  // Initialize the canvases
  leftCanvas = createGraphics(1200, 1080, P3D);
  rightCanvas = createGraphics(1920, 1080, P3D);

  // Initialize Syphon servers
  leftSyphonServer = new SyphonServer(this, "Processing syphon1");
  rightSyphonServer = new SyphonServer(this, "Right Canvas");


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

    JSONArray jsonVideos = jsonChapter.getJSONArray("videosForeground");
    String[] videosForeground = new String[jsonVideos.size()];
    for (int j = 0; j < jsonVideos.size(); j++) {
      videosForeground[j] = jsonVideos.getString(j);
    }
    JSONArray jsonVideosBackground = jsonChapter.getJSONArray("videosBackground");
    String[] videosBackground = new String[jsonVideosBackground.size()];
    for (int j = 0; j < jsonVideosBackground.size(); j++) {
      videosBackground[j] = jsonVideosBackground.getString(j);
    }

    boolean autoplay = jsonChapter.getBoolean("autoplay");

    JSONArray jsonActiveButtons = jsonChapter.getJSONArray("activeButtons");
    int[] activeButtons = new int[jsonActiveButtons.size()];
    for (int k = 0; k < jsonActiveButtons.size(); k++) {
      activeButtons[k] = jsonActiveButtons.getInt(k);
    }
    String position = jsonChapter.getString("position");
    println(".......position", position);

    JSONObject jsonVideoMapping = jsonChapter.getJSONObject("videoMapping");
    HashMap<Integer, Integer> videoMapping = new HashMap<Integer, Integer>();
    for (Object keyObj : jsonVideoMapping.keys()) {
      String key = (String) keyObj;
      videoMapping.put(Integer.parseInt(key), jsonVideoMapping.getInt(key));
    }
    String imageurl = jsonChapter.getString("stillimage");
    PImage image=loadImage(imageurl);

    // Create a new Chapter instance and add it to the array
    chapters[i] = new Chapter(id, videosForeground, videosBackground, autoplay, activeButtons, position, videoMapping, image);
  }

  // Display and play the initial chapter
  displayCurrentChapter();
  playFirstVideo();
}

void draw() {
  // Clear the background
  background(255);



  // If a video is playing, display it
  if (currentVideo != null) {
    Chapter currentChapter = chapters[currentChapterIndex];
    leftCanvas.beginDraw();
    leftCanvas.image(currentChapter.stillimage, 0, 0, leftCanvas.width, leftCanvas.height);
    leftCanvas.endDraw();

    rightCanvas.beginDraw();
    rightCanvas.image(currentChapter.stillimage, 0, 0, rightCanvas.width, rightCanvas.height);
    rightCanvas.endDraw();

    if (currentChapter.position.equals("foreground")) {
      leftCanvas.beginDraw();
      leftCanvas.background(255);
      leftCanvas.image(currentVideo, 0, 0, leftCanvas.width, leftCanvas.height);
      leftCanvas.endDraw();

  if (secondaryVideo != null) {
      rightCanvas.beginDraw();
      rightCanvas.image(secondaryVideo, 0, 0, rightCanvas.width, rightCanvas.height);
      rightCanvas.endDraw();}
    } else {
      rightCanvas.beginDraw();
      rightCanvas.background(255);
      rightCanvas.image(currentVideo, 0, 0, rightCanvas.width, rightCanvas.height);
      rightCanvas.endDraw();
  if (secondaryVideo != null) {
      leftCanvas.beginDraw();
      leftCanvas.image(secondaryVideo, 0, 0, leftCanvas.width, leftCanvas.height);
      leftCanvas.endDraw();}
    }

    // Check if the video has finished playing
    if (!currentVideo.isPlaying() && currentVideo.time() >= currentVideo.duration()) {
      if (currentChapter.autoplay) {
        nextChapter();
      } else {
        // Stop the video and jump to frame x (e.g., frame 0.5 second)
        /*currentVideo.jump(currentVideo.duration()/2);
         currentVideo.read();
         currentVideo.pause();
         */
        println("-------- END");
        leftCanvas.beginDraw();
        leftCanvas.background(255, 0, 0);
        leftCanvas.endDraw();
      }
    }
  }

  leftSyphonServer.sendImage(leftCanvas);
  rightSyphonServer.sendImage(rightCanvas);

  image(leftCanvas, 0, 0,leftCanvas.width/2,leftCanvas.height/2);
  image(rightCanvas, leftCanvas.width/2, 0,rightCanvas.width/2,rightCanvas.height/2);

  // Display the current chapter's videos list
  displayCurrentChapter();
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
  text("Videos Foreground:", 50, 90);
  int yPos=120;
  // Display the list of videos
  for (int i = 0; i < currentChapter.videosForeground.length; i++) {
    yPos+= i * 30;
    text(currentChapter.videosForeground[i], 70, yPos);
  }
  yPos+= 30;

  text("Videos Background:", 50, yPos);

  yPos+= 30;
  for (int i = 0; i < currentChapter.videosBackground.length; i++) {
    yPos+= i * 30;

    text(currentChapter.videosBackground[i], 70, yPos);
  }
}

void playFirstVideo() {
  playVideo(0);
  playSecondaryVideo(0);
}


void movieEvent(Movie m) {
  m.read();
}

void keyPressed() {
  if (key == 'n' || key == 'N') {
    nextChapter();
  } else if (Character.isDigit(key)) {
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
  String videoPath;
  Chapter currentChapter = chapters[currentChapterIndex];
  if (currentChapter.position.equals("foreground")) {
    videoPath = currentChapter.videosForeground[index];
  } else if (currentChapter.position.equals("background")) {
    videoPath = currentChapter.videosBackground[index];
  } else {
    videoPath = currentChapter.videosForeground[index];
  }
  currentVideo = new Movie(this, videoPath);

  // Add a check to see if the video file is loaded successfully
  if (currentVideo != null) {
    currentVideo.play();
  } else {
    println("Error: Could not load video " + videoPath);
  }
}

void playSecondaryVideo(int index) {
  if (secondaryVideo != null) {
    secondaryVideo.stop();
  }
  String videoPath=null;
  Chapter currentChapter = chapters[currentChapterIndex];
  if (currentChapter.position.equals("foreground")) {
    if (currentChapter.videosBackground.length > 0) {
      videoPath = currentChapter.videosBackground[index];
    }
  } else if (currentChapter.position.equals("background")) {
    if (currentChapter.videosForeground.length > 0) {
      videoPath = currentChapter.videosForeground[index];
    }
  }

if(videoPath!=null){
  secondaryVideo = new Movie(this, videoPath);
}else{
      secondaryVideo=null;
}
  // Add a check to see if the video file is loaded successfully
  if (secondaryVideo != null) {
    secondaryVideo.play();
  } else {
    println("Error: Could not load video " + videoPath);
  }
}
