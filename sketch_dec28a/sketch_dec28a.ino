#include <WiFi.h>
#include <WebServer.h>
#include <Wire.h>
#include <Adafruit_TCS34725.h>
#include <SPI.h>
#include <MFRC522.h>

// ===============================
// 기본 설정
// ===============================
const char* ssid = "Sun";
const char* password = "12345678";
WebServer server(80);

// 모터 핀
const int MOTOR_A_PIN1 = 27;
const int MOTOR_A_PIN2 = 26;  
const int MOTOR_A_ENABLE = 25;
const int MOTOR_B_PIN1 = 33;
const int MOTOR_B_PIN2 = 32;
const int MOTOR_B_ENABLE = 14;

// 센서 핀
const int SDA_PIN = 15;
const int SCL_PIN = 22;
const int RST_PIN = 2;
const int SS_PIN = 5;
const int IR_SENSOR_LEFT = 16;    // IR 센서(왼쪽)
const int IR_SENSOR_RIGHT = 17;   // IR 센서(오른쪽)

// 센서 객체
Adafruit_TCS34725 tcs = Adafruit_TCS34725(TCS34725_INTEGRATIONTIME_50MS, TCS34725_GAIN_4X);
MFRC522 mfrc522(SS_PIN, RST_PIN);

// ===============================
// 게임 상태 (단순화)
// ===============================
enum GameState {
  IDLE,
  MOVING,
  WAITING_RFID,
  COMPLETED
};

struct Game {
  GameState state = IDLE;
  int currentPosition = 0;
  int targetSteps = 0;
  int stepsCompleted = 0;
  String currentColor = "";
  String lastRFID = "";
  bool onLine = false;
  unsigned long gameStartTime = 0;
  String gameLog = "";
} game;

// ===============================
// Processing WiFi 통신 관련
// ===============================
WiFiServer processingServer(8888);  // 8888 포트로 서버 열기
WiFiClient processingClient;
bool processingConnected = false;
String inputBuffer = "";

// ===============================
// 초기화
// ===============================
void setup() {
  Serial.begin(115200);
  delay(1000);
  
  Serial.println("=== 부루마불 RC카 SIMPLE ===");
  
  // 핀 설정
  pinMode(MOTOR_A_PIN1, OUTPUT);
  pinMode(MOTOR_A_PIN2, OUTPUT);
  pinMode(MOTOR_B_PIN1, OUTPUT);
  pinMode(MOTOR_B_PIN2, OUTPUT);
  pinMode(MOTOR_A_ENABLE, OUTPUT);
  pinMode(MOTOR_B_ENABLE, OUTPUT);
  pinMode(IR_SENSOR_LEFT, INPUT_PULLUP);
  pinMode(IR_SENSOR_RIGHT, INPUT_PULLUP);
  pinMode(2, OUTPUT);
  pinMode(4, OUTPUT);
  
  // 모터 정지 상태로 초기화
  stopMotors();
  
  // PWM 설정
  ledcAttach(MOTOR_A_ENABLE, 1000, 8);
  ledcAttach(MOTOR_B_ENABLE, 1000, 8);
  
  // 센서 초기화 (간단하게)
  initSensors();
  
  // WiFi 연결
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.printf("\nWiFi 연결: %s\n", WiFi.localIP().toString().c_str());
  
  // 웹서버 설정
  setupWebServer();
  server.begin();
  
  // Processing TCP 서버 시작 추가
  processingServer.begin();
  Serial.printf("Processing 서버 시작: %s:8888\n", WiFi.localIP().toString().c_str());
  
  Serial.println("시스템 준비 완료!");
  testMotors();
}

// ===============================
// 메인 루프 (단순화)
// ===============================
void loop() {
  // Processing WiFi 통신 처리 추가
  handleProcessingWiFi();
  
  server.handleClient();
  
  // 게임 상태 처리
  switch (game.state) {
    case IDLE:
      // 대기 상태
      break;
      
    case MOVING:
      handleMoving();
      break;
      
    case WAITING_RFID:
      handleWaitingRFID();
      break;
      
    case COMPLETED:
      // 완료 상태
      break;
  }
  
  delay(50);
}

