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

  Player(int id, String name, int startMoney) {
    this.id = id;
    this.name = name;
    this.money = startMoney;
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
