# Autonomous Monopoly RC Car System (ESP32 & Processing)

본 프로젝트는 ESP32와 다중 센서를 장착한 RC카를 활용하여 물리적인 모노폴리 보드게임을 자동화한 하이브리드 게임 시스템입니다.

## 🛠 주요 기능
- **자율 주행**: 2채널 IR 센서를 이용한 라인트레이싱으로 보드판 경로 추적.
- **칸 인식 및 카운팅**: TCS34725 RGB 센서를 사용하여 타일 색상을 감지하고 이동한 칸 수를 계산.
- **이벤트 처리**: 목표 칸 도달 시 RFID 태그(MFRC522)를 읽어 해당 칸의 고유 이벤트를 처리.
- **통신 시스템**: ESP32(서버)와 Processing(클라이언트) 간의 WiFi TCP/IP 소켓 통신을 통한 실시간 데이터 교환.

## 💻 소프트웨어 구성
- **Processing**: 메인 게임 로직 제어, 주사위 생성, 사용자 UI 제공, TCP 클라이언트 역할.
- **Arduino (ESP32)**: 모터 제어, 센서 데이터 처리, TCP 서버 역할 및 상태 머신(IDLE, MOVING, WAITING_RFID 등) 관리.

## 📡 통신 프로토콜 (TCP Port 8888)
- **Processing -> ESP32**: `DICE:n` (이동 명령), `MANUAL:dir` (수동 제어)
- **ESP32 -> Processing**: `SQUARE_DETECTED` (칸 통과), `TARGET_REACHED` (도달), `RFID_SCANNED:ID` (이벤트 발생)
