# Fastlane 사용 가이드 — WorkOut Log

**문서 버전:** 1.0.0
**작성일:** 2025년 10월 19일
**작성자:** Ben (오정석) with Claude
**대상:** iOS 개발자, CI/CD 운영자, 미래의 나

---

## 📚 목차

1. [Fastlane 개요](#fastlane-개요)
2. [환경 준비](#환경-준비)
3. [로컬 사용법](#로컬-사용법)
4. [Lane 상세 설명](#lane-상세-설명)
5. [버전 관리 플로우](#버전-관리-플로우)
6. [CI 워크플로우](#ci-워크플로우)
7. [Troubleshooting](#troubleshooting)
8. [보안 주의사항](#보안-주의사항)
9. [부록: Fastfile 주요 옵션](#부록-fastfile-주요-옵션)

---

## Fastlane 개요

### 왜 Fastlane을 사용하는가?

**반복 작업 자동화**
- 수동으로 Xcode에서 Archive → Export → Upload를 반복하는 대신, 한 줄 명령으로 완료
- 빌드 번호 증가, 테스트 실행, 아카이브 생성, TestFlight 업로드를 단일 워크플로우로 통합

**일관성 보장**
- 팀원 간 동일한 빌드/배포 절차 보장
- 로컬 개발 환경과 CI 환경에서 동일한 스크립트 사용

**CI/CD 연계**
- GitHub Actions와 완벽하게 통합
- 태그 푸시만으로 자동 TestFlight 배포

---

## 환경 준비

### 1. Ruby & Bundler 설치 확인

```bash
# Ruby 버전 확인 (3.3.0 권장)
ruby --version

# Bundler 설치
gem install bundler
```

### 2. Fastlane 설치

```bash
# 프로젝트 루트 디렉토리로 이동
cd "/Users/ojung/Documents/Dev/WorkOut Log"

# 의존성 설치 (Gemfile 기준)
bundle install
```

**설치 확인:**
```bash
bundle exec fastlane --version
# 출력 예: fastlane 2.219.0
```

### 3. Xcode 16 선택

```bash
# Xcode.app 경로 확인
xcode-select -p

# Xcode 16으로 전환 (필요 시)
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# 또는 Xcode 16.0.app이 별도로 있다면
sudo xcode-select -s /Applications/Xcode_16.0.app/Contents/Developer
```

### 4. App Store Connect API Key 설정

#### 4.1 API Key 생성 (최초 1회)

1. [App Store Connect → Users and Access → Keys](https://appstoreconnect.apple.com/access/api) 접속
2. **"Generate API Key"** 클릭
3. 이름: `GitHub Actions CI` (또는 원하는 이름)
4. 역할: **App Manager** 선택
5. **Generate** 클릭
6. `.p8` 파일 다운로드 (예: `AuthKey_AB12CD34EF.p8`)
7. **Key ID**와 **Issuer ID** 복사 (나중에 필요)

⚠️ **주의:** `.p8` 파일은 한 번만 다운로드 가능. 안전한 곳에 백업하세요.

#### 4.2 macOS 로컬 환경변수 설정

**방법 1: 터미널 세션에서 임시 설정**
```bash
# Key ID (예: AB12CD34EF)
export ASC_KEY_ID="YOUR_KEY_ID"

# Issuer ID (UUID 형식)
export ASC_ISSUER_ID="YOUR_ISSUER_ID"

# .p8 파일을 Base64로 인코딩
export ASC_KEY_CONTENT=$(base64 -i /path/to/AuthKey_AB12CD34EF.p8)

# 설정 확인
echo $ASC_KEY_ID
```

**방법 2: ~/.zshrc 또는 ~/.bash_profile에 영구 설정**
```bash
# 파일 편집
nano ~/.zshrc

# 아래 내용 추가 (실제 값으로 교체)
export ASC_KEY_ID="AB12CD34EF"
export ASC_ISSUER_ID="12345678-1234-1234-1234-123456789abc"
export ASC_KEY_CONTENT="LS0tLS1CRUdJTi..." # Base64 인코딩된 값

# 저장 후 적용
source ~/.zshrc
```

**⚠️ 보안:** 실제 운영에서는 `.p8` 파일을 안전한 곳에 보관하고, 환경변수는 로컬 머신에만 설정하세요. Git에 커밋하지 마세요!

#### 4.3 GitHub Actions Secrets 설정

1. GitHub 저장소 → **Settings** → **Secrets and variables** → **Actions**
2. **"New repository secret"** 클릭
3. 아래 3개의 Secret 추가:

| Name | Value | 설명 |
|------|-------|------|
| `ASC_KEY_ID` | `AB12CD34EF` | API Key ID |
| `ASC_ISSUER_ID` | `12345678-1234-...` | Issuer ID (UUID) |
| `ASC_KEY_CONTENT` | `LS0tLS1CRUdJTi...` | Base64 인코딩된 .p8 파일 내용 |

**Base64 인코딩 방법:**
```bash
base64 -i AuthKey_AB12CD34EF.p8 | pbcopy
# 클립보드에 복사됨 → GitHub Secret에 붙여넣기
```

---

## 로컬 사용법

### 프로젝트 구성 확인

| 항목 | 값 |
|------|-----|
| **프로젝트 파일** | `WorkOut Log.xcodeproj` |
| **스킴** | `workout_log` |
| **번들 ID** | `com.Ben.WorkOut-Log` |

**만약 `.xcworkspace` 사용 시:**
- `Fastfile`에서 `project: XCODEPROJ`를 `workspace: "WorkOut Log.xcworkspace"`로 변경
- 예시:
  ```ruby
  gym(
    workspace: "WorkOut Log.xcworkspace",
    scheme: SCHEME,
    # ...
  )
  ```

### 명령어 실행 예시

#### 1. 테스트 실행
```bash
bundle exec fastlane tests
```
**출력 예시:**
```
[✔] 🚀
[15:30:45]: -----------------------
[15:30:45]: --- Step: run_tests ---
[15:30:45]: -----------------------
[15:30:45]: $ xcodebuild -scheme workout_log -project 'WorkOut Log.xcodeproj' ...
Test Suite 'All tests' passed at 2025-10-19 15:32:10.
	 Executed 42 tests, with 0 failures (0 unexpected) in 12.345 seconds
[15:32:11]: ✅ Tests passed successfully
```

#### 2. 빌드 번호 증가
```bash
bundle exec fastlane bump_build
```
**효과:**
- `CFBundleVersion` 값이 1 증가 (예: 5 → 6)
- 자동 커밋: `chore(ci): bump build number to 6`

#### 3. 로컬 아카이브 생성
```bash
bundle exec fastlane build
```
**출력:**
- `build/` 디렉토리에 `.ipa` 파일 생성
- `build/` 디렉토리에 `.dSYM.zip` 파일 생성

**용도:** App Store Connect 수동 업로드, 로컬 테스트 배포

#### 4. TestFlight 자동 배포 (beta)
```bash
# 환경변수 설정 확인
echo $ASC_KEY_ID

# 실행
bundle exec fastlane beta
```
**동작 단계:**
1. 빌드 번호 자동 증가
2. 전체 테스트 실행
3. App Store 아카이브 생성
4. TestFlight 업로드

**출력 예시:**
```
[15:40:12]: Incrementing build number to 7
[15:40:15]: Running tests on iPhone 16...
[15:42:30]: ✅ All tests passed
[15:42:35]: Building archive...
[15:45:10]: Exporting IPA...
[15:46:20]: Uploading to TestFlight...
[15:48:50]: ✅ Successfully uploaded build 7 to TestFlight!
```

#### 5. App Store Connect 업로드 (release)
```bash
bundle exec fastlane release
```
**효과:**
- 아카이브 생성 후 App Store Connect 업로드
- `submit_for_review: false`로 설정되어 있어 자동 심사 제출은 안 됨
- App Store Connect에서 수동으로 "Submit for Review" 클릭 필요

---

## Lane 상세 설명

### 1. `tests` — 단위 테스트 실행

**명령:**
```bash
bundle exec fastlane tests
```

**동작:**
- iPhone 16 시뮬레이터에서 `workout_log` 스킴 테스트 실행
- 코드 커버리지 활성화 (`code_coverage: true`)
- `clean: true`로 빌드 캐시 초기화

**입력:** 없음
**출력:** 테스트 결과 (성공/실패), 커버리지 리포트

**사전조건:**
- Xcode 16 선택됨 (`xcode-select`)
- 시뮬레이터 설치됨

**실패 시:**
- 로그에서 실패한 테스트 케이스 확인
- Xcode에서 해당 테스트 직접 실행하여 디버깅

---

### 2. `bump_build` — 빌드 번호 증가

**명령:**
```bash
bundle exec fastlane bump_build
```

**동작:**
1. `CFBundleVersion` 값 1 증가 (예: `5` → `6`)
2. `WorkOut Log.xcodeproj/project.pbxproj` 파일 수정
3. Git 커밋: `chore(ci): bump build number to 6`

**입력:** 없음
**출력:** 새 빌드 번호, Git 커밋

**사전조건:**
- Git 작업 트리가 깨끗해야 함 (uncommitted changes 없음)
- Git 저장소 초기화됨

**실패 시:**
- Uncommitted changes가 있으면 커밋 실패
- 먼저 `git status` 확인 후 변경사항 커밋 또는 stash

**롤백:**
```bash
git reset --hard HEAD~1  # 마지막 커밋 취소
```

---

### 3. `build` — App Store 아카이브 생성

**명령:**
```bash
bundle exec fastlane build
```

**동작:**
- `workout_log` 스킴으로 App Store용 아카이브 빌드
- Automatic Signing 사용 (Xcode 프로젝트 설정 따름)
- IPA 및 dSYM 파일 생성

**입력:** 없음
**출력:**
- `build/WorkOut Log.ipa`
- `build/WorkOut Log.app.dSYM.zip`

**사전조건:**
- Xcode 프로젝트에서 Automatic Signing 활성화
- Apple Developer 계정 로그인 (Xcode → Settings → Accounts)

**실패 시:**
- Code signing 오류 → Xcode에서 Signing & Capabilities 탭 확인
- Provisioning profile 문제 → Xcode → Preferences → Accounts에서 "Download Manual Profiles" 클릭

---

### 4. `beta` — TestFlight 자동 배포

**명령:**
```bash
bundle exec fastlane beta
```

**동작 단계:**
1. **빌드 번호 증가** (`increment_build_number`)
2. **테스트 실행** (`run_tests`)
3. **아카이브 생성** (`gym`)
4. **TestFlight 업로드** (`pilot`)

**입력:**
- 환경변수: `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_CONTENT`

**출력:**
- TestFlight에 새 빌드 등록
- 빌드 번호가 증가된 Git 커밋 (로컬에서만, 푸시는 안 됨)

**사전조건:**
- App Store Connect API Key 환경변수 설정
- 앱이 App Store Connect에 등록되어 있어야 함
- 첫 빌드는 Xcode에서 수동으로 1회 업로드 후 Fastlane 사용 권장

**실패 시:**
- **Auth 오류:** `ASC_KEY_*` 환경변수 확인
- **테스트 실패:** 먼저 `bundle exec fastlane tests` 단독 실행하여 디버깅
- **업로드 실패:** App Store Connect 상태 확인 (점검 중인지)

**TestFlight 반영 시간:**
- 업로드 완료 후 5~30분 내 TestFlight에서 확인 가능
- "Processing"으로 표시되면 정상

---

### 5. `release` — App Store Connect 업로드

**명령:**
```bash
bundle exec fastlane release
```

**동작:**
1. App Store 아카이브 생성
2. App Store Connect에 업로드
3. **자동 심사 제출 안 함** (`submit_for_review: false`)

**입력:**
- 환경변수: `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_CONTENT`

**출력:**
- App Store Connect에 빌드 등록 (수동 심사 제출 대기 상태)

**사전조건:**
- `beta` lane과 동일
- 메타데이터(스크린샷, 설명 등)는 App Store Connect UI에서 별도 관리

**실패 시:**
- `beta` lane과 동일한 트러블슈팅 적용

**다음 단계:**
1. [App Store Connect](https://appstoreconnect.apple.com) 접속
2. 앱 선택 → 버전 선택
3. **"Submit for Review"** 클릭
4. 심사 질문 응답 후 제출

---

## 버전 관리 플로우

### 버전 번호 정책

**CFBundleShortVersionString (마케팅 버전):**
- 형식: `MAJOR.MINOR.PATCH` (예: `1.0.0`)
- **수동 관리:** Xcode 또는 `agvtool new-marketing-version X.Y.Z`로 변경
- 의미:
  - `MAJOR`: 호환성 깨지는 변경
  - `MINOR`: 기능 추가
  - `PATCH`: 버그 수정

**CFBundleVersion (빌드 번호):**
- 형식: 정수 (예: `1`, `2`, `3`, ...)
- **자동 관리:** `bundle exec fastlane bump_build` 또는 `beta` lane 실행 시 자동 증가
- App Store는 빌드 번호가 이전 빌드보다 커야 함

### 릴리스 플로우 예시

#### 시나리오 1: 첫 릴리스 (1.0.0)

```bash
# 1. 마케팅 버전 설정 (Xcode에서 수동 또는)
agvtool new-marketing-version 1.0.0

# 2. Beta 배포 (빌드 번호 자동 증가)
bundle exec fastlane beta

# 3. TestFlight에서 내부 테스트

# 4. 정식 릴리스 준비
bundle exec fastlane release

# 5. App Store Connect에서 Submit for Review
```

#### 시나리오 2: 버그 수정 릴리스 (1.0.0 → 1.0.1)

```bash
# 1. 버그 수정 후 마케팅 버전 변경
agvtool new-marketing-version 1.0.1

# 2. Git 커밋
git add -A
git commit -m "fix: critical bug in trends chart"

# 3. 태그 생성 (CI에서 자동 TestFlight 배포)
git tag v1.0.1
git push origin v1.0.1

# 4. GitHub Actions가 자동으로 beta lane 실행
# 5. TestFlight 확인 후 App Store 제출
```

### 태깅 가이드

**형식:**
```
v{MAJOR}.{MINOR}.{PATCH}
```

**예시:**
```bash
# 버전 태그 생성
git tag v1.0.0

# 태그 푸시 (CI 트리거)
git push origin v1.0.0

# 결과: GitHub Actions에서 beta lane 자동 실행 → TestFlight 업로드
```

**태그 목록 확인:**
```bash
git tag -l
```

**태그 삭제 (실수로 생성 시):**
```bash
# 로컬 태그 삭제
git tag -d v1.0.0

# 리모트 태그 삭제
git push origin :refs/tags/v1.0.0
```

---

## CI 워크플로우

### 전체 플로우 다이어그램

```
Developer (local)
    │
    ├─── PR to main ────────────────────┐
    │                                    │
    │                             GitHub Actions
    │                                    │
    │                           ┌────────▼────────┐
    │                           │   test job      │
    │                           │                 │
    │                           │ 1. bundle install
    │                           │ 2. fastlane tests
    │                           │                 │
    │                           └─────────────────┘
    │                                    │
    │                                    ▼
    │                            ✅ Tests Passed
    │
    └─── git tag v1.0.0 ────────────────┐
         git push origin v1.0.0         │
                                        │
                                 GitHub Actions
                                        │
                               ┌────────▼────────┐
                               │   beta job      │
                               │                 │
                               │ 1. Run tests    │
                               │ 2. fastlane beta│
                               │                 │
                               └────────┬────────┘
                                        │
                                        ▼
                                  TestFlight
                                        │
                                        ▼
                              Internal Testers
                                        │
                                        ▼
                               App Store Connect
                                        │
                                        ▼
                            Submit for Review (manual)
                                        │
                                        ▼
                                  App Store
```

### GitHub Actions 트리거 조건

**1. Pull Request → `test` job 실행**
```yaml
on:
  pull_request:
    branches: [main, feat/week1-foundations]
```

**동작:**
- PR 생성/업데이트 시 자동 실행
- `bundle exec fastlane tests` 실행
- 테스트 실패 시 PR merge 블록 권장

**2. Tag Push → `beta` job 실행**
```yaml
on:
  push:
    tags:
      - "v*"
```

**동작:**
- `v*` 패턴 태그 푸시 시 실행 (예: `v1.0.0`, `v2.1.3`)
- `test` job이 먼저 실행되고 성공해야 `beta` job 실행 (`needs: test`)
- `bundle exec fastlane beta` 실행
- TestFlight 자동 업로드

### GitHub Secrets 설정 체크리스트

| Secret 이름 | 설명 | 확인 방법 |
|-------------|------|-----------|
| `ASC_KEY_ID` | App Store Connect API Key ID | 영문+숫자 10자 (예: `AB12CD34EF`) |
| `ASC_ISSUER_ID` | Issuer ID | UUID 형식 (예: `12345678-1234-...`) |
| `ASC_KEY_CONTENT` | Base64 인코딩된 .p8 파일 | `LS0tLS1CRUdJTi...`로 시작 |

**설정 경로:**
```
GitHub 저장소 → Settings → Secrets and variables → Actions → Repository secrets
```

---

## Troubleshooting

### 1. Login/Auth 오류

#### 증상:
```
[!] Could not authenticate with App Store Connect
```

#### 원인:
- 환경변수 미설정 또는 잘못된 값
- API Key 만료 또는 권한 부족
- Base64 인코딩 오류

#### 해결:

**Step 1: 환경변수 확인**
```bash
echo $ASC_KEY_ID
echo $ASC_ISSUER_ID
echo $ASC_KEY_CONTENT | head -c 50  # 앞 50자만 출력
```

**Step 2: Base64 재인코딩**
```bash
# 올바른 방법
base64 -i AuthKey_AB12CD34EF.p8 | pbcopy

# ❌ 잘못된 방법 (줄바꿈 포함됨)
cat AuthKey_AB12CD34EF.p8 | base64
```

**Step 3: API Key 권한 확인**
- [App Store Connect → Users and Access → Keys](https://appstoreconnect.apple.com/access/api)
- 해당 Key의 **Access** 열에서 "App Manager" 또는 "Admin" 확인
- "Revoked" 상태면 새로 생성

**Step 4: GitHub Actions에서 확인**
```yaml
# .github/workflows/ci.yml에서 디버깅 추가
- name: Debug secrets
  run: |
    echo "ASC_KEY_ID length: ${#ASC_KEY_ID}"
    echo "ASC_ISSUER_ID length: ${#ASC_ISSUER_ID}"
    echo "ASC_KEY_CONTENT length: ${#ASC_KEY_CONTENT}"
```

---

### 2. 코드 서명 실패

#### 증상:
```
error: Automatic signing failed
```

#### 체크리스트:

**□ Xcode 프로젝트 설정 확인**
```
1. Xcode 열기
2. 프로젝트 네비게이터에서 "WorkOut Log" 선택
3. Targets → workout_log → Signing & Capabilities
4. ✅ "Automatically manage signing" 체크
5. Team 선택됨 (본인 Apple Developer 계정)
```

**□ Apple Developer 계정 로그인**
```
1. Xcode → Settings → Accounts
2. Apple ID 추가 (kei7659@daum.net)
3. "Download Manual Profiles" 클릭
```

**□ Provisioning Profile 갱신**
```bash
# Fastlane 사용
bundle exec fastlane sigh renew
```

**□ Bundle ID 일치 확인**
- Xcode: `com.Ben.WorkOut-Log`
- App Store Connect: `com.Ben.WorkOut-Log`
- `fastlane/Appfile`: `com.Ben.WorkOut-Log`

---

### 3. Xcode Path 오류

#### 증상:
```
xcode-select: error: tool 'xcodebuild' requires Xcode
```

#### 해결:
```bash
# 현재 Xcode 경로 확인
xcode-select -p

# 올바른 경로로 설정
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# 또는 Xcode 16 버전 지정
sudo xcode-select -s /Applications/Xcode_16.0.app/Contents/Developer

# Xcode License 동의 (필요 시)
sudo xcodebuild -license accept
```

---

### 4. TestFlight 업로드 지연

#### 증상:
- `pilot` 명령이 완료되었지만 TestFlight에 빌드가 안 보임

#### 정상 상태:
- 업로드 후 **5~30분** 소요 (Apple의 처리 시간)
- App Store Connect → TestFlight → iOS Builds에서 "Processing" 상태 확인

#### 로그 확인 지점:
```bash
# Fastlane 로그에서 확인
[15:48:50]: Successfully uploaded package to App Store Connect
[15:48:50]: ✅ Successfully uploaded build 7 to TestFlight!
```

#### App Store Connect 확인:
1. [App Store Connect](https://appstoreconnect.apple.com) 로그인
2. 앱 선택 → **TestFlight** 탭
3. **iOS Builds** 섹션에서 "Processing" 또는 "Ready to Submit" 확인

#### 비정상 상태 (에러):
```
[!] Error uploading ipa file:
The provided entity includes an attribute with a value that has already been used
```

**원인:** 동일한 빌드 번호 재업로드 시도
**해결:** `bundle exec fastlane bump_build` 실행 후 재시도

---

### 5. 테스트 실패

#### 증상:
```
Test Suite 'workout_logTests' failed
```

#### 해결:

**Step 1: 로컬에서 Xcode로 테스트**
```
1. Xcode 열기
2. Product → Test (Cmd+U)
3. 실패한 테스트 케이스 확인
```

**Step 2: 특정 테스트만 실행**
```bash
xcodebuild test \
  -scheme workout_log \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:workout_logTests/WeeklyBucketTests
```

**Step 3: 시뮬레이터 초기화**
```bash
# 모든 시뮬레이터 종료
xcrun simctl shutdown all

# 시뮬레이터 초기화
xcrun simctl erase all
```

---

## 보안 주의사항

### 🔒 절대 금지 사항

**❌ .p8 파일 Git 커밋 금지**
```bash
# .gitignore에 반드시 추가
*.p8
AuthKey_*.p8
```

**❌ 환경변수를 코드에 하드코딩 금지**
```ruby
# ❌ 잘못된 예시
api_key = app_store_connect_api_key(
  key_id: "AB12CD34EF",  # 하드코딩 금지!
  issuer_id: "12345678-1234-...",
  key_content: "LS0tLS1CRUdJTi..."
)

# ✅ 올바른 예시
api_key = app_store_connect_api_key(
  key_id: ENV["ASC_KEY_ID"],
  issuer_id: ENV["ASC_ISSUER_ID"],
  key_content: Base64.decode64(ENV["ASC_KEY_CONTENT"])
)
```

**❌ GitHub Actions 로그에 Secret 노출 금지**
```yaml
# ❌ 잘못된 예시
- name: Debug
  run: echo "Key: ${{ secrets.ASC_KEY_CONTENT }}"

# ✅ 올바른 예시 (길이만 확인)
- name: Debug
  run: echo "Key length: ${#ASC_KEY_CONTENT}"
```

### ✅ 권장 사항

**1. .p8 파일 안전 보관**
- 1Password, Bitwarden 등 비밀번호 관리자에 저장
- 로컬 머신의 암호화된 폴더에 백업

**2. API Key 권한 최소화**
- **Admin** 대신 **App Manager** 역할 사용
- 필요 없는 Key는 즉시 Revoke

**3. 정기 Key 로테이션**
- 6개월마다 API Key 재생성 권장
- 이전 Key는 Revoke 처리

**4. 팀원 간 Secret 공유 방법**
- Slack DM으로 전송 금지
- 1Password Shared Vault 사용 권장

---

## 부록: Fastfile 주요 옵션

### `run_tests` 액션

| 옵션 | 설명 | 예시 |
|------|------|------|
| `project` | Xcode 프로젝트 파일 경로 | `"WorkOut Log.xcodeproj"` |
| `workspace` | Xcode 워크스페이스 경로 (CocoaPods 사용 시) | `"WorkOut Log.xcworkspace"` |
| `scheme` | 빌드 스킴 | `"workout_log"` |
| `device` | 시뮬레이터 이름 | `"iPhone 16"`, `"iPhone SE (3rd generation)"` |
| `clean` | 빌드 전 clean 여부 | `true` / `false` |
| `code_coverage` | 코드 커버리지 활성화 | `true` / `false` |
| `only_testing` | 특정 테스트만 실행 | `["workout_logTests/WeeklyBucketTests"]` |

### `gym` 액션 (Archive & Export)

| 옵션 | 설명 | 예시 |
|------|------|------|
| `project` | Xcode 프로젝트 파일 경로 | `"WorkOut Log.xcodeproj"` |
| `workspace` | Xcode 워크스페이스 경로 | `"WorkOut Log.xcworkspace"` |
| `scheme` | 빌드 스킴 | `"workout_log"` |
| `export_method` | Export 방식 | `"app-store"`, `"ad-hoc"`, `"development"` |
| `clean` | 빌드 전 clean 여부 | `true` / `false` |
| `output_directory` | IPA 출력 디렉토리 | `"build"` |
| `include_symbols` | dSYM 파일 포함 | `true` / `false` |
| `include_bitcode` | Bitcode 포함 (iOS 14+ 불필요) | `false` |

### `pilot` 액션 (TestFlight Upload)

| 옵션 | 설명 | 예시 |
|------|------|------|
| `api_key` | App Store Connect API Key 객체 | `api_key` 변수 전달 |
| `skip_waiting_for_build_processing` | 업로드 후 Processing 완료 대기 안 함 | `true` (권장) |
| `changelog` | TestFlight 릴리스 노트 | `"Bug fixes and improvements"` |
| `distribute_external` | 외부 테스터에게 자동 배포 | `false` (수동 권장) |
| `groups` | 배포할 테스터 그룹 | `["Internal Testers"]` |

### `deliver` 액션 (App Store Upload)

| 옵션 | 설명 | 예시 |
|------|------|------|
| `api_key` | App Store Connect API Key 객체 | `api_key` 변수 전달 |
| `submit_for_review` | 자동 심사 제출 | `false` (수동 권장) |
| `skip_metadata` | 메타데이터 업로드 생략 | `true` |
| `skip_screenshots` | 스크린샷 업로드 생략 | `true` |
| `force` | 기존 빌드 덮어쓰기 | `true` |
| `automatic_release` | 심사 승인 후 자동 릴리스 | `false` |

### `increment_build_number` 액션

| 옵션 | 설명 | 예시 |
|------|------|------|
| `xcodeproj` | Xcode 프로젝트 경로 | `"WorkOut Log.xcodeproj"` |
| `build_number` | 특정 빌드 번호 설정 (옵션) | `42` |

**기본 동작:** 현재 빌드 번호 + 1

---

## 참고 문서

- [Fastlane 공식 문서](https://docs.fastlane.tools/)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [Xcode Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

**문서 버전:** 1.0.0
**최종 수정:** 2025년 10월 19일
**작성자:** Ben (오정석)
**문의:** kei7659@daum.net

