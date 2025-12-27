class RfidInfo{
  String name;
  int boardIndex;
  RfidInfo(String name, int boardIndex){
    this.name = name;
    this.boardIndex = boardIndex;
  }
}

class Country {
  //기본 정보
  String name;
  int price;
  boolean purchased;
  int ownerId = -1;
  
  //통행료 관련
  int land_fee; //통행료
  int villa_fee; //별장료
  int building_fee; //빌딩료
  int hotel_fee; //호텔료

  //건설 관련
  int villaCost;
  int buildingCost;
  int hotelCost;

  //카운팅
  int villaCount;
  int buildingCount;
  int hotelCount;
  

  Country(String n, int p, int lf, int vf, int bf, int hf, int vc, int hc, int bc) {
    this.name = n;
    this.price = p;
    this.land_fee = lf;
    this.villa_fee = vf;
    this.building_fee=bf;
    this.hotel_fee = hf;
    this.villaCost = vc;
    this.hotelCost = hc;
    this.buildingCost = bc;
  }

  int currentRent() {
    return land_fee + (villaCount * villa_fee) + (buildingCount * buildingCost) + (hotelCount * hotelCost);
  }
}

// class.pde 파일의 Player 클래스를 이렇게 수정해봐.

class Player {
  int id;
  int money;
  String name;
  boolean isBankrupt;
  boolean isIslanded;
  int islandTurns;
  int position; // 논리적인 현재 위치 (게임 룰 계산용)
  ArrayList<String> ownedCountries = new ArrayList<String>();

  // --- [추가된 시각화 변수들] ---
  float visualX, visualY;       // 화면에 실제 그려지는 좌표
  ArrayList<PVector> pathQueue; // 앞으로 들러야 할 경유지(웨이포인트) 목록
  boolean isMoving = false;     // 지금 움직이는 중인가요?
  // ★ 속도 조절 변수: 이 숫자를 작게 할수록 현실 차처럼 느리게 감 (0.01 ~ 0.1 사이 추천)
  float moveSpeed = 0.05; 

  Player(int id, String name, int startMoney) {
    this.id = id;
    this.name = name;
    this.money = startMoney;
    this.position = 0; // 시작 위치
    this.pathQueue = new ArrayList<PVector>();
    // visualX, visualY 초기화는 setup()에서 버튼이 생성된 후에 해야 함!
  }

  // 매 프레임마다 호출될 함수: 위치 업데이트 + 그리기
  void updateAndDraw() {
    // 1. 움직임 로직 (내비게이션 따라가기)
    if (pathQueue.size() > 0) {
      isMoving = true;
      PVector target = pathQueue.get(0); // 다음 목표 지점
      
      // lerp 함수로 부드럽게 이동 (현재위치 -> 목표위치, 속도)
      visualX = lerp(visualX, target.x, moveSpeed);
      visualY = lerp(visualY, target.y, moveSpeed);
      
      // 목표 지점에 거의 도착했으면(거리가 5픽셀 미만이면) 도착 처리
      if (dist(visualX, visualY, target.x, target.y) < 5.0) {
        visualX = target.x; // 위치 딱 맞추기
        visualY = target.y;
        pathQueue.remove(0); // 도착했으니 목록에서 삭제
      }
    } else {
      // 큐가 비었다 = 최종 목적지 도착!
      if (isMoving) {
        isMoving = false;
        println("플레이어 " + id + " 도착 완료! 이벤트 실행.");
        // ★ 여기가 핵심! 시각적 이동이 다 끝난 후에야 팝업을 띄움
        // monopoly_main.pde에 있는 도착 처리 함수 호출
        handlePlayerArrival(this.id); 
      }
    }

    // 2. 내비게이션 경로 그리기 (빨간 점선)
    if (pathQueue.size() > 0) {
      stroke(255, 50, 50, 150); // 약간 투명한 빨간색
      strokeWeight(4);
      noFill();
      beginShape();
      vertex(visualX, visualY); // 내 현재 위치에서 시작해서
      for (PVector p : pathQueue) {
        vertex(p.x, p.y); // 남은 경유지들을 잇는다
      }
      endShape();
    }

    // 3. 플레이어 아바타(미니카) 그리기
    drawAvatar();
  }
  
  void drawAvatar() {
    noStroke();
    // 플레이어별 색상 다르게
    if (id == 1) fill(50, 50, 255); // 파랑
    else fill(255, 50, 50);       // 빨강
    
    // 심플한 자동차 모양 (나중에 이미지로 교체 가능)
    rectMode(CENTER);
    rect(visualX, visualY, 40, 20, 5); // 차체
    fill(0);
    rect(visualX-15, visualY-12, 10, 6); // 바퀴
    rect(visualX+15, visualY-12, 10, 6);
    rect(visualX-15, visualY+12, 10, 6);
    rect(visualX+15, visualY+12, 10, 6);
    
    // 이름 표시
    fill(0);
    textAlign(CENTER);
    textSize(14);
    text("P" + id, visualX, visualY - 15);
  }
}

class RandomEvent {
  String description;
  int moneyChange;
  String detail_desc;
  
  RandomEvent(String desc, int change, String detail_desc){
    description = desc;
    moneyChange = change;
    this.detail_desc = detail_desc;
  }
}

RandomEvent[] events = {
  new RandomEvent("국세청에서 세금을 환급받았다!", 10000, "은행에서 1000원을 받습니다"),
  new RandomEvent("장학금을 받았다!", 10000, "은행에서 1000원을 받습니다"),
  new RandomEvent("최보란이 개최한 공모전에서 당선되었다!", 10000, "은행에서 1000원을 받습니다"),
  new RandomEvent("특별 세금을 징수당했다!", -15000, "자산에서 15000원이 나갔습니다"),
  new RandomEvent("교통사고를 당했다!", -15000, "자산에서 150000원이 나갔습니다"),
  new RandomEvent("과속 벌금 딱지를 끊겼다", -3000, "자산에서 3000원이 나갔습니다"),
  new RandomEvent("축복을 받았습니다.", 0, "아무 효과도 없지만 행운을 빌어줍니다."), //-- index[6]
  new RandomEvent("당신이 탄 배가 난파당했습니다.", 0, "무인도로 이동!")
};
