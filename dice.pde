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

    Player p = players[currentPlayer];
    p.position = (p.position + diceNumber) % BOARD_SIZE;
    println(p.name + " → " + diceNumber + "칸 이동, pos=" + p.position);

    // 도착칸 이벤트 실행 및 팝업 상태 변경
    processBoardIndex(p.position);

    // 이 로직이 다시 실행되는 것을 막기 위해 값을 변경
    resultHoldFrames = -1; // 또는 rollEnded = false;
    dicePopup = false;
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
