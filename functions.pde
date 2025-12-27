// [functions.pde] 파일 내용 (입력 제어 부분 제거됨)

// ---------------- UI 함수들 ----------------
void showIdlePopup() {
  textSize(32); fill(0); textAlign(CENTER, CENTER);
  text("플레이어 " + p.name + "의 차례", width/2, height/2 - 40);
  text("현재 자산: " + p.money, money_X, money_Y + 20);
  text("소유 국가: " + p.ownedCountries, width/2, height/2 + 60);
  rollButton.display();
}

void showDicePopup() {
  background(0Xfafafa);
  pushStyle();
  pushMatrix();
  translate(width/2, height/2 + fallY, 0);
  ambientLight(150, 150, 150);
  directionalLight(255, 255, 255, 0, 0, -1);
  rotateX(currentAngle.x);
  rotateY(currentAngle.y);
  drawTextureCube(50);
  popMatrix();

  if (rollEnded) {
    fill(0); textAlign(CENTER, CENTER); textSize(18);
    text("결과: " + diceNumber, width/2, height/2 + 140);
  }
  popStyle();
}

void showBuyLandPopup(String countryName) {
  if (selectedCountry == null) return;
  fill(0);
  text("현재자산: " + p.money, money_X2, money_Y2);
  text(selectedCountry.name + "을(를) 구매 하시겠습니까?", width/2, height/2);
  
  if (p.money < selectedCountry.price) {
    yesButton.enabled = false;
    text("돈이 부족합니다.", width/2, height/2 + 50);
  } else {
    yesButton.enabled = true;
  }
  yesButton.display();
  noButton.display();
}

void showBuyBuildingPopup() {
  textSize(32);
  text("건물을 지을까요?", width/2, height/2-50);
  text("현재자산: " + p.money, money_X, money_Y);
  yesButton.display();
  noButton.display();
}

void showChooseBuildingPopup() {
  textSize(32);
  text("건물을 골라주세요", width/2, height/2-50);
  text("현재자산: " + displayMoney(), money_X, money_Y);
  
  if (displayMoney() < 0) {
    buyButton.enabled = false;
    text("잔액 부족", width/2, height/2 + 50);
  } else {
    buyButton.enabled = true;
  }
  villa.display(); building.display(); hotel.display(); buyButton.display();
}

void showTollPopup() {
  text("현재자산: " + p.money, money_X, money_Y);
  text(selectedCountry.name + "에 도착! (주인: P" + selectedCountry.ownerId + ")", width/2, height/2 - 50);
  text("통행료: " + selectedCountry.currentRent(), width/2, height/2 + 30);
  if (p.money < selectedCountry.currentRent()) {
     text("파산 위기!", width/2, height/2 + 80);
  }
  confirmButton.display();
}

void showcheckGameEnd() {
  int bankruptCount = 0;
  Player winner = null;
  for (Player pl : players) {
    if (pl.isBankrupt) bankruptCount++;
    else winner = pl;
  }
  if (bankruptCount == players.length - 1) {
    gameState = "THE_END";
    gameEndPopup = true;
    text("게임 종료! 승자: " + winner.name, width/2, height/2);
  }
}

void showSalaryPopup() {
  text("월급날! (+20000)", width/2, height/2);
  confirmButton.display();
}

void showIslandPopup() {
  text("무인도에 갇힘!", width/2, height/2);
  text(currentMessage, width/2, height/2 + 30);
  confirmButton.display();
}

void showEventPopup() {
  text("이벤트 발생", width/2, height/2);
  text(currentMessage, width/2, height/2 + 50);
  textSize(20);
  text(detail_currentMessage, width/2, height/2 + 80);
  confirmButton.display();
}

void showSpacePopup() {
  text("우주 여행! 목적지를 선택하세요", width/2, height/2);
  for (Button b : cityButtons) b.display();
}


// ---------------- 계산 및 로직 함수들 ----------------

int selectionCost() {
  return (villa.get() * selectedCountry.villaCost) + 
         (building.get() * selectedCountry.buildingCost) + 
         (hotel.get() * selectedCountry.hotelCost);
}

int displayMoney() { return p.money - selectionCost(); }

int selectionTotal() { return villa.get() + building.get() + hotel.get(); }

Player getCurrentPlayer() { return players[currentPlayer]; }

// 턴 관리
void Turn() {
  if (p.isIslanded) {
    p.islandTurns++;
    println("무인도 남은 턴: " + (3 - p.islandTurns));
    if (p.islandTurns >= 3) {
      p.isIslanded = false;
      p.islandTurns = 0;
    } else {
      nextTurn();
      return;
    }
  }
  
  int dice = int(random(1, 7));
  println(p.name + " 주사위: " + dice);
  movePlayer(dice);
  nextTurn();
}

Player nextTurn() {
  int nextIndex = (currentPlayer + 1) % players.length;
  // 다음 사람도 무인도면 건너뛰기 로직
  while (players[nextIndex].isIslanded) {
      players[nextIndex].islandTurns++;
      if (players[nextIndex].islandTurns >= 3) {
          players[nextIndex].isIslanded = false;
          players[nextIndex].islandTurns = 0;
      } else {
          nextIndex = (nextIndex + 1) % players.length; // 또 다음 사람
      }
  }
  currentPlayer = nextIndex;
  p = players[currentPlayer];
  return p;
}

// ★ 시각화 적용된 이동 함수 ★
void movePlayer(int steps) {
  Player cp = players[currentPlayer];
  int startPos = cp.position;
  int finalPos = (startPos + steps) % BOARD_SIZE;

  if (startPos + steps >= BOARD_SIZE) {
    cp.money += 20000;
    println("월급 지급!");
  }

  cp.position = finalPos; // 논리적 위치 먼저 갱신

  // 경로 큐 채우기 (내비게이션)
  for (int i = 1; i <= steps; i++) {
    int nextIdx = (startPos + i) % BOARD_SIZE;
    Button target = cityButtons[nextIdx];
    // 2.0f 수정 완료됨
    float destX = target.x + target.w / 2.0f;
    float destY = target.y + target.h / 2.0f;
    cp.pathQueue.add(new PVector(destX, destY));
  }
}

void initializePlayerPositions() {
  if (cityButtons.length > 0) {
    Button startBtn = cityButtons[0];
    float startX = startBtn.x + startBtn.w / 2.0f;
    float startY = startBtn.y + startBtn.h / 2.0f;
    for (Player p : players) {
      p.visualX = startX;
      p.visualY = startY;
    }
  }
}

// 도착 콜백 (Player 클래스에서 호출)
void handlePlayerArrival(int playerId) {
  Player p = players[playerId - 1];
  // 도착한 위치의 태그 UID를 찾아서 이벤트 실행
  for (String uid : uidNameMap.keySet()) {
      if (uidNameMap.get(uid).boardIndex == p.position) {
          processTagEvent(uid);
          return;
      }
  }
}

void selectRandomEvent() {
  int idx = (int)random(events.length);
  RandomEvent evt = events[idx];
  p.money += evt.moneyChange;
  currentMessage = evt.description;
  detail_currentMessage = evt.detail_desc;
  
  if (idx == 7) { // 무인도 이벤트 인덱스 확인 필요
     p.isIslanded = true;
     p.islandTurns = 0;
  }
}

// 보드 인덱스로 이벤트 트리거
void processBoardIndex(int index) {
  for (String uid : uidNameMap.keySet()) {
    if (uidNameMap.get(uid).boardIndex == index) {
      processTagEvent(uid);
      break;
    }
  }
}