// ===============================
// 모터 제어 (기본적이고 단순)
// ===============================
void moveForward() {
  Serial.println("전진!");
  
  // PWM 최대 출력
  ledcWrite(MOTOR_A_ENABLE, 255);
  ledcWrite(MOTOR_B_ENABLE, 255);
  
  // 전진 방향 설정 (양쪽 모터 모두 방향 바꿈)
  digitalWrite(MOTOR_A_PIN1, HIGH);  // A 방향 원복
  digitalWrite(MOTOR_A_PIN2, LOW);   // A 방향 원복
  digitalWrite(MOTOR_B_PIN1, LOW);   // B 방향 바꿈
  digitalWrite(MOTOR_B_PIN2, HIGH);  // B 방향 바꿈
}

void moveBackward() {
  Serial.println("후진!");
  
  ledcWrite(MOTOR_A_ENABLE, 200);
  ledcWrite(MOTOR_B_ENABLE, 200);
  
  // 후진 방향 설정 (양쪽 모터 모두 방향 바꿈)
  digitalWrite(MOTOR_A_PIN1, LOW);   // A 방향 원복
  digitalWrite(MOTOR_A_PIN2, HIGH);  // A 방향 원복
  digitalWrite(MOTOR_B_PIN1, HIGH);  // B 방향 바꿈
  digitalWrite(MOTOR_B_PIN2, LOW);   // B 방향 바꿈
}

void turnLeft() {
  Serial.println("좌회전!");
  
  ledcWrite(MOTOR_A_ENABLE, 200);
  ledcWrite(MOTOR_B_ENABLE, 200);
  
  // 좌회전은 그대로 유지 (잘 작동한다고 했으니)
  digitalWrite(MOTOR_A_PIN1, HIGH);  // A 후진
  digitalWrite(MOTOR_A_PIN2, LOW);   
  digitalWrite(MOTOR_B_PIN1, HIGH);  // B 전진
  digitalWrite(MOTOR_B_PIN2, LOW);   
}

void turnRight() {
  Serial.println("우회전!");
  
  ledcWrite(MOTOR_A_ENABLE, 200);
  ledcWrite(MOTOR_B_ENABLE, 200);
  
  // 우회전도 그대로 유지 (잘 작동한다고 했으니)
  digitalWrite(MOTOR_A_PIN1, LOW);   // A 전진
  digitalWrite(MOTOR_A_PIN2, HIGH);  
  digitalWrite(MOTOR_B_PIN1, LOW);   // B 후진
  digitalWrite(MOTOR_B_PIN2, HIGH);  
}

void stopMotors() {
  Serial.println("모터 정지!");
  
  // 모든 핀 LOW
  digitalWrite(MOTOR_A_PIN1, LOW);
  digitalWrite(MOTOR_A_PIN2, LOW);
  digitalWrite(MOTOR_B_PIN1, LOW);
  digitalWrite(MOTOR_B_PIN2, LOW);
  
  // PWM 0
  ledcWrite(MOTOR_A_ENABLE, 0);
  ledcWrite(MOTOR_B_ENABLE, 0);
}

void testMotors() {
  Serial.println("=== 모터 테스트 시작 ===");
  
  Serial.println("전진 테스트");
  moveForward();
  delay(2000);
  stopMotors();
  delay(1000);
  
  Serial.println("후진 테스트");
  moveBackward();
  delay(1500);
  stopMotors();
  delay(1000);
  
  Serial.println("좌회전 테스트");
  turnLeft();
  delay(1000);
  stopMotors();
  delay(500);
  
  Serial.println("우회전 테스트");
  turnRight();
  delay(1000);
  stopMotors();
  
  Serial.println("=== 모터 테스트 완료 ===");
}

// ===============================
// 게임 로직 (단순화)
// ===============================
void startGame(int diceValue) {
  if (game.state != IDLE && game.state != COMPLETED) {
    Serial.println("게임 진행 중!");
    return;
  }
  
  Serial.printf("주사위 %d - 게임 시작!\n", diceValue);
  
  game.state = MOVING;
  game.targetSteps = diceValue;
  game.stepsCompleted = 0;
  game.gameStartTime = millis();
  
  // 즉시 전진 시작
  moveForward();
}

