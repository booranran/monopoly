//-----------ui 함수----------------

void showDicePopup() {

  pushStyle();
  // 반투명 오버레이/카드 등은 선택
  // 배치 + 조명
  pushMatrix();
  translate(width/2, height/2 + fallY, 0);
  ambientLight(150, 150, 150);
  directionalLight(255, 255, 255, 0, 0, -1);

  rotateX(currentAngle.x);
  rotateY(currentAngle.y);
  drawTextureCube(50);
  popMatrix();

  // 결과 텍스트(선택)
  if (rollEnded) {
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(18);
    text("결과: " + diceNumber, messageX, messageY + 140);
  }
  popStyle();
}

void showBuyLandPopup(String country) {
  fill(0);

  if (selectedCountry != null) {
    fill(0);

    textSize(textSize);
    text(selectedCountry.name + "을(를) 구매 하시겠습니까?", messageX, messageY - 20);
    if (p.money < selectedCountry.price) {
      yesButton.enabled = false;
      textSize(20);
      text("돈이 부족해서 구매할 수 없습니다.", messageX, messageY + 15);
    } else {
      // 돈이 충분하면 yes 버튼 활성화
      yesButton.enabled = true;
    }

    yesButton.display();
    noButton.display();

    buyBuildingPopup = false;
    gameState = "BUY_LAND";
  }
}

void showBuyBuildingPopup() {

  textSize(textSize);
  text("건물을 지을까요?", messageX, messageY);
  yesButton.display();
  noButton.display();

  buyLandPopup = false;
  chooseBuildingPopup = false;
  gameState = "BUY_BUILDING";
}

void showChooseBuildingPopup() {
  textSize(textSize);
  text("건물을 골라주세요", messageX, messageY);

  if (displayMoney()<0) {
    // 돈이 부족하면 yes 버튼 비활성화
    buyButton.enabled = false;
    text("돈이 부족해서 구매할 수 없습니다.", messageX, messageY + 50);
  } else {
    // 돈이 충분하면 yes 버튼 활성화
    buyButton.enabled = true;
  }

  villa.display();
  building.display();
  hotel.display();
  buyButton.display();

  buyBuildingPopup = false;
  gameState = "CHOOSE_BUILDING";
}

void showTollPopup() {
  // 팝업에 표시될 텍스트
  text(selectedCountry.name + "에 도착했습니다!", messageX, messageY - 50);
  text(selectedCountry.ownerId + "P의 땅입니다.", messageX, messageY - 20);
  text("통행료 " + selectedCountry.currentRent() + "원을 지불해야 합니다.", messageX, messageY + 30);

  if (p.money<selectedCountry.currentRent()) {
    text("지불 할 돈이 없습니다!", messageX, messageY + 80);
    p.isBankrupt = true;
  }

  confirmButton.display();
  gameState = "PAY_TOLL";
}

// 게임 상태를 확인하고 승패를 결정하는 함수
void showcheckGameEnd() {
  int bankruptCount = 0;
  Player winner = null;

  // 파산한 플레이어 수를 세고, 승자를 찾습니다.
  for (int i = 0; i < players.length; i++) {
    if (players[i].isBankrupt == true) {
      bankruptCount++;
    } else {
      winner = players[i];
    }
  }

  // 모든 플레이어가 파산하고 한 명만 남았을 때
  if (bankruptCount == players.length - 1) {
    // 게임을 종료합니다
    gameState = "THE_END";
    gameEndPopup = true;
    println("게임 종료! 승자는 " + winner.name + "입니다.");
    text("게임 종료! 승자는 " + winner.name + "입니다!", messageX, messageY);
  }
}

void showSalaryPopup() {
  textSize(textSize);

  text("와! 월급날이다!", messageX, messageY);
  confirmButton.display();
}

void showIslandPopup() {
  textSize(textSize);
  text("무인도에 갇혔다!!", messageX, messageY);
  text(currentMessage, messageX, messageY + 30);
  confirmButton.display();
}

void showEventPopup() {
  textSize(textSize);

  text("랜덤 이벤트 발생!", messageX, messageY);
  text(currentMessage, messageX, messageY + 50);
  pushStyle();
  textSize(20);
  text(detail_currentMessage, messageX, messageY + 80);
  popStyle();
  confirmButton.display();
}

void showSpacePopup() {
  textSize(textSize);

  text("우주 여행을 떠나자!", messageX, messageY);
  for (int i = 0; i<cityButtons.length; i++) {
    cityButtons[i].display();
  }
}



//---------------계산함수-----------//
int selectionCost() {

  int villa_cost = villa.get() * selectedCountry.villaCost;
  int building_cost = building.get() * selectedCountry.buildingCost;
  int hotel_cost = hotel.get() * selectedCountry.hotelCost;

  int total = villa_cost + building_cost + hotel_cost;
  return total;
}

