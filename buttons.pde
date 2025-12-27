class Button {
  int x, y, w, h;
  String label;
  int idx;
  boolean centerMode;
  boolean enabled = true;

  Button(int x, int y, int w, int h, String label, int idx) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.idx = idx;
  }

  Button(int x, int y, int w, int h, String label, int idx, boolean centerMode) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.idx = idx;
    this.centerMode = centerMode;
  }


  void display() {
    pushStyle(); //textAlign 상태 일시 저장
    noStroke();
    rectMode(centerMode ? CENTER : CORNER);

    if(enabled){
      fill(isMouseOver() ? 200 : #D9D9D9);
    } else{
      fill(150);
    }
     
    rect(x, y, w, h, 14);

    fill(0);
    textSize(16);
    textAlign(CENTER, CENTER);
    text(label, centerMode ? x : x + w/2, centerMode ? y : y + h/2);
    popStyle(); //setup 내용으로 다시 되돌리기
  }

  boolean isMouseOver() {
    // 버튼이 활성화된 상태일 때만 true 반환
    if (enabled) {
      if (centerMode) {
        return mouseX > x - w/2 && mouseX < x + w/2 && mouseY > y - h/2 && mouseY < y + h/2;
      } else {
        return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
      }
    }
    return false; // 비활성화 상태에서는 항상 false 반환
  }
}

// ===== Quantity: ▲ [값 박스] ▼ 를 모두 포함한 스테퍼 =====
class Quantity {
  int cx, cy;       // 중심 좌표
  int boxW=60, boxH=40;     // 값 박스 크기
  int triW=40, triH=20;     // 삼각형(버튼) 크기
  int gap=10;               // 박스와 삼각형 사이 간격

  int value=0, minVal=0, maxVal=10;


  String label = "";        // (선택) 라벨 표시용

  Quantity(int cx, int cy, int minVal, int maxVal, int initial, String label) {
    this.cx=cx;
    this.cy=cy;
    this.minVal=minVal;
    this.maxVal=maxVal;
    this.value=constrain(initial, minVal, maxVal);
    this.label=label;
  }

  void display() {
    pushStyle();
    // ▲ 버튼
    fill(isOverUp() ? 200 : color(0xD9, 0xD9, 0xD9));
    noStroke();
    triangle(cx - triW/2, cy - boxH/2 - gap,
      cx + triW/2, cy - boxH/2 - gap,
      cx, cy - boxH/2 - gap - triH);

    // ▼ 버튼
    fill(isOverDown() ? 200 : color(0xD9, 0xD9, 0xD9));
    triangle(cx - triW/2, cy + boxH/2 + gap,
      cx + triW/2, cy + boxH/2 + gap,
      cx, cy + boxH/2 + gap + triH);

    // 값 박스
    rectMode(CENTER);
    fill(235);
    rect(cx, cy, boxW, boxH, 6);

    // 값 텍스트
    fill(20);
    textAlign(CENTER, CENTER);
    textSize(18);
    text(value, cx, cy);

    // (선택) 라벨
    if (label != null && label.length() > 0) {
      fill(0);
      textSize(14);
      text(label, cx, cy - boxH/2 - gap - triH - 12);
    }
    popStyle();
  }

  // 클릭 처리(마우스 눌림 때 호출)
  boolean handleClick(int currentTotal) {
    if (isOverUp()) {
      if (currentTotal < 3 && value < maxVal) {
        value++;
        return true;
      }
    }
    if (isOverDown()) {
      if (value > minVal) {
        value--;
        return true;
      }
    }
    return false;
  }

  void inc() {
    if (value < maxVal) value++;
  }
  void dec() {
    if (value > minVal) value--;
  }

  int  get() {
    return value;
  }
  void set(int v) {
    value = constrain(v, minVal, maxVal);
  }


  boolean isOverUp() {

    int top = cy - boxH/2 - gap - triH;
    int bottom = cy - boxH/2 - gap;
    return mouseX >= cx - triW/2 && mouseX <= cx + triW/2 &&
      mouseY >= top        && mouseY <= bottom;
  }

  boolean isOverDown() {
    int top = cy + boxH/2 + gap;
    int bottom = cy + boxH/2 + gap + triH;
    return mouseX >= cx - triW/2 && mouseX <= cx + triW/2 &&
      mouseY >= top        && mouseY <= bottom;
  }
}
