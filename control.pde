boolean inPopup() {
  return buyLandPopup || buyBuildingPopup || chooseBuildingPopup;
}

// 모든 태그 정보를 하나의 uidNameMap에 저장했다고 가정
void processTagEvent(String uid) {
  // UID로 태그 정보 가져오기
  RfidInfo tagInfo = uidNameMap.get(uid);

  // 태그 정보가 있을 경우에만 로직 실행
  if (tagInfo != null) {
    // 1. 태그의 이름(name)을 확인하여 이벤트인지 국가인지 구분
    if (tagInfo.name.equals("SALARY")) {
      salaryPopup = true;
      gameState = "SALARY";
    } else if (tagInfo.name.equals("ISLAND")) {
      islandPopup = true;
      gameState = "ISLAND";
      p.isIslanded = true;
      p.islandTurns = 0;
      currentMessage = p.name + "가 무인도에 갇혔습니다!";
    } else if (tagInfo.name.equals("EVENT")) {
      selectRandomEvent();
      eventPopup = true;
      gameState = "EVENT";
    } else if (tagInfo.name.equals("SPACE")) {
      spacePopup = true;
      gameState = "SPACE";
    } 
    
    // 2. 이벤트 태그가 아니면 국가 태그로 간주
    else {
      // tagInfo.name을 키로 사용해 Country 객체 가져오기
      selectedCountry = countryData.get(tagInfo.name);
      
      // 땅의 소유 상태에 따라 로직 분기
      // 1. 자신의 땅에 도착했을 때
      if (selectedCountry.ownerId == p.id) {
        buyBuildingPopup = true;
        gameState = "BUY_BUILDING";
        currentMessage = "자신의 땅에 도착했습니다. 건물을 지을 수 있습니다.";
      } 
      // 2. 주인이 없는 땅에 도착했을 때
      else if (selectedCountry.ownerId == -1) {
        buyLandPopup = true;
        gameState = "BUY_LAND";
        currentMessage = selectedCountry.name + "에 도착했습니다. 땅을 구매하시겠습니까?";
      } 
      // 3. 다른 플레이어의 땅에 도착했을 때
      else {
        payTollPopup = true;
        gameState = "PAY_TOLL";
        currentMessage = selectedCountry.name + "는 " + selectedCountry.ownerId + "P의 땅입니다. 통행료를 내야 합니다.";
      }
    }
    
    println(gameState + " 상태로 전환");
    return; // 이벤트 처리 후 함수 종료

  } else {
    println("알 수 없는 태그");
  }
}