int displayMoney() {
  return p.money - selectionCost();
}

int selectionTotal() {
  return villa.get() + building.get() + hotel.get();
}

Player getCurrentPlayer() {
  return players[currentPlayer];
}

void Turn() {
  // 무인도 로직은 유지하되, 여기서 movePlayer 호출 금지!
  if (p.isIslanded) {
    p.islandTurns++;
    println(p.name + "는 무인도.. (남은 턴: " + (3 - p.islandTurns) + ")");

    if (p.islandTurns >= 3) {
      p.isIslanded = false;
      p.islandTurns = 0;
      println("무인도 탈출!");
    } else {
      nextTurn(); // 다음 사람으로 넘김
      return;
    }
  }

  nextTurn();
  gameState = "IDLE";
}


Player nextTurn() {
  // 현재 플레이어를 다음으로 넘기는 코드
  int nextPlayerIndex = (currentPlayer + 1) % players.length;

  // 다음 플레이어가 무인도에 갇혔으면 그 다음 플레이어로 넘어감
  while (players[nextPlayerIndex].isIslanded) {
    // 무인도 턴 수 증가
    players[nextPlayerIndex].islandTurns++;
    println(players[nextPlayerIndex].name + "는 무인도에 갇혔다. (남은 턴: " + (3 - players[nextPlayerIndex].islandTurns) + ")");

    // 3턴이 지나면 무인도에서 해방
    if (players[nextPlayerIndex].islandTurns >= 3) {
      players[nextPlayerIndex].isIslanded = false;
      players[nextPlayerIndex].islandTurns = 0;
      println(players[nextPlayerIndex].name + "가 무인도에서 탈출했습니다!");
    }

    // 무인도에 갇힌 플레이어를 건너뛰고 다시 다음 플레이어를 찾음
    nextPlayerIndex = (nextPlayerIndex + 1) % players.length;
  }

  // 최종적으로 플레이할 플레이어로 업데이트
  currentPlayer = nextPlayerIndex;
  p = players[currentPlayer];
  println("Now it's " + p.name + "'s turn!");

  return p;
}

void movePlayer(int steps) {
  // 현재 턴인 플레이어 가져오기 (p 변수가 전역이라면 p 사용, 아니면 배열에서 가져오기)
  // 안전하게 배열에서 가져오는 방식 추천
  Player cp = players[currentPlayer];

  int startPos = cp.position;
  int finalPos = (startPos + steps) % cityNames.length; // 혹은 BOARD_SIZE

  // 1. 월급 체크 (로직 유지)
  if (startPos + steps >= cityNames.length) {
    cp.money += 20000;
    println(cp.name + " 월급 획득! (+20000)");
  }

  // 2. 논리적 위치는 미리 업데이트 (데이터상으로는 이미 도착)
  cp.position = finalPos;

  // 3. ★ 핵심: 이동 경로 예약하기 (애니메이션용) ★
  // 한 칸씩 건너가면서 모든 좌표를 pathQueue에 담아야 함
  for (int i = 1; i <= steps; i++) {
    int nextIndex = (startPos + i) % cityNames.length;

    // 해당 칸의 버튼(투명 내비게이션) 가져오기
    Button target = cityButtons[nextIndex];

    // 버튼의 정중앙 좌표 계산
    float destX = target.x + target.w / 1.5f;
    float destY = target.y + target.h / 1.5f;

    // 큐에 추가 (이제 updateAndDraw가 이걸 보고 움직임)
    cp.pathQueue.add(new PVector(destX, destY));
  }

  println("이동 경로 계산 완료. 출발!");
}


void selectRandomEvent() {
  int randomIndex = (int)random(events.length);
  RandomEvent event = events[randomIndex];

  if (randomIndex == 7) {
    p.money += event.moneyChange;

    // 이벤트 결과를 팝업에 표시
    currentMessage = event.description;
    detail_currentMessage = event.detail_desc;
    p.isIslanded = true;
    p.islandTurns = 0;
  } else {
    // 현재 플레이어의 돈을 업데이트
    p.money += event.moneyChange;

    // 이벤트 결과를 팝업에 표시
    currentMessage = event.description;
    detail_currentMessage = event.detail_desc;
  }
  println(currentMessage);
  println(p.name + "의 현재 자산: " + p.money);
}


void processBoardIndex(int index) {
  for (String uid : uidNameMap.keySet()) {
    RfidInfo info = uidNameMap.get(uid);  // uid에 해당하는 RfidInfo 꺼냄

    if (info.boardIndex == index) {
      processTagEvent(uid);  // 기존 함수 그대로 호출
      break;                 // 찾았으니까 더 돌 필요 없음
    }
  }
}


