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

class Player {
  int id;
  int money;
  String name;
  boolean isBankrupt;
  boolean isIslanded;
  int islandTurns;
  int position;
  ArrayList<String> ownedCountries = new ArrayList<String>();

  // 시각화 변수
  float visualX, visualY;
  ArrayList<PVector> pathQueue; // ★ 변수 선언
  boolean isMoving = false;
  float moveSpeed = 0.1;

  // 생성자
  Player(int id, String name, int startMoney) {
    this.id = id;
    this.name = name;
    this.money = startMoney;
    
    // ★★★ [중요] 이 줄이 없으면 무조건 널포인트 에러 남! ★★★
    this.pathQueue = new ArrayList<PVector>(); 
    
    // 위치 초기화 (일단 0으로)
    this.visualX = 0;
    this.visualY = 0;
  }

  // 이동 및 그리기 함수
  void updateAndDraw() {
    if (pathQueue.size() > 0) {
      isMoving = true;
      PVector target = pathQueue.get(0);
      visualX = lerp(visualX, target.x, moveSpeed);
      visualY = lerp(visualY, target.y, moveSpeed);
      
      if (dist(visualX, visualY, target.x, target.y) < 2.0) {
        visualX = target.x;
        visualY = target.y;
        pathQueue.remove(0);
      }
    } else {
      if (isMoving) {
        isMoving = false;
        handlePlayerArrival(this.id); // 도착 완료 처리
      }
    }

    // 경로 그리기 (빨간 점선)
    if (pathQueue.size() > 0) {
      stroke(255, 100, 100); strokeWeight(3); noFill();
      beginShape();
      vertex(visualX, visualY);
      for (PVector p : pathQueue) vertex(p.x, p.y);
      endShape();
    }
    
    drawAvatar(); // 내 자동차 그리기
  }

  void drawAvatar() {
    rectMode(CENTER); noStroke();
    if (id == 1) fill(50, 50, 255); else fill(255, 50, 50);
    rect(visualX, visualY, 30, 20, 5);
    fill(0); textAlign(CENTER); textSize(12);
    text("P" + id, visualX, visualY);
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
