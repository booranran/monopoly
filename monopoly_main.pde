import java.util.Collections;
import processing.net.*;


void setup() {
  size(1280, 720, P3D);
  background(#fafafa);
  textureMode(NORMAL);
  
  myClient = new Client(this, "172.20.10.2", 8888);

  boardImage = loadImage("board.png"); // data 폴더에 이미지 넣어야 함

  initDice();
  players = new Player[2];
  players[0] = new Player(1, "Player 1", 800000);
  players[1] = new Player(2, "Player 2", 400);

  p = players[0];

  showButtons = true;
  yesButton = new Button(403, 617, 218, 62, "YES", -1);
  noButton = new Button(663, 617, 218, 62, "NO", -1);
  
  buyButton = new Button(width/2, 617, 218, 62, "BUY", -1, true);
  confirmButton = new Button(width/2, 617, 218, 62, "CONFIRM", -1, true);
  rollButton = new Button(width/2, 617, 218, 62, "ROLL", -1, true);


  villa = new Quantity(234, 527, 0, 2, 0, "VILLA");
  building = new Quantity(576, 527, 0, 1, 0, "BUILDING");
  hotel = new Quantity(929, 527, 0, 1, 0, "HOTEL");

  font = loadFont("NotoSansKR-Thin_Bold-48.vlw");

  textFont(font);

  money_X = width/2;
  money_Y = height/2;
  money_X2 = 1052;
  money_Y2 = 604;

  uidNameMap.put("41103480", new RfidInfo("BEIJING", 1));
  uidNameMap.put("1E7b3480", new RfidInfo("CAIRO", 2));
  uidNameMap.put("95363480", new RfidInfo("ISTANBUL", 3));
  uidNameMap.put("0A493680", new RfidInfo("MANILA", 4));
  uidNameMap.put("E3563680", new RfidInfo("SINGAPORE", 5));
  uidNameMap.put("D6793480", new RfidInfo("OTTAWA", 6));
  uidNameMap.put("BORAN5", new RfidInfo("ISLAND", 7));

  uidNameMap.put("7EF63380", new RfidInfo("BERLIN", 8));
  uidNameMap.put("719B3580", new RfidInfo("BERN", 9));
  uidNameMap.put("83113580", new RfidInfo("STOCKHOLM", 10));
  uidNameMap.put("9A4B3480", new RfidInfo("COPENHAGEN", 11));
  uidNameMap.put("BORAN7", new RfidInfo("SPACE", 12));


  uidNameMap.put("D9583680", new RfidInfo("LISBON", 13));
  uidNameMap.put("9B553680", new RfidInfo("MADRID", 14));
  uidNameMap.put("BA6C3680", new RfidInfo("HAWAII", 15));
  uidNameMap.put("9E483480", new RfidInfo("SYDNEY", 16));
  uidNameMap.put("0B343680", new RfidInfo("NEWYORK", 17));
  uidNameMap.put("FD143480", new RfidInfo("SAOPAULO", 18));

  uidNameMap.put("BORAN6", new RfidInfo("EVENT", 19));

  uidNameMap.put("0B653680", new RfidInfo("ROME", 20));
  uidNameMap.put("D3103580", new RfidInfo("SEOUL", 21));
  uidNameMap.put("E9253680", new RfidInfo("PARIS", 22));
  uidNameMap.put("E23F3580", new RfidInfo("TOKYO", 23));

  uidNameMap.put("12654F05", new RfidInfo("SALARY", 0));


  Table t = loadTable("country.csv", "header");

  for (TableRow r : t.rows()) {
    String key = r.getString("key"); // 예: "SEOUL"
    Country c = new Country(
      r.getString("name"),
      r.getInt("price"),
      r.getInt("land_fee"),
      r.getInt("villa_fee"),
      r.getInt("building_fee"),
      r.getInt("hotel_fee"),
      r.getInt("villaCost"),
      r.getInt("hotelCost"),
      r.getInt("buildingCost")
      );
    countryData.put(key, c);
  }
  println("로드된 국가 수: " + countryData.size());

  cityNames = new String[24];
  cityButtons = new Button[24];

  println(cityNames.length);
  int index = 0;
  for (RfidInfo info : uidNameMap.values()) {
    if (info.boardIndex >= 0 && info.boardIndex < 24) {
      cityNames[info.boardIndex] = info.name;
    }
  }

  // 1. 레이아웃 계산 (8x6 구조, 총 24칸)
  int sidebarWidth = 320;
  int cornerSize = 110;
  int cellW = 100;

  // 전체 보드 크기: 820 x 620
  int boardW = (cornerSize * 2) + (cellW * 6);
  int boardH = (cornerSize * 2) + (cellW * 4);

  // 우측 영역 중앙 정렬 시작점 (좌상단 기준)
  int startX = sidebarWidth + (width - sidebarWidth - boardW) / 2;
  int startY = (height - boardH) / 2;

  // 2. 버튼 생성 (0번: 좌상단 Start -> 시계 방향)
  for (int i = 0; i < 24; i++) {
    if (cityNames[i] == null) cityNames[i] = "EMPTY";

    float bx = 0, by = 0;
    float bw = 0, bh = 0;

    if (i == 0) {
      // [0] 좌상단 코너 (START)
      bx = startX;
      by = startY;
      bw = cornerSize;
      bh = cornerSize;
    } else if (i > 0 && i < 7) {
      // [1~6] 상단변 (좌->우)
      bx = startX + cornerSize + ((i - 1) * cellW);
      by = startY;
      bw = cellW;
      bh = cornerSize;
    } else if (i == 7) {
      // [7] 우상단 코너
      bx = startX + boardW - cornerSize;
      by = startY;
      bw = cornerSize;
      bh = cornerSize;
    } else if (i > 7 && i < 12) {
      // [8~11] 우측변 (상->하)
      bx = startX + boardW - cornerSize;
      by = startY + cornerSize + ((i - 8) * cellW);
      bw = cornerSize;
      bh = cellW;
    } else if (i == 12) {
      // [12] 우하단 코너
      bx = startX + boardW - cornerSize;
      by = startY + boardH - cornerSize;
      bw = cornerSize;
      bh = cornerSize;
    } else if (i > 12 && i < 18) {
      // [13~18] 하단변 (우->좌)
      bx = (startX + boardW - cornerSize) - cellW - ((i - 13) * cellW);
      by = startY + boardH - cornerSize;
      bw = cellW;
      bh = cornerSize;
    } else if (i == 18) {
      // [19] 좌하단 코너
      bx = startX;
      by = startY + boardH - cornerSize;
      bw = cornerSize;
      bh = cornerSize;
    } else {
      // [20~23] 좌측변 (하->상)
      bx = startX;
      by = (startY + boardH - cornerSize) - cellW - ((i - 19) * cellW);
      bw = cornerSize;
      bh = cellW;
    }

    cityButtons[i] = new Button((int)bx, (int)by, (int)bw, (int)bh, cityNames[i], i, true);
  }

  // 마지막에 위치 초기화 필수!
  initializePlayerPositions();
}

void draw() {
  // 1. [배경 레이어] 화면 전체를 깨끗하게 지움
  background(#fafafa);
  imageMode(CORNER);
  int boardW = (110 * 2) + (100 * 6); // 820
  int boardH = (110 * 2) + (100 * 4); // 620
  int sidebarWidth = 320;
  int startX = sidebarWidth + (width - sidebarWidth - boardW) / 2;
  int startY = (height - boardH) / 2;

  image(boardImage, startX, startY, boardW, boardH);


  // 2. [기본 레이어] 항상 보여야 하는 것들 (사이드바 + 보드판 + 말)
  drawSidebar();       // ① 왼쪽 플레이어 정보창 그리기
  drawPlayers();       // ③ 플레이어 자동차 그리기

  // 3. [오버레이 레이어] 상황에 따라 위에 덮어씌우는 것들

  // (1) 주사위 굴리기 모드일 때 (보드판 위에 3D 주사위 띄우기)
  if (gameState.equals("DICE")) {
    drawDiceOverlay();
  }

  // (2) 각종 팝업창 (이벤트 발생 시 맨 위에 표시)
  // 기존 if문들을 그대로 쓰되, 'else'로 묶지 말고 필요한 것만 위에 얹음
  if (gameState.equals("BUY_LAND") && buyLandPopup) {
    showBuyLandPopup(countryName);
  } else if (gameState.equals("BUY_BUILDING") && buyBuildingPopup) {
    showBuyBuildingPopup();
  } else if (gameState.equals("CHOOSE_BUILDING") && chooseBuildingPopup) {
    showChooseBuildingPopup();
  } else if (gameState.equals("PAY_TOLL") && payTollPopup) {
    showTollPopup();
  } else if (gameState.equals("SALARY") && salaryPopup) {
    showSalaryPopup();
  } else if (gameState.equals("ISLAND") && islandPopup) {
    showIslandPopup();
  } else if (gameState.equals("EVENT") && eventPopup) {
    showEventPopup();
  } else if (gameState.equals("SPACE") && spacePopup) {
    showSpacePopup();
  } else if (gameState.equals("THE_END") && gameEndPopup) {
    showcheckGameEnd();
  }

  // ※ 'showIdlePopup'은 이제 drawSidebar가 역할을 대신하므로 삭제하거나
  //   IDLE 상태일 때만 특정 버튼을 보여주는 용도로 축소해야 함.
}
boolean isEventPopupState() {
  return gameState.equals("BUY_LAND") || gameState.equals("PAY_TOLL") ||
    gameState.equals("EVENT") || gameState.equals("ISLAND") || gameState.equals("THE_END");
}