void handleMoving() {
  // 타임아웃 체크 (30초)
  if (millis() - game.gameStartTime > 30000) {
    Serial.println("타임아웃!");
    stopMotors();
    game.state = IDLE;
    return;
  }
  
  // 라인 체크
  bool leftSensor = (digitalRead(IR_SENSOR_LEFT) == LOW);
  bool rightSensor = (digitalRead(IR_SENSOR_RIGHT) == LOW);
  
  // 하나라도 라인 위에 있으면 OK
  game.onLine = (leftSensor || rightSensor);  

  if (!game.onLine) {
    Serial.println("라인 이탈!");
    stopMotors();
    delay(200);
    // 간단한 복구 시도
    turnLeft();
    delay(300);
    leftSensor = (digitalRead(IR_SENSOR_LEFT) == LOW);
    rightSensor = (digitalRead(IR_SENSOR_RIGHT) == LOW);
    game.onLine = (leftSensor || rightSensor);
    if (!game.onLine) {
      turnRight();
      delay(600);
    }
    moveForward();
    return;
  }
  
  // 색상 감지 (간단하게)
  String color = detectColor();
  
  if ((color == "RED" || color == "BLUE" || color == "GREEN") &&
      color != game.currentColor) {
    
    game.currentColor = color;
    game.stepsCompleted++;
    game.currentPosition++;
    
    Serial.printf("칸 감지: %s (%d/%d)\n", color.c_str(), game.stepsCompleted, game.targetSteps);
    
    sendToProcessing("SQUARE_DETECTED:" + String(game.currentPosition) + "," + color);

    if (game.stepsCompleted >= game.targetSteps) {
      Serial.println("목표 도착!");
      stopMotors();
      game.state = WAITING_RFID;
      game.gameStartTime = millis();
      sendToProcessing("TARGET_REACHED");

    } else {
      // 계속 전진
      moveForward();
    }
  }
}

void handleWaitingRFID() {
  // 1.5초 대기 후 RFID 스캔
  if (millis() - game.gameStartTime > 1500) {
    String rfid = scanRFID();
    if (rfid.length() > 0) {
      game.lastRFID = rfid;  // 이 줄이 빠져있었음!
      Serial.printf("RFID: %s\n", rfid.c_str());
    }
    // RFID 스캔 완료 시
    if (rfid.length() > 0) {
      sendToProcessing("RFID_SCANNED:" + rfid);
    } else {
      sendToProcessing("RFID_NONE");
    }

    // 턴 완료 시
    sendToProcessing("TURN_COMPLETED");
    
    game.state = COMPLETED;
    Serial.println("턴 완료!");
  }
}

// ===============================
// 센서 (단순화)
// ===============================
void initSensors() {
  Serial.println("센서 초기화 시작...");
  
  // RGB 센서
  Wire.begin(SDA_PIN, SCL_PIN);
  Wire.setClock(100000); // 100kHz로 안정화
  if (tcs.begin()) {
    Serial.println("✅ RGB 센서 OK");
  } else {
    Serial.println("⚠️ RGB 센서 연결 확인 필요");
  }
  
  // RFID 센서 (강화된 초기화)
  Serial.println("RFID 센서 초기화 중...");
  SPI.begin();
  delay(100); // SPI 안정화 대기
  
  mfrc522.PCD_Init();
  delay(200); // RFID 초기화 대기
  
  // RFID 센서 연결 확인
  byte version = mfrc522.PCD_ReadRegister(mfrc522.VersionReg);
  Serial.printf("RFID 버전: 0x%02X\n", version);
  
  if (version == 0x91 || version == 0x92) {
    Serial.println("✅ RFID 센서 OK");
  } else if (version == 0x00 || version == 0xFF) {
    Serial.println("❌ RFID 센서 연결 실패");
  } else {
    Serial.println("⚠️ RFID 센서 연결 불안정");
  }
  
  // RFID 안테나 게인 최대로 설정
  mfrc522.PCD_SetAntennaGain(mfrc522.RxGain_max);
  Serial.println("RFID 안테나 게인 최대로 설정");
}


String detectColor() {
  uint16_t r, g, b, c;
  tcs.getRawData(&r, &g, &b, &c);
  
  if (c < 50) return "DARK";
  
  float red = (float)r / c * 255;
  float green = (float)g / c * 255;
  float blue = (float)b / c * 255;
  
  // 간단한 색상 판별
  if (red > 120 && green < 80 && blue < 80) return "RED";
  if (blue > 100 && red < 70 && green < 120) return "BLUE";
  if (green > 100 && red < 90 && blue < 90) return "GREEN";
  
  return "UNKNOWN";
}

