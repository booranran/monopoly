//-----------ui 함수----------------

void showIdlePopup() {

  textSize(32);
  fill(0);
  textAlign(CENTER, CENTER);

  text("플레이어 " + p.name + "의 차례", width/2, height/2 - 40);
  text("현재 자산: " + p.money, money_X, money_Y + 20);
  text("소유 국가: " + p.ownedCountries, width/2, height/2 + 60);
  rollButton.display();
}

void showDicePopup() {
  // 올바른 코드
  background(0Xfafafa);
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
    text("결과: " + diceNumber, width/2, height/2 + 140);
  }
  popStyle();
}

void showBuyLandPopup(String country) {
  fill(0);

  if (selectedCountry != null) {
    fill(0);
    text("현재자산: " + p.money, money_X2, money_Y2);
    text(selectedCountry.name + "을(를) 구매 하시겠습니까?", width/2, height/2);
    if (p.money < selectedCountry.price) {
      // 돈이 부족하면 yes 버튼 비활성화
      yesButton.enabled = false;
      text("돈이 부족해서 구매할 수 없습니다.", width/2, height/2 + 50);
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

  textSize(32);
  text("건물을 지을까요?", width/2, height/2-50);
  text("현재자산: " + p.money, money_X, money_Y);
  yesButton.display();
  noButton.display();

  buyLandPopup = false;
  chooseBuildingPopup = false;
  gameState = "BUY_BUILDING";
}

void showChooseBuildingPopup() {
  textSize(32);
  text("건물을 골라주세요", width/2, height/2-50);
  text("현재자산: " + displayMoney(), money_X, money_Y);

  if (displayMoney()<0) {
    // 돈이 부족하면 yes 버튼 비활성화
    buyButton.enabled = false;
    text("돈이 부족해서 구매할 수 없습니다.", width/2, height/2 + 50);
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
  //text("test", width/2, height/2);
}

void showTollPopup() {
  // 팝업에 표시될 텍스트
  text("현재자산: " + p.money, money_X, money_Y);
  text(selectedCountry.name + "에 도착했습니다!", width/2, height/2 - 50);
  text(selectedCountry.ownerId + "P의 땅입니다.", width/2, height/2 - 20);
  text("통행료 " + selectedCountry.currentRent() + "원을 지불해야 합니다.", width/2, height/2 + 30);

  if (p.money<selectedCountry.currentRent()) {
    text("지불 할 돈이 없습니다!", width/2, height/2 + 80);
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
    text("게임 종료! 승자는 " + winner.name + "입니다!", width/2, height/2);
  }
}

void showSalaryPopup() {
  text("와! 월급날이다!", width/2, height/2);
  confirmButton.display();
}

void showIslandPopup() {
  text("무인도에 갇혔다!!", width/2, height/2);
  text(currentMessage, width/2, height/2 + 30);
  confirmButton.display();
}

void showEventPopup() {
  text("랜덤 이벤트 발생!", width/2, height/2);
  text(currentMessage, width/2, height/2 + 50);
  pushStyle();
  textSize(20);
  text(detail_currentMessage, width/2, height/2 + 80);
  popStyle();
  confirmButton.display();
}

void showSpacePopup() {
  text("우주 여행을 떠나자!", width/2, height/2);
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
  //무인도 상태 확인
  if (p.isIslanded) {
    p.islandTurns++;
    println(p.name + "는 무인도에 갇혔다. (남은 턴: " + (3 - p.islandTurns) + ")");

    if (p.islandTurns >= 3) {
      p.isIslanded = false;
      p.islandTurns = 0;
      println(p.name + "가 무인도에서 탈출했습니다!");
    } else {
      nextTurn();  // 아직 탈출 못했으면 다음 플레이어로
      return;
    }
  }

  //주사위 굴림
  int dice = int(random(1, 7));
  println(p.name + "이(가) 주사위를 굴렸습니다: " + dice);

  // 🚶 이동 + 월급칸 체크 + 도착 이벤트 실행
  movePlayer(dice);
  nextTurn();
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
  int oldPos = p.position;
  int newPos = (oldPos + steps) % BOARD_SIZE;

  // ✅ 0번(월급칸)을 지나쳤는지 체크
  if (oldPos + steps >= BOARD_SIZE) {
    p.money += 20000;
    println(p.name + "이(가) 월급칸을 지나 월급을 받았습니다! 현재 돈: " + p.money);
  }

  // 위치 갱신
  p.position = newPos;

  // ✅ 도착한 칸 처리
  processBoardIndex(newPos);
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

    // 마우스프레스 함수
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
