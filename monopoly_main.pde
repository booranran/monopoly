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
}

void draw() {
  // 매 프레임마다 배경을 한 번만 지워줍니다.
  background(#fafafa);  
  //// 팝업이 띄워져 있는지 확인
  boolean isAnyPopupActive = false;
 

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
