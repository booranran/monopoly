void initDice() {
  // 윗면 각도 매핑
  targetAngles[0] = new PVector(-HALF_PI, 0);     // 1
  targetAngles[1] = new PVector(0, -HALF_PI);     // 2
  targetAngles[2] = new PVector(HALF_PI, 0);      // 3
  targetAngles[3] = new PVector(0, HALF_PI);      // 4
  targetAngles[4] = new PVector(0, 0);            // 5
  targetAngles[5] = new PVector(PI, 0);           // 6

  for (int i=0; i<6; i++) diceTexture[i] = loadImage("dice"+(i+1)+".png");
}

void startRoll() {
  if (rolling) return;
  rolling = true;
  rollEnded = false;      // 이징 결과 표시 잠깐 막음
  rollFrameCount = 10;
  fallY = -200;
  velocityY = 0;

  // 초기 랜덤 회전
  currentAngle.set(0, 0);
}

void updateRollAndMaybeMove() {

  //println("rolling=" + rolling + ", fallY=" + fallY + ", vel=" + velocityY + ", hold=" + resultHoldFrames);

  // 굴리는 중: 낙하/바운스 + 랜덤 회전
  if (rolling) {
    if (fallY < 0) {
      velocityY += 1.0;
      fallY += velocityY;

      if (fallY > 0) {
        fallY = 0;
        velocityY *= -0.5;
        rollFrameCount--;
      }

      currentAngle.x += velocityY * 0.03;
      currentAngle.y += velocityY * 0.03;
    } else {
      // 낙하 종료 → 결과 확정
      rolling = false;
      rollEnded = false;

      diceNumber = int(random(1, 7));      // 1~6
      println(diceNumber + "만큼 움직여요");
      targetAngle = targetAngles[diceNumber-1];
    }
  }

  // 결과 확정 후 이징 회전
  if (!rolling && !rollEnded) {
    currentAngle.x += (targetAngle.x - currentAngle.x)*easing;
    currentAngle.y += (targetAngle.y - currentAngle.y)*easing;

    if (abs(targetAngle.x - currentAngle.x) < 0.01 &&
      abs(targetAngle.y - currentAngle.y) < 0.01) {
      currentAngle.set(targetAngle);
      rollEnded = true;
      resultHoldFrames = 60;
    }
  }


  if (rollEnded && resultHoldFrames>0) {
    resultHoldFrames--;
  }

  if (rollEnded && resultHoldFrames == 0 && dicePopup) {

    println("주사위 연출 종료! " + diceNumber + "칸 이동 시작.");

    // [수정] P1일 때만 아두이노 전송 시도
    if (p.id == 1) {
      if (myClient.active()) {
        myClient.write(diceNumber); 
        println("[P1] 아두이노로 " + diceNumber + " 전송 완료!");
      } else {
        println("[오류] P1 차례지만 아두이노가 연결되지 않았습니다.");
      }
    } else {
      // P2(봇)일 때는 전송 안 함
      println("[P2] 봇은 가상으로만 이동합니다. (아두이노 전송 X)");
    }

    // 1. 주사위 팝업 닫기
    dicePopup = false;
    gameState = "IDLE";
    movePlayer(diceNumber); // 화면상의 이동은 P1, P2 모두 해야 함!

    // 3. 로직 종료 처리
    resultHoldFrames = -1;
  }
}


void drawTextureCube(float s) {

  //3: 왼쪽 0: 위
  // 앞면 (z+)
  beginShape(QUADS);
  texture(diceTexture[4]); //
  vertex(-s, -s, s, 0, 0);
  vertex( s, -s, s, 1, 0);
  vertex( s, s, s, 1, 1);
  vertex(-s, s, s, 0, 1);
  endShape();

  // 뒷면 (z-)
  beginShape(QUADS);
  texture(diceTexture[5]); // 뒤
  vertex( s, -s, -s, 0, 0);
  vertex(-s, -s, -s, 1, 0);
  vertex(-s, s, -s, 1, 1);
  vertex( s, s, -s, 0, 1);
  endShape();

  // 오른쪽 (x+)
  beginShape(QUADS);
  texture(diceTexture[1]); // 오른쪽
  vertex( s, -s, s, 0, 0);
  vertex( s, -s, -s, 1, 0);
  vertex( s, s, -s, 1, 1);
  vertex( s, s, s, 0, 1);
  endShape();

  // 왼쪽 (x-)
  beginShape(QUADS);
  texture(diceTexture[3]); // 왼쪽
  vertex(-s, -s, -s, 0, 0);
  vertex(-s, -s, s, 1, 0);
  vertex(-s, s, s, 1, 1);
  vertex(-s, s, -s, 0, 1);
  endShape();

  beginShape(QUADS);
  texture(diceTexture[0]); // 위
  vertex(-s, -s, -s, 0, 0);
  vertex( s, -s, -s, 1, 0);
  vertex( s, -s, s, 1, 1);
  vertex(-s, -s, s, 0, 1);
  endShape();

  // 아랫면 (y+)
  beginShape(QUADS);
  texture(diceTexture[2]); // 아
  vertex(-s, s, s, 0, 0);
  vertex( s, s, s, 1, 0);
  vertex( s, s, -s, 1, 1);
  vertex(-s, s, -s, 0, 1);
  endShape();
}