// [2] 플레이어(자동차) 그리기 함수
void drawPlayers() {
  for (Player p : players) {
    p.updateAndDraw();
  }
}

// [3] 왼쪽 사이드바 그리기 (여기로 정보창 이사!)
void drawSidebar() {

  // 구분선
  stroke(200);
  line(320, 0, 320, height);

  // 텍스트 정보 표시
  fill(0);
  textAlign(LEFT, TOP);

  // 제목
  textSize(28);
  text("MONOPOLY", 20, 30);

  // 현재 턴 정보
  textSize(18);
  text("-----------------------", 20, 70);
  text("현재 턴: " + p.name, 20, 90);
  text("자산: " + p.money + "원", 20, 120);

  // 소유한 땅 목록
  text("-----------------------", 20, 160);
  text("[ 소유한 땅 목록 ]", 20, 180);

  textSize(14);
  int y = 210;
  for (String land : p.ownedCountries) {
    text("• " + land, 25, y);
    y += 25;
  }

  // [중요] 주사위 굴리기 버튼은 'IDLE' 상태일 때만 사이드바 하단에 표시
  if (gameState.equals("IDLE") && !p.isMoving) {
    rollButton.x = 160;   // 사이드바 가운데 좌표
    rollButton.y = 650;   // 아래쪽
    rollButton.display();
  }
}


void initializePlayerPositions() {
  if (cityButtons != null && cityButtons.length > 0) {
    Button startBtn = cityButtons[0]; // 0번 칸(출발지) 가져오기

    // 플레이어들을 출발지 좌표로 강제 이동
    for (Player p : players) {
      p.visualX = startBtn.x + startBtn.w / 1.5f;
      p.visualY = startBtn.y + startBtn.h / 1.5f;
    }
    println("플레이어 위치 초기화 완료: " + players[0].visualX + ", " + players[0].visualY);
  }
}


// [추가] 플레이어가 시각적으로 목적지에 도착했을 때 호출되는 함수
void handlePlayerArrival(int playerId) {
  // 1. 도착한 플레이어 객체 찾기
  // (배열은 0부터 시작하니까 id가 1이면 index는 0)
  Player p = players[playerId - 1];

  println("플레이어 " + playerId + " 도착 완료! 이벤트 실행.");

  // 2. 해당 위치의 이벤트(팝업) 실행하기
  // 기존에 있던 processBoardIndex 함수를 여기서 호출하는 거야
  processBoardIndex(p.position);
}


void drawDiceOverlay() {
  // 배경 지우기(background) 삭제! -> 투명하게 오버레이 됨

  // 조명 및 3D 설정
  pushMatrix();
  // 위치를 보드판 중앙 쯤으로 이동 (우측 영역의 중심)
  translate(320 + (width-320)/2, height/2 + fallY, 0);
  ambientLight(150, 150, 150);
  directionalLight(255, 255, 255, 0, 0, -1);
  lightSpecular(255, 255, 255);

  rotateX(currentAngle.x);
  rotateY(currentAngle.y);
  drawTextureCube(50); // 큐브 크기
  popMatrix();

  updateRollAndMaybeMove(); // 물리 엔진 계속 돌리기
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
          println(destinationName + " 선택함");

          // 1. 유효성 체크
          if (!countryData.containsKey(destinationName)) {
            println("알 수 없는 목적지");
            return;
          }

          // 2. 보드 인덱스 찾아서 이동
          for (String uid : uidNameMap.keySet()) {
            RfidInfo info = uidNameMap.get(uid);

            if (info.name.equals(destinationName)) {

              // [수정 핵심 1] 현재 위치에서 목표 위치까지 몇 칸 가야 하는지 계산
              int currentPos = p.position;
              int targetPos = info.boardIndex;

              // (목표 - 현재 + 24) % 24 = 앞으로 가야 할 칸 수 (시계방향)
              int steps = (targetPos - currentPos + 24) % 24;

              // 만약 제자리를 선택했다면 한 바퀴 돌리기 (선택사항)
              if (steps == 0) steps = 24;

              println("우주여행 출발! " + currentPos + " -> " + targetPos + " (" + steps + "칸 이동)");

              // [수정 핵심 2] movePlayer 함수를 써서 '스르륵' 이동시킴
              // (이 함수가 도착하면 알아서 팝업도 띄워줌)
              movePlayer(steps);

              // [수정 핵심 3] 팝업 닫기 (Turn() 호출 절대 금지!)
              spacePopup = false;
              gameState = "IDLE";

              return; // 종료
            }
          }
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
