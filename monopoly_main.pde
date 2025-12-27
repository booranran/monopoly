import processing.serial.*;
import java.util.Collections;


void setup() {
  size(1280, 720, P3D);
  background(#fafafa);
  textureMode(NORMAL);

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

  cityNames = new String[countryData.size()];
  int index = 0;
  for (String name : countryData.keySet()) {
    cityNames[index] = name;
    index++;
  }

  cityButtons = new Button[cityNames.length];

  // 3. 루프를 돌면서 버튼 생성 및 배열에 추가
  for (int i = 0; i < cityNames.length; i++) {
    int x = 50 + (i % 3) * 120; // 가로 위치 계산
    int y = 100 + (i / 3) * 80;  // 세로 위치 계산

    // 버튼 생성자에 올바른 인자를 전달
    // label에는 cityNames[i]를, idx에는 i를 전달
    cityButtons[i] = new Button(x, y, 100, 50, cityNames[i], i, true);
  }
  
  initializePlayerPositions();
}

void draw() {
  // 매 프레임마다 배경을 한 번만 지워줍니다.
  background(#fafafa);  
  //// 팝업이 띄워져 있는지 확인
  boolean isAnyPopupActive = false;
  
  // 1. 맵(버튼들) 그리기
  for (Button b : cityButtons) {
    b.display();
  }

  // 2. 플레이어(미니카) 업데이트 및 그리기
  // 팝업보다 아래, 버튼보다 위에 그려야 자연스러움
  for (Player p : players) {
    p.updateAndDraw(); // ★ 여기서 이동 계산 + 경로선 그리기 + 차 그리기 다 함
  }
  
  // 3. 각종 팝업 그리기 (기존 코드 유지)
  if (gameState.equals("BUY_LAND")) {
     // ...
  }
  
 

  if (buyLandPopup && gameState.equals("BUY_LAND")) {
    //background(#fafafa);
    showBuyLandPopup(countryName);
    isAnyPopupActive = true;
  }

  if (buyBuildingPopup && gameState.equals("BUY_BUILDING")) {
    showBuyBuildingPopup();
    isAnyPopupActive = true;
  }

  if (chooseBuildingPopup && gameState.equals("CHOOSE_BUILDING")) {
    showChooseBuildingPopup();
    isAnyPopupActive = true;
  }

  if (payTollPopup && gameState.equals("PAY_TOLL")) {
    showTollPopup();
    isAnyPopupActive = true;
  }

  if (gameEndPopup && gameState.equals("THE_END")) {
    showcheckGameEnd();
    isAnyPopupActive = true;
  }

  if (salaryPopup && gameState.equals("SALARY")) {
    showSalaryPopup();
    isAnyPopupActive = true;
  }

  if (islandPopup && gameState.equals("ISLAND")) {
    showIslandPopup();
    isAnyPopupActive = true;
  }

  if (eventPopup && gameState.equals("EVENT")) {
    showEventPopup();
    isAnyPopupActive = true;
  }

  if (spacePopup && gameState.equals("SPACE")) {
    showSpacePopup();
    isAnyPopupActive = true;
  }

  ////// 어떤 팝업도 활성화되지 않았을 때만 기본 화면을 보여줍니다.
  if (!isAnyPopupActive) {
    showIdlePopup();
  }

  if (dicePopup && gameState.equals("DICE")) {
    showDicePopup();
    updateRollAndMaybeMove();
    isAnyPopupActive = true;
  }
}

void mousePressed() {


  Player p = getCurrentPlayer();

  switch (gameState) {

  case "IDLE":
    if (rollButton.isMouseOver()) {
      dicePopup = true;
      gameState = "DICE";
      startRoll();
      println(gameState);
      println("let's roll a dice!");
      return;
    }
    break;

  case "BUY_LAND":
    // 토지 팝업: 여기서만 돈 차감
    if (buyLandPopup) {
      if (yesButton.isMouseOver()) {
        // 이중 안전장치(이미 샀으면 또 차감 금지)
        if (!selectedCountry.purchased) {
          if (p.money >= selectedCountry.price) {
            p.money -= selectedCountry.price;
            selectedCountry.purchased = true;
            selectedCountry.ownerId = p.id;
            p.ownedCountries.add(selectedCountry.name);
            println(p.name + "구매" + selectedCountry.name);
          } else {

            currentMessage = "돈 없음!";
            println(currentMessage);

            buyLandPopup = false;
            Turn();
            gameState = "IDLE";
            return;
          }
        } else {
          buyLandPopup = false;
          Turn();
          gameState = "IDLE";
          return;
        }

        buyLandPopup = false;
        buyBuildingPopup = true;
        println(gameState);

        gameState = "BUY_BUILDING";
        println(gameState);
        return;
      } else if (noButton.isMouseOver()) {
        buyLandPopup = false;
        Turn();
        gameState = "IDLE";
        return;
      }
    }
    break;

  case "BUY_BUILDING":
    if (buyBuildingPopup&&gameState.equals("BUY_BUILDING")) {

      if (yesButton.isMouseOver())
      {
        buyBuildingPopup = false;
        chooseBuildingPopup = true;
        gameState = "CHOOSE_BUILDING";
        println(gameState);
        return;
      } else if (noButton.isMouseOver()) {
        buyBuildingPopup = false;
        Turn();
        gameState = "IDLE";
        return;
      }
    }
    break;

  case "CHOOSE_BUILDING":
    if (chooseBuildingPopup&&gameState.equals("CHOOSE_BUILDING")) {
      println(selectedCountry);
      boolean changed = false;
      changed |= villa.handleClick(selectionTotal());
      changed |= building.handleClick(selectionTotal());
      changed |= hotel.handleClick(selectionTotal());

      if (buyButton.isMouseOver()) {
        int cost = selectionCost();
        if (cost<=p.money) {
          p.money -= cost;

          selectedCountry.villaCount += villa.get();
          selectedCountry.buildingCount += building.get();
          selectedCountry.hotelCount += hotel.get();

          villa.set(0);
          building.set(0);
          hotel.set(0);

          chooseBuildingPopup = false;
          Turn();
          gameState = "IDLE";
          println(gameState);

          return;
        } else {
          Turn();
          println("돈부족");
        }
      }
    }

  case "PAY_TOLL":
    if (payTollPopup&&gameState.equals("PAY_TOLL")) {
      if (payTollPopup && confirmButton.isMouseOver()) {

        // 통행료 계산
        int toll = selectedCountry.currentRent();

        // 땅 주인 찾기
        Player owner = players[selectedCountry.ownerId-1]; // id는 1부터 시작하므로 -1

        // 현재 플레이어의 돈이 통행료보다 많으면
        if (p.money >= toll) {
          p.money -= toll; // 통행료 지불
          owner.money += toll;       // 땅 주인에게 통행료 지급
          //println(p.name + "가 " + selectedCountry.name + "의 통행료 " + toll + "원을 지불했습니다.");
          currentMessage = p.name + "가 " + selectedCountry.name + "의 통행료 " + toll + "원을 지불했습니다.";
          println(currentMessage);
        } else {
          // 돈이 부족하면 파산
          //println(p.name + "의 돈이 부족합니다! 파산.");
          currentMessage = p.name + "의 돈이 부족합니다! 파산. ";
          p.isBankrupt = true; // 파산 상태로 만듦
          showcheckGameEnd();
          return;
        }
        // 통행료 지불이 끝났으니, 다음 턴으로 넘기고 팝업 닫기

        payTollPopup = false;
        Turn();
        gameState = "IDLE";
      }
      break;
    }
  case "SALARY":
    if (confirmButton.isMouseOver()) {
      p.money += 20000;
      println(p.name + "의 돈" + p.money);
      salaryPopup = false;
      Turn();
      gameState = "IDLE";
      break;
    }

  case "ISLAND":
    if (confirmButton.isMouseOver()) {
      println("island");
      Turn();
      gameState = "IDLE";
      break;
    }

  case "EVENT":
    if (confirmButton.isMouseOver()) {
      println(gameState);
      eventPopup = false;
      gameState = "IDLE";
      Turn();
      return;
    }
    break;

  case "SPACE":
    if (spacePopup) {
      for (int i = 0; i < cityButtons.length; i++) {
        if (cityButtons[i].isMouseOver()) {
          String destinationName = cityButtons[i].label;
          println(destinationName + " 여기를 선택했어요");

          // 키 유효성 체크(선택 실수 방지)
          if (!countryData.containsKey(destinationName)) {
            println("[SPACE] unknown destination: " + destinationName);
            return;
          }

          // 이름 매칭으로 boardIndex 찾기
          for (String uid : uidNameMap.keySet()) {
            RfidInfo info = uidNameMap.get(uid);
            if (info.name.equals(destinationName)) {
              // 위치 이동 + 이벤트 처리
              p.position = info.boardIndex;
              processBoardIndex(p.position);

              // 우주여행 팝업 정리(다음 입력 가로막지 않도록)
              spacePopup = false;
              Turn();                // 턴 넘길지/안넘길지 정책에 맞게
              return;                // 찾았으니 종료
            }
          }

          // 여기까지 왔다는 건 RFID 매칭 실패
          println("[SPACE] RFID mapping not found for: " + destinationName);
          return;
        }
      }
    }
    break;

  default:
    break;
  }
}

void keyTyped() {
  if (key == '1') {
    processTagEvent("41103480"); // 베이징 태그
  } else if (key == '2') {
    processTagEvent("95363480"); // 이스탄불  태그
  } else if (key=='3') {
    processTagEvent("1E7b3480");
  } else if (key=='4') {
    processTagEvent("E3563680");
  } else if (key=='5') {
    processTagEvent("12654F05");
  } else if (key=='6') {
    processTagEvent("BORAN5");
  } else if (key=='7') {
    processTagEvent("BORAN6");
  } else if (key == '8') {
    processTagEvent("BORAN7");
  }
}
