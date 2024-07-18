# 노마드월렛 NomadWallet
![nomadwallet](https://github.com/unboxing96/NomadWallet/assets/102353544/75f4b3c2-b648-44f6-84c0-5e6466a8a2c7)

### 🎉 앱스토어 출시 완료
https://apps.apple.com/ca/app/id6470182505

</br>

### 📈 앱스토어 관련 데이터 (2024.06.09 update)
- 다운로드 횟수: 489회
- 다운로드 전환율: 17.2%
- 리뷰 수: 13개
- 별점 평균: 4.9

</br>

### ✈️ 음성으로 기록하는 해외여행 가계부
노마드월렛은 해외 배낭여행자를 위한 가계부 iOS 앱입니다. </br>
여행 중 소비가 발생하자마자 까먹기 전에 음성 메모를 남기듯 `무엇을`, `얼마에`, `어떻게` 결제했는지만 말하면 알아서 가계부에 정리해줍니다.
음성 인식으로 `기록`된 지출 내역의 카테고리를 AI로 `분류`하고, 여러 국가와 도시를 옮겨다녀도 GPS로 위치를 파악해 원화로 `계산`해줍니다.
노마드월렛과 함께라면 소비 기록의 부담을 내려놓고 여행의 소중한 순간을 만끽할 수 있습니다.

</br>

### 📆 개발 기간
2023.09.04 ~ 2023.12.18

</br>

### 👥 팀원
<img src="https://github.com/unboxing96/NomadWallet/assets/102353544/664788de-b3ad-4778-b7af-19f7c77993ca" width="800">

</br>
</br>
</br>

## 1. Development Environment ⚙️
`iOS 16.0` `Xcode 15.0`

</br>

## 2. Tech Stack ⚒️
- 언어: `Swift`
- 프레임워크: `SwiftUI`
- 아키텍처: `MVVM`
- 동시성: `GCD`, `async / await`
- 데이터베이스: `Core Data`
- 음성 인식: `Speech`
- 카테고리 분류: `CreateML`
- 위치: `Core Location`
- 환율: `Exchange API`
- 코드 품질 관리 도구: `SwiftLint`

</br>

## 3. 화면 구성
|Travel|Record|Expense|
|---|---|---|
|![travel_2x](https://github.com/unboxing96/NomadWallet2/assets/102353544/e99cdb4e-6397-46c8-b6da-09770544112e)|![record_2x](https://github.com/unboxing96/NomadWallet2/assets/102353544/33d49e0f-62ec-4fba-b2eb-7d09fc9b19b6)|![expense_2x](https://github.com/unboxing96/NomadWallet2/assets/102353544/549ac06d-eed5-4acf-9869-a4df74559687)|

</br>

## 4. 기능 요약
- `Travel`
  - 여행 일정 생성 / 삭제
  - 커스텀 캘린더로 일정 선택
  - 지난 여행 / 다가오는 여행 조회
  - 임시 지출 기록을 특정 여행에 할당 가능
 
- `Record`
  - 음성 인식으로 입력된 문자열 처리
    - 처리된 정보를 바탕, ML 활용하여 카테고리 분류
    - 처리된 정보를 바탕, 시각 / 위치 / 환율 / 음성파일 자동 저장
  - 정보 수기 입력 가능
  - 입력된 정보 수정 가능
 
- `Expense`
  - 기록된 정보를 그래프로 표현
  - 여행 / 국가 / 결제수단 별로 정보 필터링
  - 저장된 소비 기록 조회 / 수정 / 삭제
  - 저장된 소비 기록 .CSV 파일로 내보내기
    - 결제 인원 별로 자동 정산 기능

</br>

## 5. 업데이트 내역
`1.0.0` 출시 </br>
`1.1.0` 실시간 환율 정보 반영, 소비 기록 삭제 기능 추가 </br>
`1.1.1` 버그 수정 </br>
`1.1.2` 버그 수정 </br>
`1.2.0` CSV 내보내기 기능 추가 </br>
`1.2.1` API KEY 업데이트 </br>

</br>

## 6. Folder Structure

```
├── UMM
│   ├── DesignSystem
│   │   └── Fonts
│   ├── Extension
│   ├── Handler
│   ├── Model
│   │   └── Enumeration
│   ├── Protocol
│   ├── Utils
│   ├── View
│   │   ├── Expense
│   │   ├── Modal
│   │   ├── Other
│   │   ├── Record
│   │   └── Travel
│   └── ViewModel
└── UMM.xcworkspace
     └── xcshareddata
```

</br>
</br>

# 팀 개발자들을 위한 Git, Code Convention

## 네이밍
- 이슈</br>
  `이슈 핵심 내용`</br>
  `구글 로그인 구현`</br>

- 브랜치</br>
  `브랜치 종류/이슈 번호-개발할 기능 이름`</br>
  `feat/1-login-view`</br>
  
- 커밋</br>
  `(종류 이모지)[이슈 번호] 이슈 핵심 내용`</br>
  `:bug:[#11][#12] 구글 로그인 탈퇴시 발생하는 버그 해결`</br>
  
- PR</br>
  `(종류 이모지)[이슈 번호] 커밋 내용`</br>
  `:zap:[#1] 로그인 화면 개발`</br>

## 브랜치, 커밋 종류
|           종류              | 이모지                                          |       설명               |
|:---------------------------|:----------------------------------------------|:------------------------|
| initial                    | :tada: `:tada:`                               | 초기 설정                 |
| refactor                   | :recycle: `:recycle:`                         | 파일·타입 이름 변경, 파일 분리 |
| bug                        | :bug: `:bug:`                                 | 버그                     |
| feat                       | :zap: `:zap:`                                 | 기능                     |
| gui                        | :art: `:art:`                                 | View                    |
| chore                      | :broom: `:broom:`                             | SPM, 세팅, 빌드 등         |
| delete                     | :wastebasket: `:wastebasket:`                 | 파일 삭제                 |
| docs                       | :books: `:books:`                             | 코드 외 문서               |
| asset                      | :heart: `:heart:`                             | 에셋                     |
| comment                    | :memo: `:memo:`                               | 주석                     |

## 내용
- 이슈, PR은 템플릿을 따릅니다
- 커밋
  한 줄로 간결하게 작성하고 작성해야 하는 내용이 길어지면 한 줄 개행 후 상세 내용을 작성합니다
  ```markdown
  :bug:[#11] 버튼이 동작하지 않는 버그 해결
  
  - 화면을 나갔다가 다시 들어오면 버튼이 비활성화되었음
  - 어쩌구저쩌구 원인으로 인해 발생
  - 어떻게 해서 저렇게 하는 방법으로 해결
  ```

## 생성

한 이슈당 브랜치 하나 1:1

  1. Create a branch를 눌러 origin(기본 브랜치)에서 먼저 생성
  2. 또는 local에서 먼저 생성해서 작업 후 push origin 후에 톱니바퀴⚙️를 눌러 이슈와 연결
      

## 삭제

- Git flow에 해당하지 않는 브랜치는 머지 후 삭제합니다
- [Exeption] 해당하는 이슈 내 태스크가 완료되지 않았지만 기타 사유로 일단 머지하는 경우

## 작업 순서
### push: 보낼 때
{working directory}</br>
-> git add -> {staging area} </br>
-> git commit -> {local repository == 나의 mac}</br>
-> git pull 후 충돌 발생하면 로컬에서 해결</br>
-> git push -> {remote repository == github}</br>

### 깃헙 페이지에서의 Pull Request
1. PR 생성 버튼 누르기
2. PR 컨벤션에 따라 작성하기
3. 코드 리뷰와 승인 받기
4. (승인 받지 못한 경우에 코드 수정하기)
5. 병합하기
6. 리모트 브랜치 삭제하기

### pull: 받을 때
{remote repository}</br>
-> git pull -> {local repository}</br>
-> git branch -d {prev}</br>
-> git branch {new} -> git checkout {new} -> {working directory}</br>

## Code Review 코드 리뷰

### 방식에 대하여
- 본인 외 2인의 승인 필요(사실상 테크 전원)
- PR을 올린 다음날 아침 10시까지, 주말 포함

### 코드 컨벤션
- 주석은 복잡한 기능 등을 한줄요약하는 정도로만 사용합니다. 레거시 주석이 되지 않게 일반적인 내용을 적습니다.
- 린트 사용

### 코드리뷰 약어
- **IMO** in my opinion
- **LGTM** look good to me
- **FYI** for your information
- **ASAP** as soon as possible
- **TL;DR** Too Long. Didn't Read *보통 문장 앞 부분에 긴 글을 요약할 때*
- **P1 ~ P3** 우선순위. 1이 높은 것.
