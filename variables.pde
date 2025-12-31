Button yesButton, noButton, buyButton, confirmButton, rollButton;
Quantity villa, building, hotel;
Client myClient;

Button[] cityButtons;
Button[] spaceButtons;
String[] cityNames;

String countryName = "";
String currentMessage = "111";
String detail_currentMessage = "";
boolean showButtons;

PFont font;
int money = 5000000;
int salary = 20000;

int messageX;
int messageY;

float money_X;
float money_Y;
float money_X2;
float money_Y2;

boolean buyLandPopup = false;
boolean buyBuildingPopup = false;
boolean chooseBuildingPopup = false;
boolean payTollPopup = false;
boolean gameEndPopup = false;
boolean salaryPopup = false;
boolean islandPopup = false;
boolean eventPopup = false;
boolean spacePopup = false;
boolean dicePopup = false;

String gameState = "IDLE";

Player[] players;
int currentPlayer = 0;

Country selectedCountry;
Player p;

HashMap<String, RfidInfo> uidNameMap = new HashMap<String, RfidInfo>(); //rfid uid 저장
HashMap<String, RfidInfo> eventMap = new HashMap<String, RfidInfo>();
HashMap<String, Country> countryData = new HashMap<String, Country>();

// 보드
final int BOARD_SIZE = 24;
PImage boardImage;
int textSize = 30;
// [variables.pde]
// 보드판의 시작 위치를 저장할 전역 변수 선언
int boardStartX;
int boardStartY;
int playerOffsetY = 15;




//주사위
float angleX = 0.0f;
float angleY = 0.0f;
float fallY = -50.0f;
float velocityY = 0;
boolean rolling = false;
int rollFrameCount = 0;
int diceNumber = 0;
boolean rollEnded = true;  // 멈춘 상태 플래그

PVector[] targetAngles = new PVector[6];
PVector currentAngle = new PVector(0, 0);
PVector targetAngle = new PVector(0, 0);
float easing = 0.5f;

PImage[] diceTexture = new PImage[6];
int resultHoldFrames = 0;