String scanRFID() {
  Serial.println("🔍 RFID 스캔 시작...");
  
  unsigned long scanStart = millis();
  String cardUID = "";
  int attempts = 0;
  const int MAX_ATTEMPTS = 20; // 2초간 20번 시도
  
  while (millis() - scanStart < 2000 && attempts < MAX_ATTEMPTS) {
    attempts++;
    
    // 카드 감지 확인
    if (!mfrc522.PICC_IsNewCardPresent()) {
      delay(100);
      continue;
    }
    
    // 카드 읽기 시도
    if (!mfrc522.PICC_ReadCardSerial()) {
      Serial.printf("읽기 실패 (시도 %d)\n", attempts);
      delay(100);
      continue;
    }
    
    // UID 추출
    Serial.printf("카드 감지! UID 크기: %d\n", mfrc522.uid.size);
    
    for (byte i = 0; i < mfrc522.uid.size; i++) {
      if (mfrc522.uid.uidByte[i] < 0x10) {
        cardUID += "0";
      }
      cardUID += String(mfrc522.uid.uidByte[i], HEX);
    }
    
    cardUID.toUpperCase();
    
    // 카드 선택 해제
    mfrc522.PICC_HaltA();
    mfrc522.PCD_StopCrypto1();
    
    Serial.printf("✅ RFID 성공: %s\n", cardUID.c_str());
    
    // LED 피드백
    for (int i = 0; i < 3; i++) {
      digitalWrite(4, HIGH);
      delay(100);
      digitalWrite(4, LOW);
      delay(100);
    }
    
    return cardUID;
  }
  
  Serial.printf("❌ RFID 스캔 실패 (총 %d회 시도)\n", attempts);
  return "";
}

// ===============================
// RFID 테스트 함수 추가 
// ===============================
void testRFID() {
  Serial.println("=== RFID 테스트 시작 ===");
  
  // RFID 센서 상태 확인
  byte version = mfrc522.PCD_ReadRegister(mfrc522.VersionReg);
  Serial.printf("RFID 버전: 0x%02X\n", version);
  
  if (version == 0x00 || version == 0xFF) {
    Serial.println("❌ RFID 센서 연결 안됨");
    return;
  }
  
  Serial.println("카드를 RFID 센서에 가져다 대세요... (5초 대기)");
  
  unsigned long testStart = millis();
  while (millis() - testStart < 5000) {
    String uid = scanRFID();
    if (uid.length() > 0) {
      Serial.printf("🎉 테스트 성공! UID: %s\n", uid.c_str());
      Serial.println("=== RFID 테스트 완료 ===");
      return;
    }
    delay(500);
  }
  
  Serial.println("⚠️ 5초 동안 카드가 감지되지 않음");
  Serial.println("=== RFID 테스트 완료 ===");
}


void resetGame() {
  stopMotors();
  game.state = IDLE;
  game.currentPosition = 0;
  game.targetSteps = 0;
  game.stepsCompleted = 0;
  game.currentColor = "";
  game.lastRFID = "";
  Serial.println("게임 리셋!");
}

// ===============================
// 웹서버 (단순화)
// ===============================
void setupWebServer() {
  server.on("/", HTTP_GET, handleRoot);
  
  // 주사위
  server.on("/dice", HTTP_GET, []() {
    int diceValue = server.arg("value").toInt();
    if (diceValue >= 1 && diceValue <= 6) {
      startGame(diceValue);
      server.send(200, "text/plain", "주사위 " + String(diceValue) + " 시작!");
    } else {
      server.send(400, "text/plain", "잘못된 값");
    }
  });
  
  // 수동 제어
  server.on("/manual_forward", HTTP_GET, []() {
    moveForward();
    server.send(200, "text/plain", "전진!");
  });
  
  server.on("/manual_backward", HTTP_GET, []() {
    moveBackward();
    server.send(200, "text/plain", "후진!");
  });
  
  server.on("/manual_left", HTTP_GET, []() {
    turnLeft();
    server.send(200, "text/plain", "좌회전!");
  });
  
  server.on("/manual_right", HTTP_GET, []() {
    turnRight();
    server.send(200, "text/plain", "우회전!");
  });
  
  server.on("/manual_stop", HTTP_GET, []() {
    stopMotors();
    server.send(200, "text/plain", "정지!");
  });
  
  server.on("/reset_game", HTTP_GET, []() {
    resetGame();
    server.send(200, "text/plain", "리셋 완료!");
  });
  
  server.on("/test_motors", HTTP_GET, []() {
    testMotors();
    server.send(200, "text/plain", "모터 테스트 완료!");
  });
  
   server.on("/test_rfid", HTTP_GET, []() {
    String uid = scanRFID();
    if (uid.length() > 0) {
      server.send(200, "text/plain", "RFID 성공: " + uid);
    } else {
      server.send(200, "text/plain", "RFID 카드 없음");
    }
  });
  
  server.on("/rfid_status", HTTP_GET, []() {
    byte version = mfrc522.PCD_ReadRegister(mfrc522.VersionReg);
    String status = "RFID 버전: 0x" + String(version, HEX);
    if (version == 0x91 || version == 0x92) {
      status += " (정상)";
    } else if (version == 0x00 || version == 0xFF) {
      status += " (연결 실패)";
    } else {
      status += " (불안정)";
    }
    server.send(200, "text/plain", status);
  });
  
  server.on("/game_status", HTTP_GET, []() {
    String status = "위치:" + String(game.currentPosition);
    status += " | 색상:" + game.currentColor;
    status += " | RFID:" + game.lastRFID;
    status += " | 상태:";
    
    switch (game.state) {
      case IDLE: status += "대기"; break;
      case MOVING: status += "이동중"; break;
      case WAITING_RFID: status += "RFID대기"; break;
      case COMPLETED: status += "완료"; break;
    }
    
    status += " | 라인:" + String(game.onLine ? "✅" : "❌");
    
    server.send(200, "text/plain", status);
  });
}

