import processing.serial.*;
import java.util.Collections;


void setup() {
  size(1280, 720, P3D);
  background(#fafafa);
  textureMode(NORMAL);

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
  uidNameMap.put("95363480", new RfidInfo("ISTANBUL", 2));
  uidNameMap.put("1E7b3480", new RfidInfo("CAIRO", 3));
  uidNameMap.put("0A493680", new RfidInfo("MANILA", 4));
  uidNameMap.put("E3563680", new RfidInfo("SINGAPORE", 5));
  uidNameMap.put("D6793480", new RfidInfo("OTTAWA", 7));

  uidNameMap.put("7EF63380", new RfidInfo("BERLIN", 8));
  uidNameMap.put("719B3580", new RfidInfo("BERN", 9));
  uidNameMap.put("83113580", new RfidInfo("STOCKHOLM", 10));
  uidNameMap.put("9A4B3480", new RfidInfo("COPENHAGEN", 11));

  uidNameMap.put("FD143480", new RfidInfo("SAOPAULO", 13));
  uidNameMap.put("D9583680", new RfidInfo("LISBON", 14));
  uidNameMap.put("9B553680", new RfidInfo("MADRID", 15));
  uidNameMap.put("BA6C3680", new RfidInfo("HAWAII", 16));
  uidNameMap.put("9E483480", new RfidInfo("SYDNEY", 17));
  uidNameMap.put("0B343680", new RfidInfo("NEWYORK", 19));

  uidNameMap.put("E23F3580", new RfidInfo("TOKYO", 20));
  uidNameMap.put("E9253680", new RfidInfo("PARIS", 21));
  uidNameMap.put("0B653680", new RfidInfo("ROME", 22));
  uidNameMap.put("D3103580", new RfidInfo("SEOUL", 23));

  uidNameMap.put("12654F05", new RfidInfo("SALARY", 0));
  uidNameMap.put("BORAN5", new RfidInfo("ISLAND", 6));
  uidNameMap.put("BORAN6", new RfidInfo("EVENT", 18));
  uidNameMap.put("BORAN7", new RfidInfo("SPACE", 12));


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
  
  int sidebarWidth = 320; 
  int cornerSize = 110;
  int cellW = 100; 
  
  int boardW = (cornerSize * 2) + (cellW * 6); // 820
  int boardH = (cornerSize * 2) + (cellW * 4); // 620
  
  // 우측 영역 중앙 정렬
  int startX = sidebarWidth + (width - sidebarWidth - boardW) / 2;
  int startY = (height - boardH) / 2;

  // 3. 순서대로(0~23) 버튼 좌표 계산 및 생성
  for (int i = 0; i < 24; i++) {
    // 혹시라도 이름이 비어있으면(매핑 누락) "Empty"로 채움 (에러 방지)
    if (cityNames[i] == null) cityNames[i] = "EMPTY"; 

    float bx = 0, by = 0;
    float bw = 0, bh = 0;

    if (i >= 0 && i < 7) { 
      // [하단] 0(출발) ~ 6(무인도) : 오른쪽 -> 왼쪽
      if (i == 0) { // 출발점(코너)
        bx = startX + boardW - cornerSize/2.0f;
        bw = cornerSize;
      } else {
        bx = (startX + boardW - cornerSize) - (cellW/2.0f) - ((i - 1) * cellW);
        bw = cellW;
      }
      by = startY + boardH - cornerSize/2.0f;
      bh = cornerSize;
      
    } else if (i >= 7 && i < 12) {
      // [좌측] 7(오타와) ~ 11(코펜하겐) : 아래 -> 위
      if (i == 7) { // 7번은 그냥 일반 칸이지만 코너 바로 위
         // (주의: 8x6 구조에서 7번은 코너가 아닙니다. 7번은 오타와)
         // 6번이 무인도(코너)여야 함. 로직 재확인 필요하지만, 일단 배치 로직 유지
      }
      // ※ 중요: 8x6 배치에서 코너는 0, 7, 12, 19번 인덱스여야 모양이 나옴
      // 하지만 현재 게임 룰(24칸)상 코너는 0(월급), 6(무인도), 12(우주), 18(이벤트) 임.
      // 따라서 배치는 7칸-5칸-7칸-5칸(총 24)이 아니라, 변의 길이에 맞게 좌표만 잘 잡으면 됨.
      
      // 아래는 "시각적 배치"를 위한 로직 (인덱스 i에 따라 좌표 할당)
      // 하단변(0~6), 좌측변(7~11), 상단변(12~18), 우측변(19~23) ... 총 24개
      
      // 하단 (0~6)
      if (i <= 6) {
          // 위에서 처리함 (else if 구조 밖으로 빼는 게 좋음, 일단 여기서는 흐름만)
      }
    } 
    
    // ▲ 위 복잡한 if문 대신 아래의 "단순화된 좌표 계산"을 쓰세요! (강추)
    
    if (i == 0) { // 우하단 코너 (월급)
       bx = startX + boardW - cornerSize/2.0f; by = startY + boardH - cornerSize/2.0f; bw=cornerSize; bh=cornerSize;
    } else if (i > 0 && i < 7) { // 하단변 (베이징~무인도전) -> 무인도가 6번? 아님. 0~6이면 7칸임.
       // 24칸을 4변으로 나누면: 7, 5, 7, 5개
       // 하단: 0(코너) + 1,2,3,4,5 + 6(코너) => 총 7칸
       bx = (startX + boardW - cornerSize) - (cellW/2.0f) - ((i-1)*cellW);
       by = startY + boardH - cornerSize/2.0f; bw=cellW; bh=cornerSize;
       if (i==6) { // 6번이 좌하단 코너(무인도)
         bx = startX + cornerSize/2.0f; bw=cornerSize;
       }
    } else if (i > 6 && i < 12) { // 좌측변 (7~11) 5칸
       bx = startX + cornerSize/2.0f; 
       by = (startY + boardH - cornerSize) - (cellW/2.0f) - ((i-7)*cellW);
       bw=cornerSize; bh=cellW;
    } else if (i == 12) { // 좌상단 코너 (우주)
       bx = startX + cornerSize/2.0f; by = startY + cornerSize/2.0f; bw=cornerSize; bh=cornerSize;
    } else if (i > 12 && i < 18) { // 상단변 (13~17) 5칸 -> 아니 13,14,15,16,17 (5개) + 18(코너)
       bx = startX + cornerSize + (cellW/2.0f) + ((i-13)*cellW);
       by = startY + cornerSize/2.0f; bw=cellW; bh=cornerSize;
    } else if (i == 18) { // 우상단 코너 (이벤트)
       bx = startX + boardW - cornerSize/2.0f; by = startY + cornerSize/2.0f; bw=cornerSize; bh=cornerSize;
    } else { // 우측변 (19~23) 5칸
       bx = startX + boardW - cornerSize/2.0f;
       by = startY + cornerSize + (cellW/2.0f) + ((i-19)*cellW);
       bw=cornerSize; bh=cellW;
    }

    cityButtons[i] = new Button((int)bx, (int)by, (int)bw, (int)bh, cityNames[i], i, true);
  }

  // 마지막에 꼭 호출!
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
  //drawGameBoard();     // ② 오른쪽 보드판(버튼들) 그리기
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
