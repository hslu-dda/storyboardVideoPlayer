
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

        String mode = jsonChapter.getString("mode");


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
    chapters[i] = new Chapter(id, videosForeground, videosBackground, activeButtons, position, mode,videoMapping, image);
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
        rightCanvas.endDraw();
      }
    } else {
      rightCanvas.beginDraw();
      rightCanvas.background(255);
      rightCanvas.image(currentVideo, 0, 0, rightCanvas.width, rightCanvas.height);
      rightCanvas.endDraw();
      if (secondaryVideo != null) {
        leftCanvas.beginDraw();
        leftCanvas.image(secondaryVideo, 0, 0, leftCanvas.width, leftCanvas.height);
        leftCanvas.endDraw();
      }
    }
    
    
      
    float tolerance = 0.2; // Adjust this value as needed
    


    

    // Check if the video has finished playing
    if (!currentVideo.isPlaying() && currentVideo.time()  >= (currentVideo.duration() - tolerance)) {
         println("-------- END",currentChapter.mode);
  handleChapterMode(currentChapter.mode);
        
  
    }
  }
  
  
  

  leftSyphonServer.sendImage(leftCanvas);
  rightSyphonServer.sendImage(rightCanvas);

  image(leftCanvas, 0, 0, leftCanvas.width/2, leftCanvas.height/2);
  image(rightCanvas, leftCanvas.width/2, 0, rightCanvas.width/2, rightCanvas.height/2);

  // Display the current chapter's videos list
  displayCurrentChapter();
}


void nextChapter() {
  // Increment the current chapter index and wrap around if necessary
  currentChapterIndex = (currentChapterIndex + 1) % chapters.length;
  displayCurrentChapter();
  playFirstVideo();
}


void reset() {
  // Increment the current chapter index and wrap around if necessary
  currentChapterIndex = 0;
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

void handleChapterMode(String mode) {
  switch (mode) {
    case "next":
      nextChapter();
      break;
    case "repeat":
      repeatVideo();
      break;
    case "restart":
      playVideo(0);
      break;
    case "stop":
      //stopVideo();
      break;
    default:
      println("Unknown mode: " + mode);
      break;
  }
}

void playFirstVideo() {
  playVideo(0);
  playSecondaryVideo(0);
}

void stopVideo() {
  if (currentVideo != null) {
    currentVideo.stop();
  }
}

void repeatVideo() {
  if (currentVideo != null) {
    currentVideo.jump(0);
    currentVideo.play();
  }
}



void movieEvent(Movie m) {
  m.read();
  
    float tolerance = 0.2; // Adjust this value as needed
    
  println(m.isPlaying(),m.time(),m.duration());
  
  // Check if the video has finished playing
  if (!m.isPlaying() && m.time() >= (m.duration() - tolerance)) {
    if (m == currentVideo) {
      println("Current video stopped.");
      Chapter currentChapter = chapters[currentChapterIndex];
      handleChapterMode(currentChapter.mode);
    } else if (m == secondaryVideo) {
      println("Secondary video stopped.");
    }
  }
}

void keyPressed() {
  if (key == 'n' || key == 'N') {
    nextChapter();
  }
  if (Character.isDigit(key)) {
    // Convert the key to an integer and call handleButtonPress
    int buttonId = Character.getNumericValue(key);
    handleButtonPress(buttonId);
  }
  if (key=='r') {
    reset();
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
  println("Play");
  String videoPath;
  Chapter currentChapter = chapters[currentChapterIndex];
  if (currentChapter.position.equals("foreground")) {
    videoPath = currentChapter.videosForeground[index];
  } else if (currentChapter.position.equals("background")) {
    videoPath = currentChapter.videosBackground[index];
  } else {
    videoPath = currentChapter.videosForeground[index];
  }
  println("---"+videoPath);
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

  if (videoPath!=null) {
    secondaryVideo = new Movie(this, videoPath);
  } else {
    secondaryVideo=null;
  }
  // Add a check to see if the video file is loaded successfully
  if (secondaryVideo != null) {
    secondaryVideo.play();
  } else {
    println("Error: Could not load video " + videoPath);
  }
}