void handleRoot() {
  String html = R"(
<!DOCTYPE html>
<html><head>
<title>부루마불 RC카 SIMPLE</title>
<meta name='viewport' content='width=device-width,initial-scale=1'>
<style>
body{font-family:Arial;margin:20px;background:#667eea;color:white;text-align:center}
.container{max-width:500px;margin:0 auto;background:rgba(255,255,255,0.1);border-radius:20px;padding:30px}
h1{font-size:24px;margin-bottom:30px}
.btn{background:#28a745;border:none;color:white;padding:15px 20px;margin:8px;cursor:pointer;border-radius:8px;font-size:16px}
.btn:hover{background:#218838}
.btn-dice{background:#ffc107;color:#000;font-size:18px;padding:20px}
.btn-danger{background:#dc3545}
.dice-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;max-width:300px;margin:20px auto}
.control-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:10px;margin:20px auto}
.status{background:rgba(255,255,255,0.1);border-radius:10px;padding:15px;margin:20px 0;font-size:14px}
</style>
</head><body>
<div class='container'>
<h1>🎲 부루마불 RC카 SIMPLE</h1>

<h2>주사위</h2>
<div class='dice-grid'>
<button class='btn btn-dice' onclick='rollDice(1)'>🎲 1</button>
<button class='btn btn-dice' onclick='rollDice(2)'>🎲 2</button>
<button class='btn btn-dice' onclick='rollDice(3)'>🎲 3</button>
<button class='btn btn-dice' onclick='rollDice(4)'>🎲 4</button>
<button class='btn btn-dice' onclick='rollDice(5)'>🎲 5</button>
<button class='btn btn-dice' onclick='rollDice(6)'>🎲 6</button>
</div>

<h2>수동 제어</h2>
<div class='control-grid'>
<button class='btn' onclick='manualControl("forward")'>⬆️ 전진</button>
<button class='btn' onclick='manualControl("backward")'>⬇️ 후진</button>
<button class='btn' onclick='manualControl("left")'>⬅️ 좌</button>
<button class='btn' onclick='manualControl("right")'>➡️ 우</button>
<button class='btn btn-danger' onclick='manualControl("stop")'>⏹️ 정지</button>
<button class='btn' onclick='testMotors()'>🧪 모터 테스트</button>
<button class='btn' onclick='testRFID()'>🏷️ RFID 테스트</button>
<button class='btn btn-danger' onclick='resetGame()'>🔄 리셋</button>
</div>

<div id='status' class='status'>준비됨</div>

</div>

<script>
function rollDice(n){
  document.getElementById('status').innerHTML = '🎲 주사위 ' + n + ' 실행 중...';
  fetch('/dice?value=' + n).then(r => r.text()).then(d => {
    document.getElementById('status').innerHTML = d;
  });
}

function manualControl(direction) {
  document.getElementById('status').innerHTML = '🎮 ' + direction + ' 실행 중...';
  fetch('/manual_' + direction).then(r => r.text()).then(d => {
    document.getElementById('status').innerHTML = d;
  });
}

function testMotors() {
  document.getElementById('status').innerHTML = '🧪 모터 테스트 중...';
  fetch('/test_motors').then(r => r.text()).then(d => {
    document.getElementById('status').innerHTML = d;
  });
}

function resetGame() {
  fetch('/reset_game').then(r => r.text()).then(d => {
    document.getElementById('status').innerHTML = d;
  });
}

function testRFID() {
  document.getElementById('status').innerHTML = '🏷️ RFID 테스트 중...';
  fetch('/test_rfid').then(r => r.text()).then(d => {
    document.getElementById('status').innerHTML = d;
  });
}

// 자동 상태 업데이트
setInterval(() => {
  fetch('/game_status').then(r => r.text()).then(d => {
    if (!document.getElementById('status').innerHTML.includes('중...')) {
      document.getElementById('status').innerHTML = d;
    }
  });
}, 2000);
</script>
</body></html>
  )";
  
  server.send(200, "text/html", html);
}

// ===============================
// Processing WiFi 통신 함수들
// ===============================
void handleProcessingWiFi() {
  // 새로운 클라이언트 연결 확인
  if (!processingConnected && processingServer.hasClient()) {
    processingClient = processingServer.available();
    processingConnected = true;
    Serial.println("Processing 연결됨!");
    sendToProcessing("READY"); // Processing에게 준비 완료 신호
  }
  
  // 연결된 클라이언트에서 데이터 읽기
  if (processingConnected && processingClient.connected()) {
    while (processingClient.available()) {
      int c = processingClient.read();
      
      if (c >= 1 && c <= 6) {
         Serial.printf("Processing에서 숫자 수신: %d\n", c);
         startGameFromProcessing(c); // 받은 칸 수만큼 이동 시작
         inputBuffer = ""; // 버퍼 초기화
      }
      else if (c == '\n') {
        processWiFiCommand(inputBuffer);
        inputBuffer = "";
      }
      
       else {
        inputBuffer += c;
      }
    }
  } else if (processingConnected) {
    // 연결이 끊어진 경우
    processingConnected = false;
    Serial.println("Processing 연결 끊어짐");
  }
}

void processWiFiCommand(String command) {
  command.trim();
  
  if (command.startsWith("DICE:")) {
    int diceValue = command.substring(5).toInt();
    if (diceValue >= 1 && diceValue <= 6) {
      sendToProcessing("RECEIVED_DICE:" + String(diceValue));
      startGameFromProcessing(diceValue);
    }
  }
  else if (command == "STATUS") {
    sendStatusToProcessing();
  }
  else if (command == "RESET") {
    resetGame();
    sendToProcessing("GAME_RESET");
  }
  else if (command.startsWith("MANUAL:")) {
    String direction = command.substring(7);
    direction.toLowerCase();
    handleManualFromProcessing(direction);
  }
}

void sendToProcessing(String message) {
  if (processingConnected && processingClient.connected()) {
    processingClient.println(message);
    Serial.println("→ Processing: " + message); // 디버깅용
  }
}

void startGameFromProcessing(int diceValue) {
  if (game.state != IDLE && game.state != COMPLETED) {
    sendToProcessing("GAME_BUSY");
    return;
  }
  
  sendToProcessing("GAME_START:" + String(diceValue));
  
  game.state = MOVING;
  game.targetSteps = diceValue;
  game.stepsCompleted = 0;
  game.gameStartTime = millis();
  
  moveForward();
}

void sendStatusToProcessing() {
  String status = "STATUS:";
  status += "pos=" + String(game.currentPosition);
  status += ",color=" + game.currentColor;
  status += ",state=" + String(game.state);
  status += ",steps=" + String(game.stepsCompleted) + "/" + String(game.targetSteps);
  status += ",line=" + String(game.onLine ? 1 : 0);
  status += ",rfid=" + game.lastRFID;
  
  sendToProcessing(status);
}

void handleManualFromProcessing(String direction) {
  if (direction == "forward") {
    moveForward();
    sendToProcessing("MANUAL_OK:FORWARD");
  }
  else if (direction == "backward") {
    moveBackward();
    sendToProcessing("MANUAL_OK:BACKWARD");
  }
  else if (direction == "left") {
    turnLeft();
    sendToProcessing("MANUAL_OK:LEFT");
  }
  else if (direction == "right") {
    turnRight();
    sendToProcessing("MANUAL_OK:RIGHT");
  }
  else if (direction == "stop") {
    stopMotors();
    sendToProcessing("MANUAL_OK:STOP");
  }
}

